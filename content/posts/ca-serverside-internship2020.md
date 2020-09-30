---
title: "CyberAgentの2daysインターンでパフォーマンスチューニングを完全に理解した"
date: 2020-06-07T22:37:54+09:00
description: パフォーマンスチューニングなんて簡単じゃん？(←こいつは3ヶ月後のISUCON予選でボロボロに負けます)
draft: false
author:
 - "さんぽし"
tags:
 - "internship"
categories:
 - "experience"
---

こんばんは

6/6 - 6/7 で CyberAgent の 2days サーバーサイド向け開発型インターンシップに参加していました。

2 日間オンラインでパフォーマンスチューニングを実際に行い、その後解説をもらうという流れでした。

この記事ではパフォーマンスチューニング何も分からんの僕がアプリケーションに対してどのような修正を入れて行ったのかをざくっと時系列で紹介していきます

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">2days サーバーサイド向け 開発型インターンシップ ONLINE🎉<br><br>が間もなく開始となります！<br>インターンとしては初のオンライン開催💻<a href="https://twitter.com/hashtag/catechchallenge?src=hash&amp;ref_src=twsrc%5Etfw">#catechchallenge</a> <br>にて本インターンの情報を発信していきますので、ぜひご確認ください💪 <a href="https://t.co/uF3U1yobTX">pic.twitter.com/uF3U1yobTX</a></p>&mdash; 【公式】サイバーエージェント新卒エンジニア採用 (@ca_tec_des) <a href="https://twitter.com/ca_tec_des/status/1269081387396509696?ref_src=twsrc%5Etfw">June 6, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## ツール色々いれる

まず事前にまとめておいた↓の gist を基に

- alp
- pprof
- pt-query-digest

を導入しました。

[Cheat Sheet on Performance Tuning / GitHub Gist](https://gist.github.com/sanposhiho/1a8a9e93ed9eabc5fea3145dbfb210a0)

一瞬で導入できたので gist にまとめといてよかったという気持ちになりました。
ついでにソースコードを Git 管理して、Nginx とかの設定ファイルは手元にバックアップしました。

vimmer なのでファイル編集とかに困らなかったのは楽でした

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">対よろです<a href="https://twitter.com/hashtag/catechchallennge?src=hash&amp;ref_src=twsrc%5Etfw">#catechchallennge</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1269076634935545857?ref_src=twsrc%5Etfw">June 6, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## pprof見てみる

なんか getArticleTagNames という関数が遅そうってことが判明
見てみると明らかに N+1 だったので修正を入れました。

が、点数に変化なし。

ちなみに初期スコアは 750 点くらいです

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">N+1を一つつぶしたのにスコアが1も上がらないのはなぜ</p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1269105622936510465?ref_src=twsrc%5Etfw">June 6, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## DBから画像バイナリを抜く

DB に画像のバイナリが直で突っ込まれていたので、修正しました。

具体的には

- photo_binary に挿入しようとしている部分を代わりに local に保存するように変更
- デフォルトの画像を落として、わざわざ decode しないようにする
- Nginx で配信するように変更

をしました。

が、またも点数に変化なし。泣きました


## スロークエリを見る
スロークエリを pt-query-digest で解析すると、index 貼ってないのにわちゃわちゃ SELECT してる部分が色々あったので適当に良さげな index を貼りました。
スコアが一気に 1500 くらいになりました。

## MYSQLとかNginxの設定をいじる
ネットに「こうするといいよ！」みたく転がってる設定をいれるが効果なし
ちなみにこの辺りで 2 位に転落しました

## 初日の中間解説でindexの解説がされる
この解説でみんなが index を張り出したが意外と抜かれなかったので N+1 改善とかが後になって効いてきてるのかもーとか思ってました

## deferをなくす
defer をなくすといいらしいとどこかで見た気がしたので全部の defer をなくしました。

効果がなかった上に非常にめんどくさくて悲しくなりました。

## Template周りの改善
以下の記事を参考に template を毎回 Parse していたので修正しました。

[GoでISUCONを戦う話 / templateの使い方](https://gist.github.com/catatsuy/e627aaf118fbe001f2e7c665fda48146#template%E3%81%AE%E4%BD%BF%E3%81%84%E6%96%B9)

20 点くらい上がりました。

##  getLoginUsers改善
getLoginUsers という Login している User を取得する関数が遅かったです
Redis でややこしい LoginUser の管理をしているのが原因だったので、"login_users"という key でセット型で LoginUser を管理するように変更

200 点くらい上がりました

## いいね数をRedisに載せる
いいね数の取得のクエリが時間がかかってそうだったのでいいね数を Redis で管理

具体的に

- どの記事に誰がいいねしているかというのを"iine_{articleID}"という key のセット型で Redis に載せる
- GetInitialize で DB 内に既に入っているいいねを Redis に載せるように修正
- PostIine で DB と共に Redis にもいいねの情報をいれる
- getArticleIineUsers と getIineCount で DB からではなく Redis からいいねの情報を取得

の変更を加えました。

200 点くらい上がってこれで 1950 点くらいになりました。

## getArticleTagNames再改善

N+1 を直した getArticleTagNames がいまいちまだ遅いので sql/database ではなく gorp を導入して一気に複数列を取得するように変更しましたが効果無し。

また最終時間ギリギリに Redis に載せようとしましたが時間が足りず…

## getPopularArticlesが遅い
getPopularArticles は直近一定期間でいいね数が多かった記事を取得する関数です。
これが遅くて初日から何度か修正を試みたのですが、最後まで修正できませんでした。

まずは SQL を改善することを Table の構造変更も含めて検討しました。
しかし、直近一定期間のいいね数を Table に格納するとなるとかなりの頻度で定期的に更新をかけなければいけないので諦めました。
（ベンチが走るのは一瞬なのでこれでもいけたかもとは思いましたが…）

次に、先ほどのように Redis に載せることを検討しました。
しかし、

- Redis からいいね取得→直近の物だけに絞る→記事ごとにいいね数を数える→いいね数上位 5 件を取得
- 定期的に Redis を更新

がかなり煩雑すぎる処理になるなと思い、諦めました。

あとで聞いた話だと優勝の hpp くんは Redis でやったってことなのでほへぇってなりました。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">Redisにsorted setなんてあったのか！</p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1269541055742898176?ref_src=twsrc%5Etfw">June 7, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## 反省点

- defer や template 改善などのプロファイルから見えてない部分の改善は優先度を下げればよかった（実際そこまで効果が大きくなかった）
- Nginx、MYSQL の勉強不足で設定まわりを弄れなかった（特に Nginx）

## 終わりに

最終結果は 1950 点ほどが最大値でした。順位は最後 2 時間見えないようになっていたので分かりませんが、20 人中 4-7 位辺りだと思います。（多分…）

パフォーマンスチューニングは本当に全然経験がなく、今回ガッツリ 2 日間の開発-解説で本当に大きく成長できたな〜と思いました。

とても楽しい 2 日間でした、ありがとうございました！！
