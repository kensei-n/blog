---
title: "HackerRankがElixirに対応しているらしいのでやってみる"
date:  "2020-01-04T15:04:05+07:00"
author:
  - "さんぽし"
draft: false
tags: ["Elixir","競技プログラミング","HackerRank"]
categories:
  - "development"
---

Elixir がはじめに実務レベルで学んだ言語なので僕は Elixir にすごく愛着があります。

しかし、AtCoder をやろうにも Paiza やろうにも Elixir が未対応ってなってます。。
(Paiza はβ版)

(追記: AtCoder で Elixir の対応が始まりました)

僕的に
「競技プログラミングは自分の中でその言語の修行に用いるもの」
という認識だったので、「競技プログラミングするために C++を勉強しよう！」というのは手段と目的が逆転している気がしていました。
（もちろん競技プログラミングで良いスコアを取ることやアルゴリズムなどの勉強を目的に頑張っている方々の批判とかじゃないです）

なので競技プログラミングやったことがこれまでなかったのですが、
[HackerRank](https://www.hackerrank.com/)というアメリカ版 AtCoder 的なものがありましてですね、これがなんと**Elixir に対応している**ということで、

やってみます

## 実際に解いてみる
こちらの問題を解いてみます。
https://www.hackerrank.com/challenges/kmp-fp/problem

問題内容をまとめると

```
4
abcdef
def
computer
muter
stringmatchingmat
ingmat
videobox
videobox
```
のような入力が与えられます。
初めの数字は単語のペアの数、残りは 2 つずつ単語のペアになっています。

単語のペアのうち初めの単語の中に 2 つ目の単語が含まれる場合には `YES` を、含まれていない場合は `NO` を出力するという問題です。

すなわち上の例に対する出力は以下のようになれば正しいということになります。

```
YES
NO
YES
YES
```

この問題は Elixir の String モジュールに `String.contains?/2` という関数があることを知っていればすごく簡単です。

以下は解答例です。（見たくない人は飛ばしてください。）

### 解答例（見たくない人は飛ばしてください！）

```Elixir
defmodule Solution do
    def main() do
        number = IO.gets("") |> String.trim |> String.to_integer
        get_pairs([], number)
        |> Enum.map(&(substring_search(&1)))
        |> Enum.map(&(format_to_output(&1)))
        |> Enum.each(&(IO.puts(&1)))
    end

    def format_to_output(true), do: "YES"
    def format_to_output(false), do: "NO"

    def substring_search({string, contents}) do
        String.contains?(string, contents)
    end

    def get_pairs(pairs, time) do
        case time do
        0 -> pairs
        n ->pair = get_words()
            pairs = pairs ++ [pair]
            get_pairs(pairs, n-1)
        end
    end

    def get_words() do
        string = IO.gets("")|>String.trim
        contents = IO.gets("")|>String.trim
        {string, contents}
    end
end

Solution.main()
```

### 解説
すごく簡単に全体を説明すると

1. `IO.gets("")`で数字入力を受け取る
2. 受け取った数字の回数だけ `IO.gets("")` で単語を受けとる
3. `String.contains?`で評価する
4. True と False を YES と NO に置き換えて出力

となっています。

## コードの提出などの方法について

回答に関しては自分の環境で用意して提出するという形ではなく、以下のようなサイト内のエディタに直接書き込んで、「Submit Code」で提出するという形になります。
![スクリーンショット 2020-01-04 18.07.10.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/417600/88c1892c-eae3-30b1-458e-f12c1a27b094.png)

提出すると以下のようにテストが実行され、全てのテストを無事通過すれば合格となります。
![スクリーンショット 2020-01-04 18.05.54.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/417600/fde764c7-eabb-2fd9-1ded-543441915a24.png)
