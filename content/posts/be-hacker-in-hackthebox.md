---
title: "どぶ素人がHack the BoxでHackerになるまでの道のり"
date: 2020-06-08T22:37:54+09:00
description: みんなHack the Boxやろうぜ!
draft: false
author:
 - "さんぽし"
tags:
 - "penetration testing"
 - "Hack the Box"
categories:
 - "security"
---

こんばんは

1 月頃から始めた Hack the Box でやっとこさ Hacker になりました。

[Hack the Box / sanposhiho](https://www.hackthebox.eu/profile/247307)

記念なので、これまで何してきたかという競プロでいう「色変記事」的なのを雑に書こうかと思います。

Hack the Box 気になってるけど何からやればいいかわからない🤔的な人の参考になればと思います！

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">㊗️Hackerデビュー<a href="https://t.co/mExy3Aoq3g">https://t.co/mExy3Aoq3g</a> <a href="https://t.co/QeeZ2OFO1i">pic.twitter.com/QeeZ2OFO1i</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1269045729911164928?ref_src=twsrc%5Etfw">June 5, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## 1月 - 3月
### Hack the Boxとの出会い
Hack the Box のことは初めは単なる常設 CTF だと思っていて、なんとなく登録してみました。
この時点での僕の経験は「CTF の Web 問のすごい簡単なやつが解ける」程度でした。

登録してみると Hack the Box が CTF とちょっとだけ違うことに気がつきます。（challenge は CTF っぽいけど）

今更ながらの紹介ですが、Hack the Box はいわゆるペネトレーションテストが実践できるようなサービスです。CTF では PENTEST というジャンルでペネトレ問が出されることはありますが、そんなに頻繁ではないです。

### Kaliなどの環境を構築する
「ペネトレーションテストには Kali Linux なるものを使うらしい…」ということを聞きつけたので「ハッキング・ラボのつくりかた仮想環境におけるハッカー体験学習」という本を借りて Kali の環境構築&さらっと流し読みで雰囲気を掴みました。

[ハッキング・ラボのつくりかた 仮想環境におけるハッカー体験学習](https://www.shoeisha.co.jp/book/detail/9784798155302)

### Hack the Boxでいきなり課金
Hack the Box には VIP 会員という制度があり、10 ドル/month で vip になれます。

vip になると

- Retired Machine に挑戦できる
- 空いてる Machine に挑戦できる

などなどの特典があり、最も大きいのは 1 つ目の「Retired Machine に挑戦できる」です。

そもそも Machine というのは攻略対象のマシンのことですが、ランクに関係する Active Machine とランクに関係しない Retired Machine の二種類が存在します。

Retired Machine というのはランクに関係しないため、公式が「Retired Machine なら Writeup 書いていいよ！」と言っていて、公式を含めかなり多くの人が Writeup を出しています。

僕的には、**Hack the Box を楽しみたいなら VIP になるのがおすすめ**です

Retired Machine はこれまでの Machine が全て含まれている(多分)ので Active Machine よりも圧倒的に量があります。

また、多くの人が writeup を出しているため、何からすればいいかわからない人も writeup を見ながら手を動かして学習でき、自力で解けた Machine も他の人の解法をみると別のルートを通っていたり、別のツールを使っていたりと多くの学びがあります。

ということで僕は初手で VIP に登録し、Retired Machine をやり続ける日々を送ります。

また、あとで復習しやすいように自分でも Writeup を書いていました。

[tag - Hack the Box | さんぽしの散歩記](/tags/hack-the-box/)

多分この期間で 14 個の Machine を攻略しました。

## 4月- 5月

3 月後半 - 4 月前半は[インターンに行っていた](/posts/mixi-spring-internship-2020/)ので全然何もしていませんでした。

4 月の後半から TryHackMe という Hack the Box と似たようなペネトレを学べるサービスをやっていました。（これまた VIP で）

やってみて思いましたが、Hack the Box より先に TryHackMe 始めればよかったかもな〜とか感じました。

TryHackMe に関しては詳細は別の記事にまとめてあります。

[TryHackMe OSCP path Review](/posts/try-hack-me-oscp-path/)

また、TryHackMe に関しても Writeup を Qiita に書いていました。

[tag - TryHackMe | さんぽしの散歩記](/tags/tryhackme/)

## 5月 -
TryHackMe の VIP が終わってから Hack the Box の VIP に戻ってきた僕はこれまで通り Retired Machine を進めつつ、Active Machine の攻略も始めました。

また、自分なりにチートシートをまとめ始めました

[![sanposhiho/MY_CHEAT_SHEET - GitHub](https://gh-card.dev/repos/sanposhiho/MY_CHEAT_SHEET.svg)](https://github.com/sanposhiho/MY_CHEAT_SHEET)

また、今までは難易度 easy の Machine しか解いていませんでしたが、難易度 medium の Machine でも簡単なものは解けることに気がつき、最終的に

- Blunder - easy
- ServMon - easy
- Traceback - easy
- Remote - easy
- Magic - medium

を攻略し、Hacker に昇格しました。

最終的にこの時点で Active, Retired 合わせて 26 個の Machine を攻略していました。

#終わりに
Hack the Box 気になってる！みたいな人がどのように始めるかの参考になるといいなと思いこの記事を書いてみましたが、意外と内容薄っっぺらくなってしまった…

僕的に Hack the Box はどこから始めればいいかわからない（Kali のセットアップも含む）という最初のハードルが一番大きいと思っていて、特に日本だと Writeup を書いている人やこう言った入門的な記事を書いている人も少ないので、ハマると楽しいのに勿体無いな〜と思っています。

この記事を読んで Hack the Box を始めようみたいな人が増えてくれたら嬉しいです

また、セットアップなどの部分は[@v_avenger](https://twitter.com/v_avenger)さんの下の記事が一番分かりやすいと思います。

[Hack The Boxを楽しむためのKali Linuxチューニング](https://qiita.com/v_avenger/items/c85d946ed2b6bf340a84)

僕も次のランクの Pro Hacker を目指して頑張りたいと思います🏃
 
