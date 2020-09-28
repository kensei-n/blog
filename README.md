# さんぽしのBlog

## OGP生成

[tcardgen](https://github.com/Ladicle/tcardgen)を使用している. 公式のREADME通りにインストール後以下のコマンドを実行で、差分のみを対象にしてOGPの生成が行われる

```
git diff --name-only HEAD\^ content/posts  |\
xargs tcardgen -o static/tcard -f assets/fonts/kinto-sans -t assets/ogp_template.png
```
