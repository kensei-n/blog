---
title: "アカツキの夏インターンに参加してRailsのログ配信改善に取り組んだ話"
date: 2020-10-04T22:37:54+09:00
description: "Akatsuki Summer Internship 2020に参加してきました"
draft: false
author:
 - "さんぽし"
tags:
 - "ログ配信"
 - "fluentd"
 - "Rails"
 - "Ruby"
categories:
 - "experience"
 - "internship"
---

こんにちわ

9/7 ~ 9/25の期間でアカツキの**Akatsuki Summer Internship 2020**に参加してきました

この記事ではインターン中に取り組んだ内容について紹介したいと思います。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">3週間お世話になりますっ <a href="https://t.co/vGG7733ABi">pic.twitter.com/vGG7733ABi</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1302777972961677312?ref_src=twsrc%5Etfw">September 7, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>


# インターン業務内容

今回のインターンでは「ログ配信周りの改善」を中心とする以下のタスクを行いました。

- 開発環境からログの配信を行えるようにする
- アクセスログの配信方法の改善
- RedashにてAthenaからアクセスログの解析


# 既存のログ配信環境に関して

既存のログ配信の構成は以下のようになっていました

![既存のログ配信環境](/images/posts/akatsuki-summer1.png)


1. appコンテナがアクセスログをアプリケーションログ内に吐く
2. Volumeを通してfluentdがtailする形でアクセスログのみを収集、またKPI分析などの特別な目的で利用する情報は別途直接fluentdに送られる
3. fluentdはログを分類し、アクセスログは直接複数のS3へ、KPIログなどはAggregatorに配信
4. Aggregatorはさらにそれを複数のRDSやS3に対して配信

という流れになっています。

## 開発環境からログの配信

プロジェクトにはローカルに立ち上げることができる開発/検証用の環境が存在しています。
既存ではdocker-composeを利用してapp・MySQL・Redis・memcachedが立ち上がるようになっていました。

![既存のログ配信環境](/images/posts/akatsuki-summer2.png)

※ログ配信に関係のないRedis, memcachedを省略

現状の問題点として、ここにログ配信周りの環境が含まれていないことにより、

- ログの出力に関わる開発を行った際にKPIログなどが行き着く先のRDSの型などの検証ができない
- 今回僕がやるようなfluentd自体を絡めた開発の検証ができない

と言った点がありました

そこで環境にfluentdのコンテナを新たに追加し、アプリケーションから手元のfluentdを通して開発用S3へログを配信する変更を加えました。

ざっくり変更後の検証環境の構成図です

![既存のログ配信環境](/images/posts/akatsuki-summer3.png)

※ログ配信に関係のないRedis, memcachedを省略

また、図にあるように、すでに存在するMySQLにKPIログの記録用のDBを作成し、RDSに投げ込まれるログをこの環境ではMySQLに向けることでRDSを絡めた開発の検証にも対応しました。

ちなみに、S3へのUploadを行う際の認証は[shared_credentials](https://github.com/fluent/fluent-plugin-s3#shared_credentials)のオプションを利用し、手元の`~/.aws/credentials`をコンテナ内にマウントすることで行いました。

## アクセスログの配信方法の改善

アクセスログの既存の配信方法は

- アプリケーションコンテナがファイルにアクセスログを吐く
- volumeを通してfluentdコンテナがtailする
- fluentdでアクセスログのみをうまくgrepして抽出し、S3などに配信する

と言った仕組みになっています。

これによる問題点として以下のような点があります。

- 同時に膨大な数のアプリケーションコンテナが同一のログファイルに書き込むためなのかごく稀にログが壊れている
- fluentdにてアプリケーションログからアクセスログのみをgrepするのが非効率 and 稀に不正確

改善策としてはシンプルにforwardしているfluentdに対してKPIログなどとは別のポートを通して直接ログを送りつける形に変更しました。

以下変更後の構成図です

![既存のログ配信環境](/images/posts/akatsuki-summer4.png)

既存のアクセスログの出力にはlogrageを利用していました

[![roidrage/lograge - GitHub](https://gh-card.dev/repos/roidrage/lograge.svg)](https://github.com/roidrage/lograge)


アクセスログに求められる要件は以下の通りです

- 既存のlogrageが出しているログの内容はそのまま欲しい
- アプリケーションログファイルへのアクセスログの出力は残しておきたい
- 500が帰った際などのexceptionなど追加で欲しい情報がある。また、POSTパラメータをJSONシリアライズしたいなど、logrageの内容から少しカスタマイズをかけたい

logrageのloggerとしてfluentdへの出力を行う`act-fluent-logger-rails`などのloggerを登録するというのがシンプルな方法だったのですが、logrageのloggerは複数設定できず、アプリケーションログファイルに残しつつfluentdへlogを出力するという要件を満たせませんでした

[![actindi/act-fluent-logger-rails - GitHub](https://gh-card.dev/repos/actindi/act-fluent-logger-rails.svg)](https://github.com/actindi/act-fluent-logger-rails)

そのため、logrageはそのままアプリケーションログへの出力を担当させておき、上記の要件をみたすログをfluentdへと送る部分の開発を行いました

この開発には以下のActive Support::Notificationsを利用しました

> Active SupportはRailsのコア機能のひとつであり、Ruby言語の拡張、ユーティリティなどを提供するものです。Active Supportに含まれているInstrumentation APIは、Rubyコードで発生する特定の動作の計測に利用できます。

>イベントは簡単にサブスクライブできます。ActiveSupport::Notifications.subscribeをブロック付きで 記述すれば、すべての通知をリッスンできます。

[Active Support の Instrumentation 機能 - 13 イベントのサブスクライブ](https://railsguides.jp/active_support_instrumentation.html#%E3%82%A4%E3%83%99%E3%83%B3%E3%83%88%E3%81%AE%E3%82%B5%E3%83%96%E3%82%B9%E3%82%AF%E3%83%A9%E3%82%A4%E3%83%96)


今回は[process_action.action_controller](https://railsguides.jp/active_support_instrumentation.html#process-action-action-controller)をサブスクライブすることでcontrollerの動作の通知を受け取ります。

通知を受けてActiveSupport::Notificationsから渡される情報からログを作成し、公式が出している`fluent-logger-ruby`を利用して、fluentdへログを送りました。

[![fluent/fluent-logger-ruby - GitHub](https://gh-card.dev/repos/fluent/fluent-logger-ruby.svg)](https://github.com/fluent/fluent-logger-ruby)

この方式をとることで、lograge相当のログの情報を残しつつ、ログ内容の改変や追加などを行うことができました。

## Redashにてアクセスログの解析

Redashを用いてAthenaからアクセスログの解析を行いました。

Redashはデータ視覚化を行うことのできるサービスでAthenaや BigQueryなどなどのデータにアクセスし、グラフや表などの形で非エンジニアの方も閲覧しやすい形にまとめることができます。

[![getredash/redash - GitHub](https://gh-card.dev/repos/getredash/redash.svg)](https://github.com/getredash/redash)


- 指定したユーザー・日付のアクセスログを時間順に表示する
- 指定した日付のAPI(path)ごとの呼び出し回数の統計を表示する。グラフで可視化してみる
- 指定した日付の例外が発生しているアクセスログを時間順に最大1000件まで表示
- 上記例外が発生した1日のAPIごとの統計をとる

などのクエリを追加しました。

# 苦労した点
## fluentd分からん

頑張りました。

割とシンプルなので助かりました

## Rails分からん

Railsを扱った軽い経験は一応ありましたが、最終的に使用したActive Support::Notificationsは存在すらしらず、かなり試行錯誤していました。

ちなみに具体的に他に検討した案&没理由は以下の通りです。

<b>・logrageのcustom_options内で無理やりfluentdにログを飛ばす</b>
→トリッキーなので却下

<b>・ApplicationControllerのbefore_actionにログの出力を行う関数を挟む</b>
→リクエストに対するレスポンス内容などのリクエスト内容以外の情報が取得できず却下。
　また、レスポンス内容は別で出力！とかにしても複数コンテナが書き込むログの中でどのリクエストとレスポンスが紐づくかわからなくなるのでそれも却下


# 終わりに

今回はシルバーウィークを挟んで3週間という期間でしたが、ログ周辺のシステムを広く触る経験ができたのはとても良い経験でした。ログ配信周りは今まで開発の経験も知見もなく、あまり個人開発では手が回らないような部分なのでとても貴重な経験になったと感じています。

3週間お世話になりました！！！
