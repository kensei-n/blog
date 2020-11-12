---
title: "Recruit Internship Summer"
date: 2020-11-08T00:46:45+09:00
draft: true
---

こんにちは

10/5 - 11/13 で**RECRUIT Job for Student 2020 \~Engineer/Data Specialist\~**に参加していました。

[RECRUIT Job for Student 2020 ~Engineer/Data Specialist~](https://engineers.recruit-jinji.jp/event/job-for-student-2020s/)

僕はスタディサプリEnglish SREチームに配属されました。

基本オンラインでの勤務で、僕は週3.5日出社という形でした。途中学校の用事などで抜けたりと、かなり自由に勤務をさせてもらいました。

## 待遇とか

↑のページに詳しく載っていますが、

- 時給2000円
- 交通費/宿泊費
- 技術書補助(上限1万円)
- 食事代

が出ました。
めちゃんめちゃん豪華ですね

オンラインなので交通費/宿泊費？と思われるかもしれませんが、希望する人は色々制限付きですが数日出社日を設けることができ、その際の費用と言った感じです。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">2日間現地出社マンでした <a href="https://t.co/RoggMQUoMH">pic.twitter.com/RoggMQUoMH</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1317050059528179712?ref_src=twsrc%5Etfw">October 16, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

スタディサプリEnglishは新しめのオフィスですごくきれいでした。

また、記載がありませんが、技術書補助と一緒に在宅勤務補助(上限2万円)ももらう事ができました


<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">書籍購入補助で買ってもらった〜〜 <a href="https://t.co/noFwJWd2X2">pic.twitter.com/noFwJWd2X2</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1305340470466281472?ref_src=twsrc%5Etfw">September 14, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

という事で積読補助はこの二冊を


<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">在宅！！！補助！！！！！！！ <a href="https://t.co/PdkhtyM99w">pic.twitter.com/PdkhtyM99w</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1305315089327689728?ref_src=twsrc%5Etfw">September 14, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

在宅補助はMagic TrackPadを買ってもらいました🙏

またまた、食事代に関しては、ランチ代が毎勤務分配られたので、近所のUberEATSを食い漁っていました。

## やった事

Jenkins/ArgoCDのデプロイ通知の改善を行いました。

現状はArgoCDのsyncの完了の通知を出しておらず、ArgoCDのダッシュボードを見に行かないと完了しているかわからない、syncの失敗にもすぐに気がつけない、と言った問題がありました。

ArgoCD Resource Hooksと言うPreSync(syncの実行前)やPostSync(sync完了)、SyncFail(sync失敗)などのsyncに関するイベントを検知してJobを実行することができる機能を用いて、Slack通知を実現しました。
Resource Hooksの公式の例としてもSlackへの通知を送るサンプルが記載されています。

[ArgoCD - Resource Hooks](https://argoproj.github.io/argo-cd/user-guide/resource_hooks/)

実行されるimageではArgoCDのApplication Controllerを利用してArgoCDのリソースの状態を取得しています。現在syncされた(もしくはsyncに失敗した)リソースのrevisionを取得することや、今までのsyncの履歴なども取得することができます。そのためリソースの状態に応じたかなり自由度の高い動作をさせることが可能になります。

[ArgoCD - Application Controller](https://argoproj.github.io/argo-cd/operator-manual/architecture/#application-controller)

今回はrevisionからGitHubAPIを通してAuthorを取得し、SlackAPIを通してAuthorに対するメンションを行うという流れで通知を行いました

## つまりポイント

この記事の内容で1週間近く進捗が無でした

[Kustomizeを利用しているプロジェクトでArgoCD Resource Hooksを用いて複数リソースで同一Jobを使用したいときに詰まるポイント](/posts/argocd-kustomize-bug/)

## 終わりに

今回1.5ヶ月/週3.5日と言う期間で学校と並列してかなり自由に勤務させていただきとても助かりました🙏
かなりモダンなCI/CD環境の整っている中で多くのことを学べました。短い間でしたがお世話になりました！！

以下で部署の方の記事が出ているので気になる人はチェックしてみてください👀

- [スタディサプリENGLISHの基盤をECSからEKSに移行しました](https://tech.recruit-mp.co.jp/infrastructure/post-20706/)
- [Amazon EKSでのArgoCDを使ったGitOps CD](https://tech.recruit-mp.co.jp/infrastructure/gitops-cd-by-using-argo-cd-at-eks/)
