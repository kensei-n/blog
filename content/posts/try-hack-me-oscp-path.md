---
title: "TryHackMe OSCP path Review"
date: 2020-05-17T22:37:54+09:00
draft: false
author:
 - "さんぽし"
tags:
 - "TryHackMe"
categories:
 - "security"
---

こんにちは

この 1 ヶ月 TryHackMe のサブスクをしてその中の OSCP path にチャレンジしていました。

TryHackMe に関しては Hack the Box などと比較するとマイナーで情報も少ないと思うのでどんな感じだったかというのを残しておきたいと思います

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">僕が皆さんの人柱となります…！ <a href="https://t.co/5GGb1O88SC">pic.twitter.com/5GGb1O88SC</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1251388139043577863?ref_src=twsrc%5Etfw">April 18, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

※記事の特性上完全に僕の主観で感想を述べています。TryHackMe ええやんってなった人は無料でできる machine もあるのでそっちから試して見た方がいいかもです

※TryHackMe の Room のことを machine とこの記事では呼ぶことにします（Hack the Box との違いが出るのがややこしいので）

## 先に結論

- TryHackMe は Hack the Box や VulnHub を今から始めようと思ってる人がその前に調査の流れ、ツールの使い方などを覚えるのにお勧め
- 僕みたいな Hack the Box かじってましたみたいな人でも OSCP Path を攻略していけば体系立てて色々学べるので知らなかったツールなどを覚えるきっかけになる
- 逆にある程度できる人には物足りないかも（Hack the Box、VulnHub に machine 数、やってる人の数、Writeup 数などの点で勝てない）

## TryHackMeって何なん？
Hack the Box のようにリモートに存在する machine をネットワークに接続し、攻略していくというサービスです。

[Try Hack Me](https://tryhackme.com)


## Hack the Boxでええやん
Hack the Box との大きな違いは**machine の攻略にある程度の道筋が示されている**という点かなと思います

Hack the Box は「machine は用意したからあとは頑張ってね！Try harder!!」といった感じですが、

TryHackMe には以下の machine をみてもらうと分かるようにかなり丁寧な誘導が付いています。

[Try Hack Me / blue](https://tryhackme.com/room/blue)

そのため、例えば

- Samba がいるけどなにすれば良いかわからない…
- SQLi が通りそうだけどなにすれば良いんだ…
- Windows 問解いたことがない…

などのように自分にとっての初見の技術が使われている場合/何から手をつければ良いかわからないなどの場合にすごく助かると思います。

そういった意味で Hack the Box などを今から始めたい！みたいな人は先に TryHackMe から始めると色々学べて良いのではないかなと思いました。

逆にそういった特性上 Hack the Box などとは違って
「machine 攻略したったぜ！！！」
という達成感はあまり無いかもです

## OSCP Pathについて
TryHackMe は Learning Path としてこういったものの勉強をしたいときはこういった順番で machine にチャレンジしてくといいよ〜という道筋を示してくれています。

その中の 1 つが OSCP Path でした。

示されていた machine の種類として、

- metasploit を使わないもの
- BOF 問

などがありました。また Path に示されている machine には似たような種類のものが少なかったため、自分の足りないジャンルの知識埋めになると思います。

僕は BOF 問まではスラスラ進んだのですが、あまり TryHackMe に時間を割けなかったこともあり、BOF やったことないマンだったのでそこで詰まって 1 ヶ月のサブスクでは終了できませんでした。

ですが、ある程度の経験はあり、1 ヶ月そこそこ時間が取れる人は普通に 1 ヶ月で終わるくらいの分量なんじゃないかなって思います。

## 書いたWriteup達

[tag - TryHackMe | さんぽしの散歩記](/tags/tryhackme/)

こいつ全然解いてないジャーンと思った方。その通りです

全部の machine で WriteUp 書いた訳では無いですけど↑にプラスで数問しか解いていないと思います。圧倒的精進不足…

## 総じて感想
僕的にはかなり満足度が高かったです！

- SQLi 問題に今までチャレンジしたことがなかったことに気づいた
- Samba や PowerShell など雰囲気で扱っていたもの達をしっかり学べた
- BOF もやらなきゃなと思った

OSCP Path から外れた machine なども含めて学びがかなり多かったです！

## 終わりに

この記事で TryHackMe を知った方はもしかすると選択肢の 1 つに入れてみてもいいかもしれません。参考になれば幸いです

僕は BOF をしっかり勉強してからもう 1 回チャレンジしようかなって思ってます。

OSCP 欲しい〜〜（心からの叫び）

## 雑談

高林さん OSCP 取得おめでとうございます！！！！！！！🎉🎉

また色々質問させてください…！🙏

[OSCP Review(受験記)](https://kakyouim.hatenablog.com/entry/2020/05/11/225348)
