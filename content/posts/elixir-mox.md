---
title: "【Elixir】moxを使用してmock用いたテストを書く"
date: 2020-11-03T12:55:50+09:00
draft: true
---


5年前のJoséのこの記事、みたことがある人も多いのではないでしょうか

[Mocks and explicit contracts](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/)

内容を超意訳すると「テストのために特定のモジュールに対するmockを作っちゃうと結局そのモジュールと密結合になっちゃうよね。behaviourを使ってDIしよう！」っていう話です。今となってはそんなに珍しくない考え方かもしれません。

そして、上記の考えを基にして、behaviourからmockの生成を行うライブラリが**mox**です。
今年の9月にv1.0.0がリリースされた比較的新しいライブラリです。

[![dashbitco/mox - GitHub](https://gh-card.dev/repos/dashbitco/mox.svg)](https://github.com/dashbitco/mox)

今回はそのmoxを使用して、mockを使ったテストを使用するサンプルを紹介します

## Behaviourを使用したモジュールの作成

moxは前述のように[この記事](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/)の思想を基に作成されたライブラリです。

そのためBehaviourを使用したモジュールを作成する必要があります。
(個人的にはこのライブラリを使用する云々関係なく、Behaviourを適宜使用するべきだと思いますが、そういった話はいつか別の記事にします)

Behaviourを使用したモジュールの作成に関しては以下の別記事を参照してください。
今回のサンプルでは以下の記事で紹介しているモジュールをそのまま使用しています

[ElixirでBehaviourを使用した実装を行うのに必要な基礎知識](/posts/elixir-behaviour)


## moxの依存の追加

```mix.exs
  defp deps do
    [
#..(略)
      {:mox, "~> 1.0", only: :test}  #add
    ]
  end
```

## moxkの生成の設定

`Mox.defmock`を使用してmockを生成します

```test/test_helper.exs
Mox.defmock(ExTwitterMock, for: ExTwitter.Behaviour)
Mox.defmock(TsundokuBuster.Repository.UserMock, for: TsundokuBuster.Repository.UserBehaviour)
```

Behaviourを指定することでそれを基にしたmockが生成されます

当たり前ですが、[ExTwitter](https://github.com/parroty/extwitter/blob/master/lib/extwitter/behaviour.ex)など外部のライブラリのBehaviourのモックを使用することも可能です

## configでDI

test環境で使用するmoduleをmockに指定します

```config/test.exs
config :tsundoku_buster,
  twitter_client: ExTwitterMock,
  user_repo: TsundokuBuster.Repository.UserMock
```

## test書いてみる

```test/tsundoku_buster/usecase/user_test.exs
defmodule TsundokuBuster.Usecase.UserTest do
  alias TsundokuBuster.Usecase.User, as: UserUsecase
  alias TsundokuBuster.Schema.User
  alias TsundokuBuster.Repository.UserMock
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  describe "get_authorize_url/0" do
    test "APIへのリクエストが全て成功した場合authorize_urlが返される" do
      ExTwitterMock
      |> expect(:request_token, fn ->
        {:ok, %ExTwitter.Model.RequestToken{oauth_token: "token"}}
      end)
      |> expect(:authorize_url, fn "token" -> {:ok, "url"} end)

      assert UserUsecase.get_authorize_url() == {:ok, "url"}
    end

    test "APIへのリクエストに何かしらのエラーが起きた際にはエラーがかえる" do
      ExTwitterMock
      |> expect(:request_token, fn -> {:error, :reason} end)

      assert UserUsecase.get_authorize_url() == {:error, :reason}
    end
  end
end
```

かなりシンプルに記述できますね。expectで呼び出しが期待される関数を列挙していき、それに基づいたテストが行われます。
expectしているのに呼び出されていない関数があれば以下のようなエラーでテストが失敗します

```
* expected ExTwitterMock.access_token/2 to be invoked once but it was invoked 0 times
```

## 
