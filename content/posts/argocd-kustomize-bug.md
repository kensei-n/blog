---
title: "Kustomizeを利用しているプロジェクトでArgoCD Resource Hooksを用いて複数リソースで同一Jobを使用したいときに詰まるポイント"
date: 2020-11-08T11:29:13+09:00
author:
 - "さんぽし"
tags:
 - "ArgoCD"
 - "Kustomize"
 - "Kubernetes"
categories:
 - "development"
---

こんにちは

1. ArgoCDを使用している
2. [Kustomize](https://github.com/kubernetes-sigs/kustomize)でリソースを管理している
3. [ArgoCD Resource Hooks](https://argoproj.github.io/argo-cd/user-guide/resource_hooks/)で同じJobを複数のリソースで使用したい

この条件下で2020/11現在で存在する詰まりレベルがかなり高かったので記録として残しておきます

## シンプルに実装する

ArgoCD Resource HooksはArcdCDのsyncの特定のタイミング(Sync前、中、Sync成功時、Sync失敗時)にJobを実行できる機能です。

条件3の「同じJob」とは同一のyamlから生成されるJobを示しています。
Kustomizeを利用する事で「yamlを読み込む」という事ができるため、同一のyamlから生成されるJobを複数のリソースのResource Hooksに利用すると言った事が可能です。(DRYにかけて良いですね)

ここで発生する問題点としては、「同一タイミングで同一namespace内で複数のResource Hooksが発火したときに名前が衝突して実行に失敗する」という事です。
同じyamlから生成されるJobはそのままだと当然同じ/metadata/nameを持ちますのでこう言った事が起こってしまいます。

そこで使用するのが`generateName`です。これはkubernetesの機能でリソースの生成時にランダムな名前をつけてくれます。

[generated value - Kubernetes API Concepts](https://kubernetes.io/docs/reference/using-api/api-concepts/#generated-values)

> name: if generateName is set, name will have a unique random name

Jobの/metadata/nameの代わりに/metadata/generateNameを使用する事で先程のリソースの名前の衝突を防ぐ事ができますね。
実際にArgoCD Resource Hooksの公式のページのサンプルには/metadata/generateNameが使用されています

[ArgoCD Resource Hooks](https://argoproj.github.io/argo-cd/user-guide/resource_hooks/)

これで解決!ですね

### ところがどっこい問題点

ここで発生する問題は「kustomizeが/metadata/nameを持たないリソースをうまく扱ってくれない」というものです。以下にissueが上がっています。

[Unable to handle 2+ resources kinds using generateName: #586](https://github.com/kubernetes-sigs/kustomize/issues/586)

issueの通りですが、`kustomization.yaml`にて`resources`句を使用して、/metadata/generateNameを使用したリソースを読み込もうとすると「/metadata/nameが無いぜ!」と怒られるという問題です。

## /metadata/generateNameのエラーを上手く避ける作戦で実装する


/metadata/generateNameのエラーを上手く避ける作戦とは、patchesJSON6902を使用して/metadata/nameを途中で/metadata/generateNameに書き換えるというものです。

これによって先程のresourcesで読み込む際のエラーを回避する事ができます。この作戦は上記のissueのディスカッション内にも記載がありますが、以下に紹介されている作戦です。

[Support generateName for application resources](https://github.com/argoproj/argo-cd/issues/1639#issuecomment-494999921)

これで解決!ですね

### ところがどっこい問題点

次に発生する問題はpatchesJson6902を使用した特定の状況でエラーが発生するというものです。

[patchesJson6902 with operation "move" fail under certain circumstances.](https://github.com/kubernetes-sigs/kustomize/issues/3178)

> - use patchesJson6902 with operation move
> - move /metadata/name
> - patchesJson6902 has several targets
> - several targets has same group, target, and kind
> When use the above resource from other kustomization.yaml with resources statements, the following errors occur

僕が挙げたissueですが解決される事なくcloseされました()、なので未解決です

これによってまたもや失敗します、ちなみに似たようなものにpatchesというものがありますがpatchesJSON6902の代わりにpatchesを使用しても同様の問題が発生します

## さらに上記エラーの回避を試みる

上記issueには回避の方法があります、注目すべきはここです
> When use the above resource from other kustomization.yaml with resources statements, the following errors occur

resources句で読み込もうとする際にのみ発生するという点です。
そのため、DRY原則からは少し外れますが、Jobを読み込む各リソースのkustomization.yaml側でpatchesJSON6902を利用して/metadata/nameを/metadata/generateNameに置き換えをします
resource句で読み込んだ段階では/metadata/nameなので一つ目のissueをクリア、そして読み込んだ後にpatchesJSON6902を使用するので二つ目のissueをクリアという魂胆です

また、この作戦のめんどくさいポイントとしては、patchのためのファイルをcurrentディレクトリ以下に置かなければいけないという点です。
そのため、例えば300リソースにJobを登録したい場合、kustomization.yamlを300リソース分変更して、さらにpatchesJSON6902用のpatchファイルを300リソース分おいて回る必要があります。(深いため息)

### ところがどすこい問題点

[Suffix generateName is always 62135596800 #181](https://github.com/argoproj/gitops-engine/issues/181)

何とArgoCD側でgenerateNameの生成をミスっていて全てのリソースの名前が`some-operation-{git_hash}-presync-62135596800`という名前になってしまうという問題です。(本来は`some-operation-{git_hash}-presync-{suffix}`となるはず)

## 最終的な実装

妥協に妥協を重ねて結局以下のように実装を行いました。

- Job側はしょうがないので/metadata/nameを使用
- Jobを読み込む各リソースのkustomization.yaml側でpatchesJSON6902を利用して/metadata/nameの値をnamespace内でコンフリクトしないように頑張ってuniqにする

## 終わりに

この数々のissueに先週1週間を潰しました。偶然ArgoCDとkustomizeがバグが絶妙に噛み合って地獄のコンボとなっていました。
