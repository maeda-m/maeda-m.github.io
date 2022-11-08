---
layout: post
title: "VPS割引きっぷを使ってお得にConoHa VPSを使ってみた"
date:  2022-11-08 19:00:00 +0900
---

## 概要

[Heroku が無料プランを終了する](https://blog.heroku.com/eco-and-mini-plans-ga) のをきっかけに、格安でWeb/AP/DBサーバーを稼働させるにはどうすればいいのかを検討していたら、いつのまにか [ConoHa VPS メモリ 2GB/CPU 3Core プランの「VPS割引きっぷ 36か月分」](https://www.conoha.jp/conoha/vps/pricing/) をポチっていた話。

## 背景

件の Heroku 代替案については次の記事で認識はしているものの、いっそのこと [Nano Pi](https://www.friendlyelec.com/index.php?route=product/product&product_id=289) や [Raspberry Pi](https://raspberry-pi.ksyic.com/main/index/pdp.id/667/pdp.open/667) に [Dokku](https://dokku.com/) や [Ledokku](https://github.com/ocstudios/ledokku) などを導入すればいいのでは🤔 と検討していました。

- [RailsアプリをHerokuから移行するならどれがいいのか比較する | うなすけとあれこれ](https://blog.unasuke.com/2022/compare-heroku-alternatives/)
- [Herokuの新しい有料プランのまとめと、無料プラン終了後の個人的な移行方針について - give IT a try](https://blog.jnito.com/entry/2022/10/04/104100)

シングルボードコンピュータを常時稼働すると、維持費として通信費（IoT向けのグローバルIPありの格安SIMでも月額1,000 円前後から）や電気代が発生しますし、電源の冗長化などの設備投資をどこまでするのかなどの課題が判明したため、見送りとしました。規模感は違えど Heroku などのクラウドサービスの利用料金に維持費が含まれていると考えれば納得です。

## ConoHa VPS の何がうれしいのか

前述の背景から格安でWeb/AP/DBサーバーを稼働させるにはという評価軸で判断すると、[50万人突破記念キャンペーン｜VPSならConoHa](https://www.conoha.jp/campaign/500k/) や [秋の超得キャンペーン｜VPSならConoHa](https://www.conoha.jp/campaign/chotoku2022/) で期間限定ではあるがとにかく安い。

|▼ 図 キャンペーン期間中のVPS割引きっぷ料金|
|:---:|
|![キャンペーン期間中のVPS割引きっぷ料金](/assets/images/20221108-conoha-vps-pricing.png) <br>出典： [料金｜VPSならConoHa](https://www.conoha.jp/conoha/vps/pricing/) より|

例えば36か月分のVPS割引きっぷが次の料金となっている（2022年11月08日時点）。

|プラン     |年額（消費税込み）|アメリカ合衆国ドル換算|
|-----------|--------:|---:|
|メモリ512MB| 9,939 円| [68 USD](https://www.google.co.jp/search?q=9%2C939+%E5%86%86+USD) |
|メモリ 2GB |16,711 円|[115 USD](https://www.google.co.jp/search?q=16%2C711+%E5%86%86+USD)|

他VPSの年額程度で36か月使えてしまうため、ひとまず気軽に使う前提として使ってみた。
[アプリケーションテンプレート](https://www.conoha.jp/conoha/vps/function/template/) が豊富で動きを確かめやすい。

ただし、ちゃんとアプリを稼働させるのであれば [脆弱性対応やログ監視、バックアップなど](https://www.meti.go.jp/policy/netsecurity/secdoc/contents/seccontents_000078.html) を検討しなければならないため、DBの待機系などの限定的に使用するものについては、クラウドサービスを使うなどのすみ分けが必要なのかもしれない。

## 最後に

下のリンク経由でアカウント登録すると1,000 円分のクーポンが貰え、すぐに使えます（私には 2,000 円分のクーポンがプレゼントされます）。

[![ConoHa by GMO](https://www.conoha.jp/conoha/images/mainvisual_title.png)](https://www.conoha.jp/referral/?token=MQXBDOwXoLTjy3fziyvG9v4kX7YYk2Jv8RPu4VnGSFYtNPaetU0-9RP)
