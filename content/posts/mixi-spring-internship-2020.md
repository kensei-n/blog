---
title: "Dive into mixi GROUP 2020 (春) に参加してきた"
date: 2020-04-17T22:37:54+09:00
description: Kubernetes初挑戦の巻
draft: false
author:
 - "さんぽし"
tags:
 - "internship"
categories:
 - "experience"
---

こんにちは

3/16 - 4/17 で mixi の長期就業型インターン Dive into mixi GROUP 2020 に参加してきました。

僕は今回 Unlim というスポーツギフティングのサービスを開発している部署に配属されました。（ここでは僕の大好きな Elixir が使用されています！珍しい！）

[Unlim - Sports Gifting](https://unlim.team/)

## 選考〜インターン参加まで
選考の流れは数回人事の方と面接、その後エンジニアの方とも面接して、最後に実際に配属（予定）のチームの方と最終面接という流れでした。
個人的にはコーディングテストがなくて助かりました。笑


僕の場合インターンの最終面接に通ったのが 3 月の頭でした。

そこで最終面接かつ面談のような形で Unlim のチームの方と実際にお話させていただいて、実際にインターンでどういったことに取り組むかと言うことをざっくりと聞きました。

そこで Elixir でバックエンドの開発というよりは Docker や Kubernetes などを使った開発を任せることになると思うという趣旨のお話を頂きました。

その当時の僕は「Docker って何？」「Kubernetes ってもっと何？？？」と言う状態でした。

3/16 からインターン開始ということでかなり時間のない中でしたが（2 週間）、事前課題ということでざっくり Docker と Kubernetes を minikube 上で動かして見て欲しいと言われていたのでとりあえず動かしてみつつ、Qiita の記事にまとめたりしました。
(追記: 現在はこのブログに記事を移動)

[初心者が流れで学ぶDocker/Kubernetes超入門](/posts/2020-03-08-qiita-fc8082f3d303c04cca2e/)

この記事を書き終わった時点で 1 週間ほど余っていたので、これまで逃げてきた AWS のお勉強に勤めました。Qiita に出てくるような AWS の記事を色々読んで AWS 上のどのサービスでどのようなことができるのかというのを本当にざっくり勉強しました。


## インターンでやらせてもらったこと
はじめにメンターの社員さんとインターンの最終的な目標となるタスクを設定しました。

僕の最終目標として定めたタスクは
**master ブランチに PR を投げたときに自動で環境が作成されるデプロイフローの作成**
です。

現在 Unlim チームでは

- master にマージされる前に staging/unstable ブランチに一旦マージしてみる。
- staging/unstable にマージされると CircleCI が回って staging/unstable 環境のデプロイが実行される。
- staging/unstable 環境で OK そうなら master にマージ

と言う流れで開発が行われています。

これを master に PR 投げただけで CircleCI が回りデプロイされるような環境に変更しようと言うのが今回の僕の最終タスクでした。

はじめは CircleCI の回るタイミングを変えるだけじゃね？みたいなことを思っていましたが、デプロイは単純に `kubectl apply` を打っているだけではなく、AWS 上のリソースなどもどのように作成/管理するかという部分などもあり、とても面白いタスクでした。

使用した技術としては、Docker, Kubernetes, Helm, CircleCI（,ECR, EKS）あたりです。

詳細は別記事としてまとめたので興味のある方はぜひ読んでみてください！

[ブランチのpushで環境を動的に作成する開発環境を作った話](/posts/2020-04-13-qiita-c2ca5ebc56ade9b79b33/)



## インターンの途中でコロナが猛威を振るう
インターンの 2 週間目を終えたとき小池さんが「東京やばいっす、外出まじやめてね」という会見をしたこともあって、インターン生含めて（基本）リモートの勤務に変更されました。

[新型コロナウイルス感染拡大に伴う当社勤務体制の変更について](https://mixi.co.jp/press/2020/0327/3923/index.html)

個人的に文章を書くのがすごく苦手で冗長にタラタラ書いてしまう癖があるので、Slack などのコミュニケーションだけになるという部分は不安もありましたが、1 日に 2 回ほど入れてもらったオンラインでの 1on1 などで心配することはなかったです。

~~というか後でよく考えたらいつも開発する時は爆音イヤホンで周りの音をシャットアウトするのでそこまで頻繁に直接コミュニケーション取ってたわけでも無いなとも思ったり~~

また、リモート勤務の開始に伴って、**契約社員やアルバイトを含む全ての社員に hoge 万円の機材購入支援が行われました。**

小池さんの会見があった 2 日後にもう機材購入支援の事がアナウンスされ、会社としてエンジニアの働きやすさ(=生産性につながる)を重視するという姿勢が見て取れてすごいなっと感じました。

僕も遠慮なくディスプレイを購入しました。京都の下宿にディスプレイがなく、そういう面でもとても嬉しかったです。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">来週からリモートになる代わりに、リモートワークの補助金がインターン生にも出るらしくて、いやいやすいません。と思いながらも制限ギリッギリまで使おうとしているの図 <a href="https://t.co/RtLInFSfQD">pic.twitter.com/RtLInFSfQD</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1243505596738895872?ref_src=twsrc%5Etfw">March 27, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

これからの開発にめちゃめちゃ役立てていきます…！！！💪


## 終わりに
Docker、Kubernetes 何も知らない状態から本当に多くのことを学ぶことができました！

具体的には

- Docker, Kubernetes とはなんぞや
- CiecleCI、CI/CD とはなんぞや

と言った基本的な部分から

- どのように manifest, リソースが管理されるか（Helm, ArgoCD）
- アプリケーションがどのようにインフラ的に組み合わさって動作しているか

などまで本当に幅広く濃い内容を学ぶことができました。

最高のインターンでした！！
一ヶ月の間お世話になりました！！！

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">このロケーションで作業出来るの最高か？？ <a href="https://t.co/I7lBJnWwwH">pic.twitter.com/I7lBJnWwwH</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1240830793032720384?ref_src=twsrc%5Etfw">March 20, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
