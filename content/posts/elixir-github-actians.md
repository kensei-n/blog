---
title: "Elixir / PhoenixのリポジトリにGitHub Actiansを用いてlintとtestをかけたい"
date: 2020-10-20T21:11:44+09:00
draft: false
author:
 - "さんぽし"
tags:
 - "Elixir"
 - "Phoenix"
categories:
 - "development"
---

こんばんは、みなさんGitHub Action使ってますか？

この記事はElixir/PhoenixのリポジトリにGitHub Actionを利用して自動でlintとtestが回るように設定したい際のメモになります
例の如くElixirに関する記事が少ないため自分用のメモがてら残しておきます

## 実行したいmixタスク

```
mix test
mix format --check-formatted
```

見ての通りですが、上からtestをするコマンド、formatがかかってるか確認するコマンドになります

Elixirは公式のformatがあるのはすごく良いですよね

このタスク達をPRの作成時、更新時に実行してちゃんとtestが通るかformatがかかってるかを確認することにします

## workflowファイル

```yaml
name: test_and_lint

on:
  pull_request:
    types: [opened, synchronize]
    paths-ignore:
    - 'docs/**'

jobs:
  test_and_lint:
    name: Test-and-Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-elixir@v1
        with:
         otp-version: '23.1.1'
         elixir-version: '1.11.1'
      - uses: actions/cache@v1
        with:
         path: deps
         key: ${{ runner.os }}-mix-${{ hashFiles(format('{0}{1}', github.workspace, '/mix.lock')) }}
         restore-keys: |
           ${{ runner.os }}-mix-
      - name: set up mysql
        run: |
          make run-db-local
          eval "$(cat env.local <(echo) <(declare -x))"
          until mysql -u${DB_USER} -p${DB_PASSWORD} -h${DB_HOST} -P${DB_PORT} -e "SELECT 1"; do sleep 1; done
      - run: mix deps.get
      - run: mix test
      - run: mix format --check-formatted
```

以下を用いてElixirの環境を立ち上げています

[![actions/setup-elixir - GitHub](https://gh-card.dev/repos/actions/setup-elixir.svg)](https://github.com/actions/setup-elixir)

他に特に特殊なことはしていません。基本的には公式のREADMEと同じようなことをしています。
キャッシュを挟んでactionの回る時間を短くしています

また、`make run-db-local`は手元に開発用のmysqlを立てるコマンドです
mysqlを利用していたので開発用のmakeコマンドを再利用しましたが、postgresqlの方は上記の公式のREADMEをそのまま参考にすれば良いと思います

このGitHub Actionを用いているリポジトリは以下なので詳しく見たい方は確認してみたください

[![sanposhiho/nippol-server - GitHub](https://gh-card.dev/repos/sanposhiho/nippol-server.svg)](https://github.com/sanposhiho/nippol-server)
