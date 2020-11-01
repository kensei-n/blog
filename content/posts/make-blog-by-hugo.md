---
title: "Hugoでさくっと自作ブログを作った"
date: 2020-09-28T22:37:54+09:00
draft: false
author:
 - "さんぽし"
tags:
 - "Hugo"
categories:
 - "development"
---

## はじめに

こんにちは。
前々からやりたいと思っていた自作ブログへの乗り換えをついにやりました。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">僕も可愛い自作ブログが欲しい…</p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1310500432070864896?ref_src=twsrc%5Etfw">September 28, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

これまで僕は、
- 技術系: Qiita
- インターン記: はてなブログ

という使い分けをしていましたが、それぞれ以下の理由などから、乗り換えたいと前々から考えていました。

#### Qiita

- コミュニティが盛り下がってきている気がする(個人的感覚)(トレンドの LGTM の数を見て明らかに一時期よりも少ない数の記事のものが上がるようになっている)

#### はてなブログ

- 文字数がすごく多くなってくると保存 and プレビューに時間がかかる
- というかそもそもプレビューで画面を切り替えないといけないのがちょいめんどくさい(Qiita みたいに隣に置いておいてくれればいいのに)

あたりです。

まあ、これらはきっかけにすぎず僕が自作ブログ欲しいなぁと前々から思っていたのが一番大きいです。

## Hugoで作る自作ブログ

このブログは Hugo で作成されています。リポジトリは↓です。

[![sanposhiho/blog - GitHub](https://gh-card.dev/repos/sanposhiho/blog.svg)](https://github.com/sanposhiho/blog)

僕はフロントエンドも💩ですしデザインセンスも💩なので、[Hugoのテーマ](https://themes.gohugo.io/)の中から良さげのものをそのまま拝借しました。

このテーマ、結構可愛くないですか？？かなり気に入っています。

上の水滴マークからテーマも色々変更できるので試してみてください。

Netlify から配信しているので、**記事を書いて push すれば更新される**という楽々仕様です。

ついでにムームードメインで念願(？)の `sanposhiho.com` を取得しました。

### OGP生成

OGP の生成には[Ladicle/tcardgen](https://github.com/Ladicle/tcardgen)を使用しています。

[![Ladicle/tcardgen - GitHub](https://gh-card.dev/repos/Ladicle/tcardgen.svg)](https://github.com/Ladicle/tcardgen)

これを用いて以下のコマンドをデプロイ前に打って OGP を生成しています。

```shell
git diff --name-only HEAD\^ content/posts  |\
xargs tcardgen -o static/tcard -f assets/fonts/kinto-sans -t assets/ogp_template.png
```

これによってその時に commit した記事の OGP のみが生成されます。
便利ですね〜✨

また、テーマの `partials/head/meta.html` を上書きして、生成される画像を OGP として認識するように設定する必要があります。

## 乗り換えにあたって

はてなブログからはすごく頑張って記事をコピペしてきました。

Qiita からの移行には[qiitaexporter](https://github.com/tenntenn/qiitaexporter)を使用しました。

[![tenntenn/qiitaexporter - GitHub](https://gh-card.dev/repos/tenntenn/qiitaexporter.svg)](https://github.com/tenntenn/qiitaexporter)

## 終わりに

これを機に Qiita とはてなブログは引退します。これまでそちらを読んでくださっていた方ありがとうございました。

やっと自作ブログライフが始められてすごく清々しい気分です。Hugo で作ると**ものの数時間**で作成が終わるので皆さんもどうでしょうか？
