---
title: "メルカリのインターンに参加して静的解析をゴッツリ学んできた"
date: 2020-09-06T22:37:54+09:00
description: 静的解析完全に理解した
draft: false
author:
 - "さんぽし"
tags:
 - "internship"
categories:
 - "experience"
---

こんばんわ

8/31 - 9/4 でメルカリの**Online Summer Internship for Gophers 2020**に参加してきました。

内容としては以下の通りで 1 週間を通して、Golang の静的解析について学びました。

> 前半2日間は、Goの静的解析に関する講義やプログラミング言語Go完全入門の資料で参加者が興味を持つ領域を中心とした講義をWorkshopを交えながら実施。後半3日間では、静的解析ツールまたはその周辺ツールの開発に取り組んでいただきます。
> 
> [https://mercan.mercari.com/articles/22800/:title]


資料に関してはすでに公開されているので興味のある方は是非！

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">今日からお世話になってる <a href="https://twitter.com/hashtag/mercari_intern?src=hash&amp;ref_src=twsrc%5Etfw">#mercari_intern</a> の資料が公開されています👀<br><br>「プログラミング言語Go完全入門」の完全公開のお知らせ | メルカリエンジニアリング<br> <a href="https://t.co/XKmwhJo7wO">https://t.co/XKmwhJo7wO</a> <a href="https://twitter.com/mercaridevjp?ref_src=twsrc%5Etfw">@mercaridevjp</a>より</p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1300330932189106176?ref_src=twsrc%5Etfw">August 31, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## 僕が作ったもの

上記の説明の通り 3 日間かけて静的解析ツールの実際の開発を行いました。

僕は

- 不要な代入の検出ツール
- 代入文の後にデバック文を入れてくれるツール

を開発しました。

自分で作っておきながらどっちも凡庸的に使える便利くんだと思うので是非使ってみてくれよなっっっ


## 不要な代入の検出

[![sanposhiho/wastedassign - GitHub](https://gh-card.dev/repos/sanposhiho/wastedassign.svg)](https://github.com/sanposhiho/wastedassign)

このツールでは具体的に

- 代入されたけど return までその代入された値が使用されることはなかった
- 代入されたけど代入された値が用いられることなく、別の値に変更された

と言った物を検出します。

Golang は完全な未使用変数は教えてくれるけど、定義されてから一度使われている変数に対する再代入は教えてくれないよね。というモチベです

具体的な使用例はこちらです

```go
package a

func f() {
    useOutOfIf := 0 // "wasted assignment"
    err := doHoge()
    if err != nil {
        useOutOfIf = 10 // "reassigned, but never used afterwards"

        return
    }

    err = doFuga() // "reassigned, but never used afterwards"

    useOutOfIf = 12
    println(useOutOfIf)
    return
}
```

コメントの通り、このコードに対しては 3 回ツールによる警告が行われます。

- 1 つ目はどのルートを通っても `useOutOfIf` が**もう一度定義される**ので 1 行目で定義する必要性がない
- 2 つ目は `useOutOfIf` に対して再代入が行われているが、その後**すぐに return されている**ので再代入の必要性がない
- 3 つ目は `doHoge()` の返り値として受け取った変数 `err` を使いまわして `doFuga()` のエラーを受け取っているが、その後**使用されていない**ので再代入の必要性がない

このツールを使用するメリットとしては

- 無駄な代入文を省くことによる**可読性アップ**
- 無駄な再代入を検出することによる**使用忘れの確認**（上記例で言うところの err ハンドリング忘れなど

があります。

前者に関しては必ずしも可読性がアップするかというと議論の余地はあるかもしれませんが、使用しないのであればブランク変数で受け取るなりした方が読む方としては明示的に使わないということがわかり、読みやすいと思います。

また、使用しないことが明示的にわかることで、

- なぜ使用しないのか
- 関数の返り値として返す必要がそもそもないのではないか（上記例で言うと、`doFuga()`はそもそもエラーを返す必要がないのではないか

などの議論が生まれるきっかけとなります。

### どう言う仕組みなの？

どう言う仕組みで解析しているかを簡単に紹介します。

このツールでは**SSA（静的単一代入形式）**と言う形式を利用して不要な(再)代入を検出しています。SSA に関して詳しくは序盤に紹介した講義資料を参照してみてください

流れとしては

- Local の変数に対する `ssa.Store` 命令(= 変数への代入文)を探す（変数 `hoge` に対する `ssa.Store` 命令が発生していたと仮定する）
- `ssa.Store`命令が発生していたブロックから遷移し得るブロック全てに探索をかけ、次に `hoge` がどこで使用されるかを探す

この流れで `hoge` に**代入が起こった後に `hoge` がどのように使われるか**の可能性を全て列挙できます。

そして、`hoge`の次の使用の可能性が**全て**`hoge`に対する代入であった場合は探索の元になった方の `ssa.Store` 命令は無駄な命令だと判別ができます。

また、`hoge`に対する操作の可能性がなかった場合も不要な再代入であるとの判別ができます。

##  代入文の後にデバック文を入れてくれるツール

[![sanposhiho/easydebug - GitHub](https://gh-card.dev/repos/sanposhiho/easydebug.svg)](https://github.com/sanposhiho/easydebug)

こちらは個人的にとても欲しかったので作成しました。

ソースコードの中の変数に対する代入が発生している箇所を検出してそのすぐ後にその変数をデバックするための式を挿入してくれる物です。

↓Before

```go
package main

func test() int {
	hoge := 1

	fuga := 3

	if hoge == 2 {
		fuga = abusoluteTwo()

		hoge = 12

	}

	return hoge + fuga
}

func abusoluteTwo() int {
	return 2
}
```

↓After

```go
package main

func test() int {
	hoge := 1
	dmp("hoge", hoge)

	fuga := 3
	dmp("fuga", fuga)

	if hoge == 2 {
		fuga = abusoluteTwo()
		dmp("fuga", fuga)

		hoge = 12
		dmp("hoge", hoge)

	}

	return hoge + fuga
}

func abusoluteTwo() int {
	return 2
}

// generated from goeasydebug
// function for data dump
func dmp(valueName string, v ...interface{}) {
  for _, vv := range(v) {
      // arrange debug as you like
      fmt.Printf("%s: %#v\n",valueName, vv)
  }
}
```

このツールによって挿入されたデバック文をさくっと消すことができるのも推しポイントです。（コマンドに flag で `-mode 1` を渡すとデバック文消去が可能）（勿論このツールによって挿入されたデバック文のみしか消しません）

また、このツールではデバック用の関数 `dmp` がファイル内に作成され、デフォルトではそこでシンプルに fmt.Printf するだけになっていますが、この関数を編集することで、logger を使うなり、ファイルに出力するなりに変更を加えることができるようにしています。

### どう言う仕組みなの？

こちらは 1 つ目のツールよりはかなりシンプルな作りになっています。

SSA ではなく、AST の状態でソースコードを解析し、

- `ast.AssignStmt`（= 変数への代入）を探す
- その次にデバック用の関数 `dmp` の呼び出しを追加する

と言う流れになっています。

削除はその逆で

- `ast.CallExpr`でデバック用の関数 `dmp` の呼び出している位置を探す
- 消す

と言う流れになります。

また、if 文などが挟まっているときには再帰でその中まで探しに行くと言うことをしています。

## 総じて感想

僕は参加前はｾｲﾃｷｶｲｾｷ?って感じのレベルでしたが実際に講義を通して Golang における静的解析ツールの作成を一通り学べ、Golang がこれほどまでに静的解析周りの環境が整っていることにもとてもびっくりしていました。

普段の開発ライフだと確実に手を出すことのない分野だったのでとても良いきっかけになりました。

Twitter で[#mercari_intern](https://twitter.com/search?q=%23mercari_intern&src=typeahead_click)と検索すると他の人が何をやっていたかなどが出てくると思うのでそちらもチェックしてみてください！！

メンターさんをはじめとするサポートしてくださった社員の皆さん、5 日間ありがとうございました！！！！！
