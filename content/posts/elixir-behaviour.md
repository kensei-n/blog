---
title: "ElixirでBehaviourを使用してDIPを実現する基礎知識"
date: 2020-11-07T13:06:46+09:00
author:
 - "さんぽし"
tags:
 - "Elixir"
 - "Phoenix"
categories:
 - "development"
---

こんばんは

Elixirは他の言語でいうところのinterfaceと似たような機能として、behaviourという機能を持っています
[Typespecs and behaviours - elixir Getting Started](https://elixir-lang.org/getting-started/typespecs-and-behaviours.html#behaviours)
[ビヘイビア - Elixir School](https://elixirschool.com/ja/lessons/advanced/behaviours/)

Elixirは動的型付け言語ではありますが、以下のように型を扱うことも可能なわけです。
[Typespecs - Elixir](https://hexdocs.pm/elixir/typespecs.html)

この記事ではBahaviourはそもそも何が嬉しいのか、どういう目的で用いるのかと言ったことから、実際の実装のサンプルまでを紹介したいと思います。
(**基礎**知識なので、使用経験のある方は、「はいはい分かる分かる」という感じで読んで貰えれば思います)

## Behaviour何が嬉しいの？
Behaviourは結局何が嬉しいのでしょうか

前述のElixir Schoolの説明が一番詳しくてわかりやすいですね.
> - 実装しなければならない関数一式を定義すること
> - その関数一式が実際に実装されているかチェックすること

また、もう一つ大きなメリットがあります。

上位のモジュールが下位のモジュールに依存することを防ぐことができるということです。
いわゆる、依存性逆転の原則( The Dependency Inversion Principle)、SOLID原則でいうところのDですね。

これに関しては検索トップに出てくる以下の記事がわかりやすいです
[依存関係逆転の原則の重要性について](https://medium.com/eureka-engineering/go-dependency-inversion-principle-8ffaf7854a55)

> 上位のモジュールは下位のモジュールに依存してはならない。どちらのモジュールも「抽象」に依存すべきである 「抽象」は実装の詳細に依存してはならない。実装の詳細が「抽象」に依存すべきである

この中で出てきている「抽象」がBehaviourです。

下位のモジュールはBehaviourに沿って実装を行い、そして上位のモジュールはBehaviourが満たされていることを前提にして下位モジュールの使用を行います。

「下位のモジュールを直接使用してたら結局依存してるんじゃないか」となりますが、これから紹介する方法ではconfigにてDI(依存性の注入)を行い、環境変数経由で上位モジュールから使用モジュールを参照することで、「Behaviourが満たされていることを前提に下位モジュールの使用を行う(= Behaviourに依存する)」と言ったことを実現できます。

その他、`config/test.exs`にてmockを代わりにDIすることでtestでのみmockを利用できたりするメリットがあります。詳しい話は以下の5年前のJoséの記事に記載があります
[Mocks and explicit contracts](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/)

この記事にもありますが、こう言ったモックの使い方に便利なライブラリとしてというものがあります。moxに関しては次の記事で取り上げます。

[![dashbitco/mox - GitHub](https://gh-card.dev/repos/dashbitco/mox.svg)](https://github.com/dashbitco/mox)

### Behaviourを定義する

今回は以下のようにUserに関するDB操作を一つのBehaviourにまとめます

```lib/tsundoku_buster/behaviour/repository/user.ex
defmodule TsundokuBuster.Repository.UserBehaviour do
  alias TsundokuBuster.Schema.User

  @callback list_users() :: [%User{}]
  @callback get_user(id :: String.t()) :: {:ok, %User{}} | {:error, atom()}
  @callback create_user(attrs :: TsundokuBuster.Database.User.attrs()) ::
              {:ok, %User{}} | {:error, %Ecto.Changeset{}}
  @callback update_user(user :: %User{}, attrs :: TsundokuBuster.Database.User.attrs()) ::
              {:ok, %User{}} | {:error, %Ecto.Changeset{}}
  @callback delete_user(user :: %User{}) :: {:ok, %User{}} | {:error, %Ecto.Changeset{}}
  @callback change_user(user :: %User{}, attrs :: TsundokuBuster.Database.User.attrs()) ::
              %Ecto.Changeset{}
end
```

Behaviourでは`@callback`を使用して、関数名や関数の引数/型、返り値として想定される値/型を記述していきます

### モジュールをBehaviourに沿って実装

`@behaviour`や`@impl`を使用してBehaviourに沿ったモジュールを実装します

実装内容はあまり関係ないので適当に読み飛ばしてください

```lib/tsundoku_buster/database/user.ex
defmodule TsundokuBuster.Database.User do
  @moduledoc """
  manage users in Database
  """
  @behaviour TsundokuBuster.Repository.UserBehaviour

  import Ecto.Query, warn: false
  alias TsundokuBuster.Repo

  alias TsundokuBuster.Schema.User

  @type attrs :: %{
          optional(:name) => String.t(),
          optional(:twitter_id) => String.t(),
          optional(:oauth_token) => String.t(),
          optional(:oauth_token_secret) => String.t(),
          optional(:created_at) => DateTime.t(),
          optional(:updated_at) => DateTime.t()
        }

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  @impl TsundokuBuster.Repository.UserBehaviour
  @spec list_users() :: [%User{}]
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  ## Examples

      iex> get_user(123)
      {:ok, %User{}}

      iex> get_user(456)
      {:error, :not_found}

  """
  @impl TsundokuBuster.Repository.UserBehaviour
  @spec get_user(id :: String.t()) :: {:ok, %User{}} | {:error, atom()}
  def get_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @impl TsundokuBuster.Repository.UserBehaviour
  @spec create_user(attrs :: TsundokuBuster.Database.User.attrs()) ::
          {:ok, %User{}} | {:error, %Ecto.Changeset{}}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @impl TsundokuBuster.Repository.UserBehaviour
  @spec update_user(user :: %User{}, attrs :: TsundokuBuster.Database.User.attrs()) ::
          {:ok, %User{}} | {:error, %Ecto.Changeset{}}
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  @impl TsundokuBuster.Repository.UserBehaviour
  @spec delete_user(user :: %User{}) :: {:ok, %User{}} | {:error, %Ecto.Changeset{}}
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  @impl TsundokuBuster.Repository.UserBehaviour
  @spec change_user(user :: %User{}, attrs :: TsundokuBuster.Database.User.attrs()) ::
          %Ecto.Changeset{}
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
```

### ↑のモジュールを使用するモジュールの実装

`@user_repo`や`@twitter_client`を使用して環境変数から使用するモジュールを決定しています
`@user_repo`には先程の`TsundokuBuster.Repository.UserBehaviour`を満たすモジュールがDIされることを期待します
(ちゃんとBehaviourを満たすモジュールがDIされてんの?っていうのは`Dialyzer`を使用すれば担保できるのですが、これもまたいつか別記事で紹介します)
※DI: Dependency Injection(依存性の注入)

これも実装の細かい内容はあまり関係がないので適当に読み飛ばしてください

```lib/tsundoku_buster/usecase/user.ex
defmodule TsundokuBuster.Usecase.User do
  @user_repo Application.get_env(:tsundoku_buster, :user_repo)
  @twitter_client Application.get_env(:tsundoku_buster, :twitter_client)
  alias TsundokuBuster.Schema.User

  @spec get_authorize_url() :: {:ok, String.t()} | {:error, atom()}
  def get_authorize_url() do
    case @twitter_client.request_token() do
      {:ok, token} ->
        token
        |> Map.get(:oauth_token)
        |> @twitter_client.authorize_url()

      {:error, error} ->
        {:error, error}
    end
  end

  @spec create_user_from_twitter(String.t(), String.t()) :: {:ok, %User{}} | {:error, atom()}
  def create_user_from_twitter(oauth_verifier, oauth_token) do
    case @twitter_client.access_token(oauth_verifier, oauth_token) do
      {:ok, creds} ->
        case @twitter_client.user(creds.user_id) do
          {:ok, twitter_user} ->
            case @user_repo.create_user(%{
                   name: twitter_user.name,
                   twitter_id: twitter_user.screen_name,
                   oauth_token: creds.oauth_token,
                   oauth_token_secret: creds.oauth_token_secret,
                   created_at: Timex.now(),
                   updated_at: Timex.now()
                 }) do
              {:ok, user} -> {:ok, user}
              _ -> {:error, :cannot_store_user}
            end

          error ->
            error
        end

      error ->
        error
    end
  end

  @spec get_user(String.t()) :: {:ok, %User{}} | {:error, atom()}
  def get_user(id) do
    @user_repo.get_user(id)
  end

  @spec update_user(String.t()) :: {:ok, %User{}} | {:error, atom()}
  def update_user(id) do
    case @user_repo.get_user(id) do
      {:ok, user} ->
        case @twitter_client.user(user.twitter_id) do
          {:ok, twitter_user} ->
            case @user_repo.update_user(
                   user,
                   %{
                     name: twitter_user.name,
                     twitter_id: twitter_user.screen_name,
                     updated_at: Timex.now()
                   }
                 ) do
              {:ok, user} -> {:ok, user}
              _ -> {:error, :cannot_store_user}
            end

          error ->
            error
        end

      error ->
        error
    end
  end

  @spec delete_user(String.t()) :: {:ok, :no_content} | {:error, atom()}
  def delete_user(id) do
    case @user_repo.get_user(id) do
      {:ok, user} ->
        case @user_repo.delete_user(user) do
          {:ok, _} -> {:ok, :no_content}
          {:error, _} -> {:error, :cannot_delete_user}
        end

      error ->
        error
    end
  end
end
```

### configにてDIする

configにてDIします

```config/config.exs
config :tsundoku_buster,
  twitter_client: ExTwitter,
  user_repo: TsundokuBuster.Database.User
```

これによって実行時に環境変数を通して先程の`usecase/user.ex`にてBehaviourを満たすモジュールが使用されます

## 終わりに

今回はElixirのBehaviourとその利用例を紹介しました。
境界を明確にすることで変更の範囲を抑えることができたりするなど、Behaviourのメリットには多くのものがあります。

この記事が誰かの参考になれば幸いです。
