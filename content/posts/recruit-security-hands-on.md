---
title: "脆弱性を直して学ぶ！Webセキュリティハンズオン by Recruit に参加した"
date: 2020-05-16T22:37:54+09:00
draft: false
author:
 - "さんぽし"
tags:
 - "Web Security"
categories:
 - "internship"
 - "experience"
 - "security"
---

こんばんは

本日 5/16 に脆弱性を直して学ぶ！Web セキュリティハンズオン by Recruit というイベントに参加したので、軽くですが参加記を残しておきたいと思います。

セキュリティを学べるようなイベントは（僕の観測範囲だと）少ない気がするのでとても楽しかったです！！


## どんなイベント？
イベントタイトルそのままですが、事前課題となるリポジトリを与えられて、そこに残された脆弱性を修正する、当日に脆弱性 1 つ 1 つ解説してもらう、といったイベントでした。

また、僕が一方的に知っている方などの豪華解説陣となっていて、とても貴重な機会だなぁ…と感動していました。

以下が事前課題となっていた、いわゆるやられアプリ Badsns です。

[ommadawn46/badsns2019](https://github.com/ommadawn46/badsns2019)

見ての通り Rails のアプリで、この中に計 20 個の脆弱性が存在します。

元々Recruit で新卒研修に用いられるものだそうです。

事前課題に関しては僕は締め切り直前に申し込んだということもあり、全く手を付けられず当日イベントに参加しました。~~割と同じ理由で手をつけてない人が何人かいて安心しました。~~

誰かが WriteUp をあげる的なことをいっていた気がするので、詳しく知りたい方は誰かが上げてくれる WriteUp をお待ちください…（人任せ）（僕は軽く目を通しただけで自分で 1 つも解いてないので…）

## 内容に関して
脆弱性は簡単な SQLi やディレクトリトラバーサルから、SSRF などの珍しい（気がする）ものまで豊富なバリエーションのものが存在しました。

Rails の open 関数などの仕様を利用したものなどもあり、Rails をにわかなりに扱うこともあるので、アプリの実装側としてもこれは注意しないと自分で脆弱性作っちゃうな…と感じました。

また SSRF に関しては僕は知識としてしか知らず、実際にどのように SSRF を利用した攻撃が行われるかなどがわかっていなかったため、攻撃例やクラウド環境を交えた悪用のされ方/対策などとても学びが深かったです。


僕は普段から Hack the Box、時々CTF といった感じで攻撃側に回ることが多く、

「脆弱性があることがわかりゃ後は攻撃するだけ！中身の実装がどうなってて脆弱性が生まれてるかなんて知らん！w」

といった感じだったのですが、実際に実装の際に気をつけるべき点や脆弱性の原因となっている実装など、普段の↑のようなことをしていては学びにくい内容を経験できました。


当日の僕のツイートを載せておきます、

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">MassAssignmentって初めて聞いた👀<a href="https://twitter.com/hashtag/WebSecurity_RecruitEvents?src=hash&amp;ref_src=twsrc%5Etfw">#WebSecurity_RecruitEvents</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1261525386380210178?ref_src=twsrc%5Etfw">May 16, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">How GitHub handled getting hacked <a href="https://t.co/JBxoYuSWzl">https://t.co/JBxoYuSWzl</a> <a href="https://twitter.com/ZDNet?ref_src=twsrc%5Etfw">@ZDNet</a> &amp; <a href="https://twitter.com/emilprotalinski?ref_src=twsrc%5Etfw">@emilprotalinski</a>さんから</p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1261529555040272385?ref_src=twsrc%5Etfw">May 16, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr"><a href="https://twitter.com/hashtag/WebSecurity_RecruitEvents?src=hash&amp;ref_src=twsrc%5Etfw">#WebSecurity_RecruitEvents</a><br><br>Rails の CVE-2019-5418 は RCE (Remote code execution) です<a href="https://t.co/RFY55yzyTH">https://t.co/RFY55yzyTH</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1261532159216517120?ref_src=twsrc%5Etfw">May 16, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr"><a href="https://twitter.com/hashtag/WebSecurity_RecruitEvents?src=hash&amp;ref_src=twsrc%5Etfw">#WebSecurity_RecruitEvents</a><br>LIKE句に%入れまくってDoS攻撃なんてできるのか<br><br>第２回：クエリを使用したSQLインジェクション<a href="https://t.co/Iw6kMyKuBr">https://t.co/Iw6kMyKuBr</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1261551417430437888?ref_src=twsrc%5Etfw">May 16, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## 終わりに

イベントに際して、3000 円分の UberEats などで使えるギフトがもらえたりしたのですが、むしろ 3000 円払ってでも参加したいくらいの濃い内容でした。

3 時間の濃密な解説本当にお疲れ様でした & ありがとうございました！！

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">え、まじ？？？（イベントの事前課題をやってない顔 <a href="https://t.co/E0m8OcGI34">pic.twitter.com/E0m8OcGI34</a></p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1261178165268865024?ref_src=twsrc%5Etfw">May 15, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
