---
title: "mixiの夏インターンに参加してフルスタックエンジニア()をしてきた"
date: 2020-08-31T22:37:54+09:00
description: Vue分からん芸人
draft: false
author:
 - "さんぽし"
tags:
 - "internship"
categories:
 - "experience"
---

こんばんわ

[春に引き続き](/posts/mixi-spring-internship-2020/)、8/3 - 8/28 の 4 週間で mixi の長期就業型インターン Dive into mixi GROUP 2020 に参加してきました。

今回はインフラ室という社内のインフラに広く携わるような部署に配属されました。

これはどんなことしたん？的なインターン記になります

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">1ヶ月よろしくお願いします！！！！ <a href="https://t.co/Byb9kWiLrb">pic.twitter.com/Byb9kWiLrb</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1290091976541364224?ref_src=twsrc%5Etfw">August 3, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## インターン全般に関して

インターンは初めの 3 週間がオフライン、最後の 1 週間がリモートといった形でした。

某友人が一緒の時期にミクシィでインターンだったので毎日一緒に飯を食ってました。（孤独じゃなくてよかった

![オフィスからの景色](/images/posts/mixi-summer-internship-2020.jpg)

## ざっくり業務内容

今回は TIPSTAR という mixi の新しいサービスに関わらせて頂きました。

[TIPSTAR | みんなで参戦！のっかりベッティング『TIPSTAR』](https://tipstar.com/top?inviteCode=7a23e404-d803-44ab-a246-13232f1a6b2f)
（↑こっそり招待 URL）

TIPSTAR では毎日競輪の映像をリアルタイムで編集し、生配信を行なっています。そこでは一部機械学習を用い競輪の映像の編集がなされています。

通常機械学習に関して、チーム内での役割の差によって運用が属人化してしまうなどの問題が生じます。

このような問題を解決する機械学習システムを構築・運用していく枠組みが必要とされ、そう言ったものを解決する取り組み・思想は**MLOps**と呼ばれます

今回のインターンではそんな MLOps を実現しようという大きな目標の元、機械学習周りの管理アプリケーションの開発を担当しました。

## 実装したもの達

### 前処理Cloud Run

まずデータの前処理・管理を自動化することを目的に、Cloud Run による前処理を実装しました。

レースの動画が GCS に Upload されるので、そのイベントを Pub/Sub を通して CloudRun で受け取って、コマ画像と指定秒数毎の音声データに変換して規則に沿ったディレクトリ構成で GCS に格納し直します。

[Cloud Storage の Pub/Sub 通知](https://cloud.google.com/storage/docs/pubsub-notifications?hl=ja)

これらのデータたち 1 つ 1 つが学習のために実際に用いられるデータとなります。

この実装によって、今まで担当の人が

- 動画から ffmpeg でコマ画像、指定秒数ごとの音声データなどを抽出
- 手元に抽出したデータを保存

としていた物を自動化/管理化しました


### データ管理君


また、そうして生成されたデータの場所やラベルなどを一限管理するためのアプリケーションを作成しました。

具体的には

- レース情報の管理/検索
- Cloud Run で生成されたデータの格納場所管理/検索
- データに対するラベル付け

などを行います。

- フロントエンド: TypeScript/ Vue / Nuxt
- バックエンド: Golang / echo

を使用して開発しました。


僕はこれまで「React ちょっとだけ触ったことある」レベルの人間だったのでちゃんとしたフロントエンドの開発はほぼ初めてでした。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">Vueのあまりのわからなさに絶望している人の鳴き声「ｳﾞｴ」</p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1294973265895501825?ref_src=twsrc%5Etfw">August 16, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

基本的にはなんかかんか Vuetify の肩に乗ることで頑張りました。

フロントエンドのアーキテクチャとかはよくわかりませんが、基本的に初心者はオレオレ実装をしないほうがいいだろうと思い、Nuxt の意をそれないように(?)実装を行なっていきました。

また、アトミックデザイン的な component の切り分け方を意識していたような気がします（自信は全くない

デザイン的には**音声、コマ画像両方一括の操作ができる**ことだけを意識して UI を実装しました。（それ以上のことを考えても実装力が皆無なので…

また、バックエンドは基本的に Relaym と同様のアーキテクチャに設計しました。

- 開発全体を通して時間がなかった（1 ヶ月で Cloud Run 前処理実装 ~ フロント/バックエンド/インフラに載せるまでをやる）ので慣れている構成で開発をしたかった
- レビューのない個人開発状態であり、インターンを終えた引き継ぎ後も同様であると考えられるため、テストで動作を保証するために**テストの文化/環境**を立ち上げの段階で整えておきたかった

特に後者が大きな理由です。mockgen や GitHub Actions などを含めテストの環境を充実させることを意識して開発を行いました。

引き継ぎ後に関数の意をテストを見ることでわかるようにという意図もあります。いわゆるテストがドキュメント代わりといった状態を目指しました。（ちゃんとドキュメントも書いたよ

[![camphor-/relaym-server - GitHub](https://gh-card.dev/repos/camphor-/relaym-server.svg)](https://github.com/camphor-/relaym-server)

## 学んだこと/感想

今回は完全に 1 からフロントエンドからバックエンド、それらを載せるインフラ構成を自分で考え、開発しました。こういった"1 からアプリケーションの構成を全て考える経験"をこれまで持っておらず、とても刺激的で楽しい 1 ヶ月でした。

僕は基本的にこれまでバックエンドを中心に開発の経験を積んできていて、（AWS はちょっと経験がありますが、）GCP は触ったこと全くなし、フロントエンドに関しては丸っきり初心者！といった感じでした。それを 1 ヶ月という短い期間でそれぞれ濃ゆい濃度で経験できたのはすごく貴重だったと思います。（もちろんやり残した実装はかなり多くありましたが…）

部署のみなさん一ヶ月間お世話になりました！！！！！！

![一ヶ月間ありがとうございました](/images/posts/mixi-summer-internship-20202.png)
