---
title: "Rustlerを用いてRustでErlangVM上で動作するWebアプリケーションを作成する"
date: 2020-10-31T21:11:44+09:00
description: 
draft: false
author:
 - "さんぽし"
tags:
 - "Elixir"
 - "Phoenix"
 - "Rust"
categories:
 - "development"
---

こんばんは、さんぽしです

先日このような記事を見かけました。

- [Using Rust to Scale Elixir for 11 Million Concurrent Users](https://blog.discord.com/using-rust-to-scale-elixir-for-11-million-concurrent-users-c6f19fc029d3)
- [Real time communication at scale with Elixir at Discord](https://elixir-lang.org/blog/2020/10/08/real-time-communication-at-scale-with-elixir-at-discord/)

どちらもDiscordはElixirを使ってるよ〜という記事なのですが、中を読んでいくと「Rustlerを用いてErlangVMのNIFsを応用することで一部の処理をRustで書いている」とのことでした。

今回のこの記事ではElixir


RustlerはErlang NIFs(Native Implemented Functions)を利用してElixir(Erlang)の中でRustの関数をフックできるようにしたライブラリです。


[![rusterlium/rustler - GitHub](https://gh-card.dev/repos/rusterlium/rustler.svg)](https://github.com/rusterlium/rustler)

>Rustler is a library for writing Erlang NIFs in safe Rust code. That means there should be no ways to crash the BEAM (Erlang VM). The library provides facilities for generating the boilerplate for interacting with the BEAM, handles encoding and decoding of Erlang terms, and catches rust panics before they unwind into C.

すごく簡単にいうとElixirの中でRustの関数を呼べるよってことです。

> - Safety - The code you write in a Rust NIF should never be able to crash the BEAM.
> - Interop - Decoding and encoding rust values into Erlang terms is as easy as a function call.
> - Type composition - Making a Rust struct encodable and decodable to Erlang or Elixir can be done with a single attribute.
> - Resource objects - Enables you to safely pass a reference to a Rust struct into Erlang code. The struct will be automatically dropped when it's no longer referenced.

NIFsは強力な反面ネイティブな関数がクラッシュした際にErlang VM自体に深刻な影響をもたらす可能性がありますが、そんなNIFsの安全性を高めつつ利用できるのがRustlerです。

## Elixirの中でRustを呼べると何が嬉しいか

Rust側から見るとタイトルにもある通り、RustをErlangVM上で動作させることが一番の強みになります。

> Elixirは、低レイテンシで分散型のフォールトトレラントシステムや、Webや組み込みシステムの領域で成功を収めている、Erlang VMを利用します。
https://elixir-lang.jp/

これらの強みをまるっといただくことができます。

そしてElixir側から見たNifを利用してRustを使用するメリットとしては(これはNIFs自体のメリットとも言えますが)、実行速度の向上です。

ErlangVMのプロセスの実行はスケジューラーによって全て管理され、それによりErlangVMならではの多くの恩恵を受けていますが、トレードオフとしてその管理の分ネイティブコードの実行よりは当然速度で劣ることになります。この辺りの詳細は以下の記事の前半が参考になります

[Writing Rust NIFs for your Elixir code with the Rustler package](https://medium.com/@jacob.lerche/writing-rust-nifs-for-your-elixir-code-with-the-rustler-package-d884a7c0dbe3)

--- 
(引用と和訳)

> the fastest way being with a Native Implemented Function (NIF) whose API expects them to be written in C. But speaking frankly, the last time I worked with C involved a lengthy debugging session that boiled down to the lack of type safety, so I’d rather not have to repeat that experience. It’s for this reason that Rust is such a compelling language. It has a robust type system with type inference, pattern matching, and many more features. That and it has a C compatible ABI.

最も速い方法はネイティブ実装関数（NIF）で、そのAPIはC言語で書かれていることを期待しています。しかし率直に言って、前回C言語を使って作業したときは、型の安全性がないことが原因で長時間のデバッグセッションが必要でした。だからこそ、Rust は魅力的な言語なのです。型推論、パターンマッチング、その他多くの機能を備えた堅牢な型システムを持っています。また、C互換のABIを持っています。

> This is where the Rustler project comes in. In its own words it provides a safe bridge for writing Erlang NIFs. One of its safety guarantees is catching panics before they reach the C code. One of the nice things about Rust is that if the code compiles, you can be reasonably sure you won’t run into a wide range of memory safety related bugs, among others.

ここでRustlerプロジェクトの出番です。Rustlerの言葉を借りれば、ErlangのNIFを書くための安全なブリッジを提供します。その安全性の保証の一つは、パニックがC言語のコードに到達する前にキャッチすることです。Rustの良いところの一つは、コードがコンパイルされた場合、特にメモリ安全性に関連した広範囲のバグに遭遇しないことを合理的に保証できることです。

(引用と和訳ここまで)

---

NIFsの「クラッシュした際にErlang VMに対する影響がやばい」という諸刃の剣の諸刃の部分(?)をRustのメモリ安全性を利用して、安全性を担保することができます。

## 実際に使ってみる

NIFsを用いてElixirのコードに触れることなくRustのみを用いてWebアプリを立てられれば良いな〜と思っていたのですが、全く触れないというのは流石に無理でした。

今回はものすごく簡単なAPIサーバーを作成してみます。

ElixirのデファクトなWebフレームワークであるPhoenixを利用します。

ElixirやPhoenix自体のインストール方法は公式に説明を譲り、省略します。

[elixir - Install](https://elixir-lang.org/install.html)
[Phoenix - Installation](https://hexdocs.pm/phoenix/installation.html)

```
$ mix phx.new rust_phx_sample --no-ecto
```

このコマンドでPhoenixのプロジェクトが作成されます(`rust_phx_sample`はプロジェクト名です)
途中で何か聞かれたらとりあえずYesにしておきましょう

作成されたプロジェクトのディレクトリに入って以下のコマンドでサーバーを立ち上げます

```
$ mix phx.server
```

`localhost:4000`にアクセスして以下のような画面が表示されればうまいことプロジェクトを作成できています。

![PhoenixのTOP](/images/posts/phoenix-top.png)

PhoenixはRails likeのMVCなフレームワークです。

とりあえず以下のファイルを作成してjsonを返すpathを作成します

```lib/rust_phx_sample_web/controllers/sample_controller.ex
defmodule RustPhxSampleWeb.SampleController do
  use RustPhxSampleWeb, :controller

  def sample(conn, _params) do
    num = 1 + 2
    params = %{number: num}

    render(conn, "sample.json", number: num)
  end
end
```

```lib/rust_phx_sample_web/views/sample_view.ex
defmodule RustPhxSampleWeb.SampleView do
  use RustPhxSampleWeb, :view

  def render("sample.json", json = %{number: num}) do
    IO.inspect json
    %{number: num}
  end
end
```
