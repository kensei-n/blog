---
title: "ElixirでDialyzerを用いた静的解析を行い、型(Typespec)を最大限に活用する"
date: 2020-11-10T03:50:09+09:00
author:
 - "さんぽし"
tags:
 - "Elixir"
 - "Phoenix"
 - "静的解析"
categories:
 - "development"
---

Elixirには静的解析ツールのDialyxirというものが存在します

[![jeremyjh/dialyxir - GitHub](https://gh-card.dev/repos/jeremyjh/dialyxir.svg)](https://github.com/jeremyjh/dialyxir)

> Mix tasks to simplify use of Dialyzer in Elixir projects.

Dialyxir自体は今年(2020年)の三月にv1.0.0がリリースされた比較的新しいライブラリです。

Dialyxir は[Dialyzer](http://www.erlang.org/doc/man/dialyzer.html)というErlangの静的解析ツールをElixirのmixタスクとしてさくっと実行可能にしたライフラリです。Dialyzerを直接Elixirで使用することもできるのですが、いろいろ手順がめんどくさそうだったのですごく助かります

## 昨今のトレンド

昨今のでもないかもしれませんが、最近は特にGoやRustなどの静的型付けの言語が流行ってきているというのは感じるところだと思います。ましてやWebフロントエンドではJavaScriptに型を付けたTypeScriptがデファクトになりつつあります(知らんけど)

多くの理由はあると思いますが、個人的には最も大きいメリットは「保守性」だと思います。プロダクトの規模が大きくなるにつれて型がついていることにおけるメリットが大きくなっていきます。

静的型付け言語ではコンパイル時に多くのエラーをチェックしてくれますね。
プロダクトが大きくなってくるとコードの変更による影響範囲が大きくなってきます。動的型付けでは予想していなかった部分に変更の影響が出てしまい、「まあ(自分の実装したつもりの範囲は)動いているしヨシ!」とやって気がつかない、みたいなことが起こるかもしれないわけです。(実際はそれをしっかりテスト等で担保して頑張っているわけです)

## Dialyzerの概要

Elixirは動的型付け言語です。普通にいくと開発者は型に関与せずプログラミングをすることになります。そこでDialyzerです。
静的解析を行ってかなり詳しい部分まで確認してくれます。

Dialyzerはtypespecを利用することで型を利用したチェックまで行うことができ、最大限の力を発揮します
[Typespecs - Elixir](https://hexdocs.pm/elixir/typespecs.html)
> they're used by tools such as Dialyzer, that can analyze code with typespec to find type inconsistencies and possible bugs

(ちなみにtypespecを使用していないコードに対しても型が関与しない部分で色々確認をしてくれるので、導入する価値があります)

## Dialyxirを導入する

特に大きく作業は発生しません

`mix.exs`にDialyxirの依存を追加します。

```
defp deps do
  [
#..(略)
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
  ]
end
```

```
$ mix do deps.get, deps.compile
```

これで以下のコードで実行できます
導入したのがDialyxirなのに実行するのが`mix dialyzer`なのがややこしいですね。Dialyxir経由でDialyzerを使用しているわけなのでこの先ではmixタスク名と合わせて*Dialyzerを使用する*と表現します

```
$ mix dialyzer
Compiling 14 files (.ex)
Generated dialyxir_sample app
Finding suitable PLTs
Checking PLT...
[:asn1, :compiler, :connection, :cowboy, :cowboy_telemetry, :cowlib, :crypto, :db_connection, :decimal, :ecto, :ecto_sql, :eex, :elixir, :file_system, :gettext, :jason, :kernel, :logger, :mime, :phoenix, :phoenix_ecto, :phoenix_html, :phoenix_live_dashboard, :phoenix_live_reload, :phoenix_live_view, :phoenix_pubsub, :plug, :plug_cowboy, :plug_crypto, :postgrex, :public_key, :ranch, :runtime_tools, :ssl, :stdlib, :telemetry, :telemetry_metrics, :telemetry_poller]
Looking up modules in dialyxir_erlang-23.1.1_elixir-1.11.1_deps-dev.plt
Looking up modules in dialyxir_erlang-23.1.1_elixir-1.11.1.plt
Finding applications for dialyxir_erlang-23.1.1_elixir-1.11.1.plt
Finding modules for dialyxir_erlang-23.1.1_elixir-1.11.1.plt
Removing 5 modules from dialyxir_erlang-23.1.1_elixir-1.11.1.plt
Checking 438 modules in dialyxir_erlang-23.1.1_elixir-1.11.1.plt
Adding 5 modules to dialyxir_erlang-23.1.1_elixir-1.11.1.plt
done in 0m35.19s
Finding applications for dialyxir_erlang-23.1.1_elixir-1.11.1_deps-dev.plt
Finding modules for dialyxir_erlang-23.1.1_elixir-1.11.1_deps-dev.plt
Copying dialyxir_erlang-23.1.1_elixir-1.11.1.plt to dialyxir_erlang-23.1.1_elixir-1.11.1_deps-dev.plt
Looking up modules in dialyxir_erlang-23.1.1_elixir-1.11.1_deps-dev.plt
Checking 443 modules in dialyxir_erlang-23.1.1_elixir-1.11.1_deps-dev.plt
Adding 806 modules to dialyxir_erlang-23.1.1_elixir-1.11.1_deps-dev.plt
done in 4m17.71s
No :ignore_warnings opt specified in mix.exs and default does not exist.

Starting Dialyzer
[
  check_plt: false,
  init_plt: '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/dialyxir_erlang-23.1.1_elixir-1.11.1_deps-dev.plt',
  files: ['/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSample.Application.beam',
   '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSample.Repo.beam',
   '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSample.beam',
   '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSampleWeb.Endpoint.beam',
   '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSampleWeb.ErrorHelpers.beam',
   ...],
  warnings: [:unknown]
]
Total errors: 0, Skipped: 0, Unnecessary Skips: 0
```

初回の実行はかなり時間がかかりますが、一回目以降はさくっと終わります

↑上記では`mix phx.new`したばかりのコードに対してDialyzerを実行しています。当然何のエラーも出ません

## typespecを利用しない静的解析例

適当に`add/2`を実装し、controllerから呼び出します

```
defmodule DialyxirSample do
  @moduledoc """
  DialyxirSample keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def add(a, b) do
    a + b
  end
end
```

```
defmodule DialyxirSampleWeb.PageController do
  use DialyxirSampleWeb, :controller

  def index(conn, _params) do
    result = DialyxirSample.add(1, 1)

    render(conn, "index.html")
  end
end
```

これも特に変な部分もないのでDialyzerで何のエラーも出ません
ここでcontroller側での呼び出しの引数を減らしてみまそう

```
defmodule DialyxirSampleWeb.PageController do
  use DialyxirSampleWeb, :controller

  def index(conn, _params) do
    result = DialyxirSample.add(1)

    render(conn, "index.html")
  end
end
```

これに対してDialyzerを実行してみると、以下のように怒られが発生します

```
$ mix dialyzer  
Finding suitable PLTs
Checking PLT...
[:asn1, :compiler, :connection, :cowboy, :cowboy_telemetry, :cowlib, :crypto, :db_connection, :decimal, :ecto, :ecto_sql, :eex, :elixir, :file_system, :gettext, :jason, :kernel, :logger, :mime, :phoenix, :phoenix_ecto, :phoenix_html, :phoenix_live_dashboard, :phoenix_live_reload, :phoenix_live_view, :phoenix_pubsub, :plug, :plug_cowboy, :plug_crypto, :postgrex, :public_key, :ranch, :runtime_tools, :ssl, :stdlib, :telemetry, :telemetry_metrics, :telemetry_poller]
PLT is up to date!
No :ignore_warnings opt specified in mix.exs and default does not exist.

Starting Dialyzer
[
  check_plt: false,
  init_plt: '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/dialyxir_erlang-23.1.1_elixir-1.11.1_deps-dev.plt',
  files: ['/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSample.Application.beam',
   '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSample.Repo.beam',
   '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSample.beam',
   '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSampleWeb.Endpoint.beam',
   '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSampleWeb.ErrorHelpers.beam',
   ...],
  warnings: [:unknown]
]
Total errors: 1, Skipped: 0, Unnecessary Skips: 0
done in 0m1.96s
lib/dialyxir_sample_web/controllers/page_controller.ex:5:call_to_missing
Call to missing or private function DialyxirSample.add/1.
________________________________________________________________________________
done (warnings were emitted)
Halting VM with exit status 2
```

ちなみにですが、外部参照しているmoduleの関数の引数の数が間違っていても`mix compile`では何のエラーも出ません。

```
$ mix dialyzer
```

これが前述したtypespecを使用していないコードに対しても型が関与しない部分で色々確認をしてくれるってやつのうちのひとつです。

## typespecを利用した静的解析例

`print/2`を適当に実装します

```
  @spec print(a :: integer, b :: integer) :: atom()
  def print(a, b) do
    IO.puts(a)
    IO.puts(b)
    :ok
  end
```

typespecでintegerを引数として受け取ることを提示します

```
  result = DialyxirSample.print(1, 1)
```

もちろん上記のようにintegerのみを渡すとDialyzerの実行は成功しますが

```
  result = DialyxirSample.print(1, "a")
```

これだと失敗します

```
$ mix dialyzer
Compiling 1 file (.ex)
Finding suitable PLTs
Checking PLT...
[:asn1, :compiler, :connection, :cowboy, :cowboy_telemetry, :cowlib, :crypto, :db_connection, :decimal, :ecto, :ecto_sql, :eex, :elixir, :file_system, :gettext, :jason, :kernel, :logger, :mime, :phoenix, :phoenix_ecto, :phoenix_html, :phoenix_live_dashboard, :phoenix_live_reload, :phoenix_live_view, :phoenix_pubsub, :plug, :plug_cowboy, :plug_crypto, :postgrex, :public_key, :ranch, :runtime_tools, :ssl, :stdlib, :telemetry, :telemetry_metrics, :telemetry_poller]
PLT is up to date!
No :ignore_warnings opt specified in mix.exs and default does not exist.

Starting Dialyzer
[
  check_plt: false,
  init_plt: '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/dialyxir_erlang-23.1.1_elixir-1.11.1_deps-dev.plt',
  files: ['/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSample.Application.beam',
   '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSample.Repo.beam',
   '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSample.beam',
   '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSampleWeb.Endpoint.beam',
   '/Users/kenseinakada/workspace/dialyxir_sample/_build/dev/lib/dialyxir_sample/ebin/Elixir.DialyxirSampleWeb.ErrorHelpers.beam',
   ...],
  warnings: [:unknown]
]
Total errors: 2, Skipped: 0, Unnecessary Skips: 0
done in 0m1.91s
lib/dialyxir_sample_web/controllers/page_controller.ex:4:no_return
Function index/2 has no local return.
________________________________________________________________________________
lib/dialyxir_sample_web/controllers/page_controller.ex:5:call
The function call will not succeed.

DialyxirSample.print(1, <<97>>)

breaks the contract
(a :: integer(), b :: integer()) :: atom()

________________________________________________________________________________
done (warnings were emitted)
Halting VM with exit status 2
```

しっかり型を利用した静的解析をしてくれていることがわかります

## Dialyzerの利用における工夫例

Dialyzerは常にチェックし続けることに意味があります。

```
.PHONY: serve
serve:
	mix dialyzer
	mix phx.server

.PHONY: test
test:
	mix dialyzer
	mix test
```

そのため僕のPhoenixプロジェクトでは上記の通りMakefileにて、`mix phx.server`時、`mix test`時に一緒にDialyzerを実行してくれるように良さげにタスクを定義しています

また、以下の記事を参考にGitHub Actionsにさくっと追加するのも良いと思います(記事のようにうまくキャッシュしないと毎回長時間かかることになるので注意)

[Build the Ultimate Elixir CI with Github Actions - Running Dialyzer Checks With PLT Cache](https://hashrocket.com/blog/posts/build-the-ultimate-elixir-ci-with-github-actions#running-dialyzer-checks-with-plt-cache)

## 終わりに/所感

Dialyzer/Dialyxirはさくっと導入できる静的解析ツールとしてかなり大きな武器になることを理解していただけたでしょうか。

個人的には、動的型付けオンリーで開発できるプロダクトの規模にはアーキテクチャでうまく境界を引きつつ開発したとしても、限界があると考えています。そのため、新しいElixir(主に大規模になることが予想されるPhoenix)のプロジェクトにおいては、**最初から**Dialyzer/Dialyxirの導入を積極的に考えるべきです。

皆さんもDialyzerを使って良き静的解析ライフを！
