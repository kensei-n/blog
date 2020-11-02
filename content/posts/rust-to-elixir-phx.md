---
title: "RustでErlangVM上で動作するWebアプリケーションを開発する"
date: 2020-10-31T21:11:44+09:00
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

僕はElixir好き好き君なのですが、先日以下のような記事を見かけました。

- [Using Rust to Scale Elixir for 11 Million Concurrent Users](https://blog.discord.com/using-rust-to-scale-elixir-for-11-million-concurrent-users-c6f19fc029d3)
- [Real time communication at scale with Elixir at Discord](https://elixir-lang.org/blog/2020/10/08/real-time-communication-at-scale-with-elixir-at-discord/)

どちらも「DiscordはElixirを使ってるよ〜」という内容の記事なのですが、詳しく読んでいくと
「**Rustler**を用いてErlangVMのNIFsを応用することで一部の処理をRustで書いている」
とのことでした。

そもそもNIFsって何という詳しい話は以下の公式のページに説明を譲ります
[8. NIFs - Erlang](http://erlang.org/doc/tutorial/nif.html)

RustlerはErlang NIFs(Native Implemented Functions)を利用してElixir(Erlang)の中でRustの関数をフックできるようにしたライブラリです。

[![rusterlium/rustler - GitHub](https://gh-card.dev/repos/rusterlium/rustler.svg)](https://github.com/rusterlium/rustler)

## RustをErlangVM上で動作させると何が嬉しいか

Rust開発者側から見るとErlangVMの恩恵を受けることができる点が一番大きなメリットです。(それはそうという感じですね)

> Elixirは、低レイテンシで分散型のフォールトトレラントシステムや、Webや組み込みシステムの領域で成功を収めている、Erlang VMを利用します。
https://elixir-lang.jp/

ものすごく堅牢と言われるErlangVMのこれらの強みをRustでまるっといただくことができます。

現状、ある程度の環境が整っていてErlangVMを扱うことができる言語はErlang, Elixirがありますが、Webアプリケーションの開発となるとElixir一択と言ってもいいでしょう。

そんな中でErlangVM上のアプリケーションの開発の選択肢としてRustも入ってくるのはコミュニティにとってもかなり良いことだと感じます(Rustをbeamにコンパイルできるという話ではないのでElixir, Erlangとは完全に別の種別になります。今後Rustler等が発展し開発者から見ればRustのみで開発を行いErlangVMを扱えるという環境になる未来はあるのかもですが、Rust単体でErlangVMを扱えるという話ではないです)

## Erlang/Elixirの中でRustを呼べると何が嬉しいか

そしてElixir側から見たNIFsを利用してRustを使用するメリットとしては(これはNIFs自体のメリットとも言えますが)、実行速度の向上が言われています。

しかし、Erlangの"The Seven Myths of Erlang Performance"として、以下が挙げられています
[2.7  Myth: A NIF Always Speeds Up Your Program](https://erlang.org/doc/efficiency_guide/myths.html#myth--a-nif-always-speeds-up-your-program)

1. NIFで早くなるかは保証できない
2. 少なくともdangerousにはなる
3. NIFの関数を呼ぶこと自体や、戻り値や引数をチェックすることの小さなオーバーヘッドがあるから細々とした関数をチマチマ呼ぶとむしろ遅くなったりするかも

なるほど、という感じですね。

1.に関しては(結局は3と合わせてNIFsの扱い方なんだろうとは思いますが)前述のDiscordの記事も然り、実行速度は早くなるという見方が大勢な気がします。

2に関しては以下の記事が分かりやすかったです

[Writing Rust NIFs for your Elixir code with the Rustler package](https://medium.com/@jacob.lerche/writing-rust-nifs-for-your-elixir-code-with-the-rustler-package-d884a7c0dbe3)

--- 
(引用と和訳)

> the fastest way being with a Native Implemented Function (NIF) whose API expects them to be written in C. But speaking frankly, the last time I worked with C involved a lengthy debugging session that boiled down to the lack of type safety, so I’d rather not have to repeat that experience. It’s for this reason that Rust is such a compelling language. It has a robust type system with type inference, pattern matching, and many more features. That and it has a C compatible ABI.

最も速い方法はネイティブ実装関数（NIF）で、そのAPIはC言語で書かれていることを期待しています。しかし率直に言って、前回C言語を使って作業したときは、型の安全性がないことが原因で長時間のデバッグセッションが必要でした。だからこそ、Rust は魅力的な言語なのです。型推論、パターンマッチング、その他多くの機能を備えた堅牢な型システムを持っています。また、C互換のABIを持っています。

> This is where the Rustler project comes in. In its own words it provides a safe bridge for writing Erlang NIFs. One of its safety guarantees is catching panics before they reach the C code. One of the nice things about Rust is that if the code compiles, you can be reasonably sure you won’t run into a wide range of memory safety related bugs, among others.

ここでRustlerプロジェクトの出番です。Rustlerの言葉を借りれば、ErlangのNIFを書くための安全なブリッジを提供します。その安全性の保証の一つは、パニックがC言語のコードに到達する前にキャッチすることです。Rustの良いところの一つは、コードがコンパイルされた場合、特にメモリ安全性に関連した広範囲のバグに遭遇しないことを合理的に保証できることです。

(引用と和訳ここまで)

---

NIFsの「クラッシュした際にErlang VMに対する影響がやばい」という諸刃の剣の諸刃の部分(?)をRustのメモリ安全性を利用して、安全面を担保することができます。

## 実際にRustlerを使ってみる

長い前置きはここまでにして、Rustlerを実際に用いてみて開発の流れを確認してみましょう。今回は簡単なAPIサーバーを作成してみます。

ElixirのデファクトなWebフレームワークであるPhoenixを利用します。

ElixirやPhoenix、Rust自体のインストール方法は公式に説明を譲り、省略します。

[elixir - Install](https://elixir-lang.org/install.html)
[Phoenix - Installation](https://hexdocs.pm/phoenix/installation.html)
[Rust - Install Rust](https://www.rust-lang.org/tools/install)

この記事の対象読者は全人類です。Elixir/Phoenixに精通していない人、Rust分からんって人にもわかるように割と一歩一歩解説していきます。
また、筆者はRust歴0日なのでそもそもRust分からんの人間です。

今回のソースコードは全て以下のリポジトリに置いてあります。

[![sanposhiho/rust-to-elixir-phoenix-sample - GitHub](https://gh-card.dev/repos/sanposhiho/rust-to-elixir-phoenix-sample.svg)](https://github.com/sanposhiho/rust-to-elixir-phoenix-sample)


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

とりあえずsampleとして簡単なjsonを返すpathを作成します

以下のように`sample_controller.ex`と`sample_view.ex`を作成します

```lib/rust_phx_sample_web/controllers/sample_controller.ex
defmodule RustPhxSampleWeb.SampleController do
  use RustPhxSampleWeb, :controller

  def sample(conn, _params) do
    num = add(1, 2)

    render(conn, "sample.json", number: num)
  end

  def add(num1, num2) do
    num1 + num2
  end
end

```

```lib/rust_phx_sample_web/views/sample_view.ex
defmodule RustPhxSampleWeb.SampleView do
  use RustPhxSampleWeb, :view

  def render("sample.json", %{number: num}) do
    %{number: num}
  end
end
```

`router.ex`を編集してroutingを追加します

```lib/rust_phx_sample_web/router.ex
  scope "/", RustPhxSampleWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/sample", SampleController, :sample
  end
```

これによって`/sample`にアクセスすると以下のように雑なAPiが作成できていることがわかります

![json返している](/images/posts/router.png)

ここまでで一旦雑なAPIサーバーを立てることができました

### rustlerの導入

`mix.exs`に`rustler`の依存を追加します

```mix.exs
  defp deps do
    [
      {:phoenix, "~> 1.5.6"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.3 or ~> 0.2.9"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:rustler, "~> 0.21.0"} #add
    ]
  end
```

```
$ mix deps.get
```

これで`rustler`を導入できました

`mix rustler.new`で新しいNIFs用のプロジェクトを作成します

```
$ mix rustler.new
This is the name of the Elixir module the NIF module will be registered to.
Module name > RustPhxSampleWeb.SampleController 
This is the name used for the generated Rust crate. The default is most likely fine.
Library name (rustphxsampleweb_samplecontroller) > 
* creating native/rustphxsampleweb_samplecontroller/.cargo/config
* creating native/rustphxsampleweb_samplecontroller/README.md
* creating native/rustphxsampleweb_samplecontroller/Cargo.toml
* creating native/rustphxsampleweb_samplecontroller/src/lib.rs
Ready to go! See /Users/kenseinakada/workspace/rust_phx_sample/native/rustphxsampleweb_samplecontroller/README.md for further instructions.
```

作成されたRustのテンプレートファイルを覗いてみると以下のようになっています

```native/rustphxsampleweb_samplecontroller/src/lib.rs
use rustler::{Encoder, Env, Error, Term};

mod atoms {
    rustler_atoms! {
        atom ok;
        //atom error;
        //atom __true__ = "true";
        //atom __false__ = "false";
    }
}

rustler::rustler_export_nifs! {
    "Elixir.RustPhxSampleWeb.SampleController",
    [
        ("add", 2, add)
    ],
    None
}

fn add<'a>(env: Env<'a>, args: &[Term<'a>]) -> Result<Term<'a>, Error> {
    let num1: i64 = args[0].decode()?;
    let num2: i64 = args[1].decode()?;

    Ok((atoms::ok(), num1 + num2).encode(env))
}

```

Elixir側のaddと実装が合うように以下のように修正します

```native/rustphxsampleweb_samplecontroller/src/lib.rs
use rustler::{Encoder, Env, Error, Term};

rustler::rustler_export_nifs! {
    "Elixir.RustPhxSampleWeb.SampleController",
    [
        ("add", 2, add)
    ],
    None
}

fn add<'a>(env: Env<'a>, args: &[Term<'a>]) -> Result<Term<'a>, Error> {
    let num1: i64 = args[0].decode()?;
    let num2: i64 = args[1].decode()?;

    Ok((num1 + num2).encode(env))
}
```

Elixir側のaddでRustのaddを呼び出すように以下のように変更を加えます

```lib/rust_phx_sample_web/controllers/sample_controller.ex
defmodule RustPhxSampleWeb.SampleController do
  use RustPhxSampleWeb, :controller
  use Rustler, otp_app: :rust_phx_sample, crate: :rustphxsampleweb_samplecontroller

  def sample(conn, _params) do
    num = add(1, 2)

    render(conn, "sample.json", number: num)
  end

  def add(_a, _b), do: exit(:nif_not_loaded)
end
```

また、`mix.exs`を再び編集し、Elixirのコンパイル時にRustのコードも一緒にコンパイルされるように設定します

```mix.exs
  def project do
    [
      app: :rust_phx_sample,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext, :rustler] ++ Mix.compilers(), #rustlerの追加
      rustler_crates: rustler_crates(), #追加
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp rustler_crates() do
    [rustphxsampleweb_samplecontroller: [
      path: "native/rustphxsampleweb_samplecontroller",
      mode: rustc_mode(Mix.env)
    ]]
  end

  defp rustc_mode(:prod), do: :release
  defp rustc_mode(_), do: :debug
```

これによってPhoenixのサーバーを立ち上げ直すことでRustのコンパイルも実行されます

```
$ mix phx.server
```

同様に`/sample`にアクセスすることで以下のように先ほどと同じ結果が帰ってきていることがわかります
![json返している](/images/posts/router.png)

これによってElixirのaddの関数をNIFに置き換えてRustのaddを代わりに実行することができました。

### もう少し本格的なAPIサーバーを実装してみる

ここまででRustlerの雰囲気は掴んでいただけたのではないでしょうか。

**「いや足し算の関数置き換えただけでRustでWebアプリケーションって言えるんか」**

そう言われると思ったので、そこでここからAPIサーバーが行うことの多いであろう、DBへのアクセスを絡めた処理を実際にRustで実装してみます

先ほどと同様の手順で`user_controller.ex`、`user_view.ex`を作成し、`router.ex`にrouteを追加します

```lib/rust_phx_sample_web/controllers/user_controller.ex
defmodule RustPhxSampleWeb.UserController do
  use RustPhxSampleWeb, :controller
  use Rustler, otp_app: :rust_phx_sample, crate: :rustphxsampleweb_usercontroller

  def create(conn, %{"user" => %{"name" => name, "age" => age}}) do
    {:ok, {id, name, age}} = create_user(name, age)

    user = %{
      id: id,
      name: name,
      age: age,
    }

    render(conn, "user.json", user: user)
  end

  def create_user(_name, _age), do: exit(:nif_not_loaded)
end
```

```lib/rust_phx_sample_web/views/user_view.ex
defmodule RustPhxSampleWeb.UserView do
  use RustPhxSampleWeb, :view

  def render("user.json", %{user: user}) do
    %{user: user}
  end
end
```

```lib/rust_phx_sample_web/router.ex
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    # plug :protect_from_forgery  # セキュリティ上ものすごく良くないがCSRFToken Errorを回避するのがめんどくさいので今回は無効化
    plug :put_secure_browser_headers
  end

#..(中略)
    post "/user", UserController, :create
```

同様の手順で新しいNIFs用のプロジェクトを作成します

```
$ mix rustler.new
This is the name of the Elixir module the NIF module will be registered to.
Module name > RustPhxSampleWeb.UserController
This is the name used for the generated Rust crate. The default is most likely fine.
Library name (rustphxsampleweb_usercontroller) >
* creating native/rustphxsampleweb_usercontroller/.cargo/config
* creating native/rustphxsampleweb_usercontroller/README.md
* creating native/rustphxsampleweb_usercontroller/Cargo.toml
* creating native/rustphxsampleweb_usercontroller/src/lib.rs
Ready to go! See /Users/kenseinakada/workspace/rust_phx_sample/native/rustphxsampleweb_usercontroller/README.md for further instructions.
```

`mix.exs`にも作成しNIFs用のプロジェクトを登録します

```mix.exs
  defp rustler_crates() do
    [rustphxsampleweb_samplecontroller: [
      path: "native/rustphxsampleweb_samplecontroller",
      mode: rustc_mode(Mix.env)
    ],
    rustphxsampleweb_usercontroller: [                   # add
      path: "native/rustphxsampleweb_usercontroller",
      mode: rustc_mode(Mix.env)
    ]
    ]
  end
```

そして作成された`native/rustphxsampleweb_usercontroller/src/lib.rs`にDBにUserを格納する処理を書いていきます。

DBクライアントライブラリには`Diesel`を使用しました。

Rustの実際のコードは長いので載せませんが、以下に置いてあります。

[sanposhiho/rust-to-elixir-phoenix-sample:native/rustphxsampleweb_usercontroller/src](https://github.com/sanposhiho/rust-to-elixir-phoenix-sample/blob/master/native/rustphxsampleweb_usercontroller/src)

実際に`mix phx.server`をしてサーバーを立てて、curlでAPIを叩いてみます。

```
$ curl -X POST  -H "Content-Type: application/json" -d '{"user":{"name":"taro", "age":14}}' localhost:4000/user
{"user":{"age":1,"id":1,"name":"taro"}}

$ curl -X POST  -H "Content-Type: application/json" -d '{"user":{"name":"miho", "age":12}}' localhost:4000/user
{"user":{"age":1,"id":2,"name":"miho"}}
```
しっかりレスポンスが返ってきました。

今回はReadのAPIを立てていないので直接DBを覗きに行くと

```
diesel_demo=> select * from users;
 id | name | age
----+------+-----
  1 | taro |   14
  2 | miho |   12
(2 rows)
```

ちゃんとWriteされていることがわかります

## Rustlerを使ってみて

RustlerはRust側の関数とElixir側の関数を紐付けるだけでかなりRust側に処理を任せることができることがわかりました。
Phoenixにルーティングとレスポンスの構築のみを任せて内部の処理を全てRustに置き換えるようなことも実現が可能そうな感じがします。まあ、冒頭でもお話ししたようにNIFsは適材適所な面も大きいため、全てをRustに置き換えれればハッピーということもないのかもしれません。

やはりElixir/Phoenix側のコードを少なからずいじる必要もあるので、Rustだけを知っている人がElixir/Phoenixを利用してErlangVM上でRustを動作させるということは現状少しハードルがある感じがします。
この辺をうまく吸収し、RustだけでErlangVM上で動作するアプリケーションを作成できるようになったら面白いかもしれませんね。

Rustlerは現在v0.21.0が最新リリースです。メジャーバージョンが待ち遠しいです。
読んでいただきありがとうございました。
