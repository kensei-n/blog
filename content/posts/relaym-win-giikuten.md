---
title: "Relaymを出展して技育展「Webアプリ」部門で優勝してきた"
date: 2020-09-27T22:37:54+09:00
description: 優勝だーワッショーイ！テンションAGEAGEマック
draft: false
author:
 - "さんぽし"
tags:
 - "event"
categories:
 - "experience"
---

こんにちは

9/27 に技育展というイベントが行われました
「Web アプリ」部門で[CAMPHOR-](https://camph.net/)のメンバーと開発していた Relaym を出典していました。

>技育展は「未来の技術者を育てる」ことを目的とし
自らのアウトプットを「展示」する学生向けテックカンファレンスです。
([公式サイト](https://talent.supporterz.jp/geekten/2020/)より)


[Relaym | Spotifyの楽曲を1つのスピーカーで楽しめるWebアプリ](https://relaym.camph.net/)

そこでなんと**最優秀賞**を頂くことができました！！めちゃめちゃ嬉しい！！！ありがとうございます！！！！！！

この記事では発表したことに加えて、**時間の都合で説明できなかった技術的に細かぁ〜い部分**を紹介したいと思います。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr"><a href="https://twitter.com/hashtag/%E6%8A%80%E8%82%B2%E5%B1%95?src=hash&amp;ref_src=twsrc%5Etfw">#技育展</a> テーマ別審査結果です。<br><br>「WEBアプリ」の受賞作品は<br><br>最優秀賞：Spotify楽曲共有「Relaym」<br>優秀賞：ゲーム実況専用SNS「わいコレ」<br>敢闘賞：トレーニング支援「many-time-fitness」<br><br>となりました！<br>受賞された皆さん、おめでとうございます！！ <a href="https://t.co/28OShHgeI8">pic.twitter.com/28OShHgeI8</a></p>&mdash; 【公式】技育プロジェクトbyサポーターズ (@geek_pjt) <a href="https://twitter.com/geek_pjt/status/1309719590088318976?ref_src=twsrc%5Etfw">September 26, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## 解決したい課題
![スライド](/images/posts/relaym-slide1.png)

Relaym はそれぞれが聴きたい Spotify の楽曲を 1 つのスピーカーで楽しめる Web アプリケーションです。

![スライド](/images/posts/relaym-slide2.png)

Relaym は例えば上記のような課題を解決したいと思い開発されました。

ドライブ中に限らず、複数人での勉強会や鍋パ中など音楽を流している人に流したい人を頼まなければならない、もしくは Bluetooth を繋ぎ変えなければならないみたいな経験ありがちではないですか？

また、一人で作業している際、いつも同じプレイリストばかり使用してしまい、なかなか新しい曲に出会う機会がない、そう言ったときにも新しい曲を発掘したいという方もいませんか？

そんな中以下の考えのもと Relaym の開発に着手しました。

![スライド](/images/posts/relaym-slide3.png)

## 具体的にRelaymでできること

Relaym ではセッションという中心となる概念が存在していて、皆でセッションを共有して曲を追加していくような使用方法になります。

![スライド](/images/posts/relaym-slide4.png)

Relaym の使用はまず画像のようにセッションを作成するところから始まります。

![スライド](/images/posts/relaym-slide5.png)

セッションの作成後は左側のメニューバーからリンクを共有してセッションへの招待を行うことができます。

![スライド](/images/posts/relaym-slide6.png)

また、セッション作成時に他人からの操作を許可しないことで、上記のように**「SNS 上に招待リンクを投稿し不特定多数の人から作業 BGM を募集する」**といった使い方もできます。

![スライド](/images/posts/relaym-slide7.png)

セッションの作成後は、曲の検索/追加を行うことができます。

ここには[**インクリメンタルサーチ**](https://ja.wikipedia.org/wiki/%E3%82%A4%E3%83%B3%E3%82%AF%E3%83%AA%E3%83%A1%E3%83%B3%E3%82%BF%E3%83%AB%E3%82%B5%E3%83%BC%E3%83%81#:~:text=%E3%82%A4%E3%83%B3%E3%82%AF%E3%83%AA%E3%83%A1%E3%83%B3%E3%82%BF%E3%83%AB%E3%82%B5%E3%83%BC%E3%83%81%EF%BC%88%E8%8B%B1%E8%AA%9E%3A%20incremental%20search,%E3%81%AB%E5%80%99%E8%A3%9C%E3%82%92%E8%A1%A8%E7%A4%BA%E3%81%95%E3%81%9B%E3%82%8B%E3%80%82)を採用しており、滑らかな検索体験を実現しています。


![スライド](/images/posts/relaym-slide8.png)

曲の追加後に再生を行うことができます。その他、曲の停止やスキップなどの操作を行うことができます。

もちろん再生後も随時曲の新規追加を行えます。

## Relaymの設計/デザインに関して

![スライド](/images/posts/relaym-slide9.png)

Relaym は前述のように「複数人で曲を楽しんで欲しい」と言った思いから生まれているため、**セッションのシェア/参加の気軽さ**という点を中心に設計が行われています。

- Web アプリなのでインストール**不要**
- Relaym にアカウントという概念がないためログイン/登録**不要**
- 参加者に関しては Spotify アカウントすら**不要**

そのため**本当に招待 URL にアクセスするだけ**でセッションに参加できます。

## 技術スタックの話

ここから少し技術の話に入っていきます。

![スライド](/images/posts/relaym-slide10.png)

技術スタックはこんな感じです。

Spotify Web API を選んだ理由としては

- Spotify の**豊富な楽曲を利用できる**点
- Web アプリなのに**バックグラウンドで利用できる**点

というところにあります。

## 参加者同士の情報の同期

Relaym では参加者同士の情報の同期を実現する必要がありました。

以下のように操作の内容が別の参加者の画面にすぐに反映されています。

![同期の様子](/images/posts/relaym_sync.gif)

これを実現するために Relaym では**WebSocket を用いたイベントの一斉送信**を行っています

![スライド](/images/posts/relaym-slide11.png)

例えば再生開始が誰かの端末からリクエストされた際の流れを追ってみます

1. API サーバーがリクエストを受ける
2. SpotifyAPI を通し、Spotify 上で再生を実行
3. API サーバーは WebSocket を通して**全端末へ**再生開始のイベントを送信

このように逐一サーバーからセッションへの**操作の内容を全端末へ通知する**ことで参加者同士の情報の同期を実現しています。

また、参加者同士の情報の同期が実現できたとしても Spotify との実際の再生内容とあっていなければ元も子もありません。

![スライド](/images/posts/relaym-slide12.png)

そのため、API サーバーは特定のタイミングで**Spotify の再生状況の確認**を行い、Relaym の想定している動作とずれていないかを確認しています。

これによって Spotify が Relaym の想定と異なる状況だった場合は同様に WebSocket を通して全端末に同期失敗のイベントを通知しています。

## Relaymの再生状況を管理について

**ここから発表で話せなかった少し細かい技術的な部分の紹介を行います。**

僕がサーバーサイドの開発しか担当していなかった為、そちら中心の話になります

Relaym では前述のようにセッションの再生状況の管理を API サーバーで行っています。Go お得意の非同期処理で持っているわけですが、セッションのライフサイクルを追ってみましょう。

**1. セッションが作成される**

ソースコードでいうところの[この部分](https://github.com/camphor-/relaym-server/blob/master/usecase/session.go#L66-L83)です。

この時点では DB 内に**空のセッションが作成されるだけ**です。

**2. セッションに曲が追加される**

ソースコードでいうところの[この部分](https://github.com/camphor-/relaym-server/blob/master/usecase/session.go#L37-L64)です。

曲の追加では DB と同時に Spotify 側のキューに曲の追加を行います。

**3. 再生の開始**

ソースコードでいうところの[この部分](https://github.com/camphor-/relaym-server/blob/master/usecase/session_state.go#L202-L238)です。

再生の開始のタイミングでここではまず前述のように**Spotify API**を通して曲の再生開始がリクエストされます。その後[非同期処理](https://github.com/camphor-/relaym-server/blob/master/usecase/session_timer.go)でのセッションの管理が始まります。

非同期処理内ではセッションごとに**曲の終了の検知を行う Timer**が作成されます。

再生開始時に再生される曲の時間分の長さの Timer が作成されます。

（厳密には SpotifyAPI の遅延を吸収する為に数秒足された時間の Timer がセットされます。）

**4. 曲の終了**

ソースコードでいうところの[この部分](https://github.com/camphor-/relaym-server/blob/master/usecase/session_timer.go#L171)です。

先ほどセットした Timer の終了を検知して、次の曲への遷移の処理に移ります。

## SpotifyAPI側の処理の遅延の吸収のために

SpotifyAPI へのリクエストから**実際に端末でリクエストの内容が動作するまでに少し時間がかかってしまいます**。また、この遅延時間は利用者の端末の通信状況などでも変わってくる為、一定ではありません。

その為

- 曲の再生が終了する
- 次の曲の再生を Relaym からリクエストする

なんてことをやっていると利用者から見て、「曲の遷移が遅い」「曲が完全に終わっていないのに次の曲の再生が始まった」というふうな違和感が生じる原因となります。

この対策に Relaym では**Spotify 側に先に 2 曲先の曲まで積んでおく**と言った処理を行っています。

具体的には

- 「2. セッションに曲が追加される」内で、追加された曲が**現在再生されている曲の 2 曲先以内であれば Spotify に積む**
- 曲が終了するたびに**次の曲の 2 曲先に再生予定の物を Spotify 側に積む**

と言った処理を行っています。

これによって曲の終了とともに Spotify 側で自動で次の曲の再生が実行される為、前述の問題が解決します。

## エッジケースへの対応
Relaym は Spotify を利用するサービスである為、いくつか利用者の状況によって Relaym が正常に動作しないというケースがありました。

###Spotify 側のキューに既に曲が積んである場合

前述のように Relaym は Spotify 側のキューを利用する為、Relaym の利用前に Spotify 側のキューに曲を積んでいた場合（具体的には Spotify の「次に聴く」の機能を使用した場合）に Relaym が次に流して欲しい曲とは**別の曲が先に再生されてしまいます。**

その為、Relaym では再生を開始する際に**Spotify 側のキューをいったんリセットする**という処理を行っています

「キューの曲をなくす」と言ったニッチな API は Spotify 側から提供されていなかった為、SkipAPI を利用して無理やり実装を行いました。

- 曲の Skip の API を叩く
- 曲の再生状況を取得し、再生状況が STOP になっていた場合キューに曲がなくなったとみなす

これを繰り返すことによって Spotify 側のキューのリセットを実現しています。

また、先ほど「Spotify 側に先に**2 曲先**の曲まで積んでおく」というのがありましたが、ここで全ての曲ではなく 2 曲先までのみを追加としている理由は**キューの曲の全 Skip に時間がかかる**ためです。

###Spotify で何かしらの曲を再生していないと Spotify 側で検知できない

開発中に最も苦しめられた問題です。

Spotify で何かしらの曲を再生していない場合、**SpotifyAPI から「Active Device」として認識できず**、その端末での再生が開始できません。

その対策のために Relaym では再生時に `Active Device not found` が発生した際に Spotify で何かしらの曲を再生してもらうという手法をとっています

![スライド](/images/posts/relaym-slide13.png)

このダイアログを出すことで利用者に先に Spotify で再生を行ってもらい、利用者が Spotify から戻ってきた際に Relaym の再生がスタートするという設計にしています。

## 終わりに

技育展での発表の内容、また発表で伝えられなかった具体的な Relaym の動作について紹介しました。

Relaym はサーバーサイド、フロントエンド両方が OSS として公開されています。**あなたの contribution をお待ちしています！！！！**

[![camphor-/relaym-server - GitHub](https://gh-card.dev/repos/camphor-/relaym-server.svg)](https://github.com/camphor-/relaym-server)
[![camphor-/relaym-client - GitHub](https://gh-card.dev/repos/camphor-/relaym-client.svg)](https://github.com/camphor-/relaym-client)

また、関西近郊の学生の方はぜひ CAMPHOR- HOUSE に一度きてみてくださいね…👀👀

[CAMPHOR- —京都のIT系学生コミュニティ—](https://camph.net/)
 
