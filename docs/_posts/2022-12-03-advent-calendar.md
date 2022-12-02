---
layout: post
title: "Heroku の代替 OSS を試した話"
date:  2022-12-03 00:00:00 +0900
---

これは [「フィヨルドブートキャンプ Part 2 Advent Calendar 2022」](https://adventar.org/calendars/7786) の3日目の記事です（[Part 1](https://adventar.org/calendars/7760) もあります🎅）。
昨日はよかじさんの「[フィヨルドブートキャンプのカリキュラム以外でやってよかったこと - よかじみ](https://yocajii.hatenablog.jp/entry/2022/12/02/114536)」という記事でした。

## 概要

この記事は Heroku が無料プランを終了するのをきっかけに [Heroku の代替 OSS「CapRover」](https://caprover.com/) を VPS 上に構築してアプリケーションのデプロイを試した記録です。

## 背景

フィヨルドブートキャンプは最後の課題「Webサービスを作って公開する」を終えて卒業になります [^1] 。

そのWebサービスのデプロイ先として私が検討していたのは Heroku でしたが、 [Heroku’s Next Chapter | Heroku](https://blog.heroku.com/next-chapter) でアナウンスがあったとおり2022年11月28日で無料プランが終了しました。
現時点（2022年12月03日）では [最小構成（Eco Dyno と Postgres Mini）で月額 $10](https://jp.heroku.com/pricing) となり、次の機能の価値と浮いた時間に対して格安と考えます。

- アプリケーションのデプロイが開発端末から実行でき、かつ簡単なこと
- 大量でないデータの永続化手段としてデーターベースを作成できること
- 実行環境のメンテナンス（パッチやセキュリティ設定）の手間がほとんどなく、アプリケーションの構築に集中できること
- 新しい機能によって開発体験がよくなること

この記事では最小構成の年額となる [$120（現時点では 16,242 円）](https://www.google.co.jp/search?q=120%20USD%20JPY)  [^2] を予算として OSS を活用したアプリケーションのデプロイを試します。

## 実行環境

2022年12月09日までのキャンペーンですが ConoHa VPS のメモリ 2GB/CPU 3Core プランが **3年分 16,711 円** で使えます（詳細は [VPS割引きっぷを使ってお得にConoHa VPSを使ってみた](https://www.maeda-m.com/2022/11/08/using-vps-discount-ticket.html) にまとめていますので、そちらを参照ください）。今回は上記のプランを実行環境とし、 OS は Ubuntu 22.04 にしました。

## Heroku の代替 OSS

[CapRover - Free and Open Source PaaS!](https://caprover.com/) を使用します。[ドキュメント](https://caprover.com/docs/deployment-methods.html) や [デモ環境（password: captain42）](https://captain.server.demo.caprover.com/) を見ると次のデプロイ方法がありました。

|デプロイ方法|補足|
|------------|----|
|Git ローカルリポジトリのディレクトリでコマンド「`caprover deploy`」を実行する|-|
|TAR形式のアーカイブファイルをアップロードする|試していません|
|GitHub/Bitbucket/GitLab の Webhook で連携する|試していません|
|Dockerfile/Dockerイメージ/captain-definition を指定する|-|
| [ワンクリック用テンプレート](https://github.com/caprover/one-click-apps) を使用する/追加する|試していません|

### ハードウェア要件とソフトウェア要件

[公式サイトにある前提条件](https://caprover.com/docs/get-started.html#prerequisites) ではいろいろ書いてありますが要点は次のとおりです。

- サーバーのメインメモリは 1GB 以上を推奨している
- OS は Ubuntu を推奨している
- Docker は v17.06.x 以上が必要になる
- ファイアウォールは `Docker Registry` や `Cluster` が不要であれば `80/tcp` と `443/tcp` だけ許可すればよさそう

### インストール手順

[公式サイトにあるセットアップ手順](https://caprover.com/docs/get-started.html#caprover-setup) や [コマンド「 `caprover serversetup` 」](https://github.com/caprover/caprover-cli#server-setup) 、 [Docker CE のインストール手順](https://docs.docker.com/engine/install/ubuntu/) を踏まえると次のシェルスクリプトになります。

<details>
<summary>bootstrap.sh</summary>

```bash
#!/bin/bash
CAPROVER_ROOT_DOMAIN=app.example.com
LETSENCRYPT_CERTIFICATE_EMAIL=admin@example.com

apt update
apt upgrade -y

apt install -y \
  sudo \
  wget \
  curl

# Docker
# See: https://docs.docker.com/engine/install/ubuntu/
echo "127.0.0.1 "`hostname` >> /etc/hosts

apt remove -y \
  docker \
  docker-engine \
  docker.io \
  containerd \
  runc

apt install -y --no-install-recommends \
  ca-certificates \
  gnupg \
  lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-compose-plugin

# Node.js
# See: https://github.com/nodesource/distributions#installation-instructions
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - &&\
apt install -y nodejs
npm install -g npm

# CapRover
# See: https://caprover.com/docs/get-started.html
mkdir /usr/local/captain
cd /usr/local/captain/

docker run \
  -e BY_PASS_PROXY_CHECK='TRUE' \
  -p 80:80 -p 443:443 -p 3000:3000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /captain:/captain caprover/caprover

# See: https://github.com/caprover/caprover-cli
# Note: https://github.com/coollabsio/get.coollabs.io/blob/main/static/coolify/install.sh
npm install -g caprover

CAPROVER_NEW_PASSWORD=$(echo $(($(date +%s%N) / 1000000)) | sha256sum | base64 | head -c 32)
cat << EOS > /usr/local/captain/config.json
{
  "caproverIP": "$(curl -4 ifconfig.co)",
  "caproverPassword": "captain42",
  "caproverRootDomain": "${CAPROVER_ROOT_DOMAIN}",
  "newPassword": "${CAPROVER_NEW_PASSWORD}",
  "caproverName": "$(hostname)",
  "certificateEmail": "${LETSENCRYPT_CERTIFICATE_EMAIL}"
}
EOS
```

</details>

なお OS の基本設定は次の内容を想定しています。

|項目            |設定値|
|----------------|------|
|ホスト名        |`self-hostable-heroku-by-captain`|
|ファイアウォール|http, https, ssh を許可している|

### セットアップ手順

前述の `bootstrap.sh` をスーパーユーザー権限で実行すると次の内容でセットアップ用の設定ファイル「`/usr/local/captain/config.json`」が作成されます。自身の実行環境向けに設定ファイルを変更してください。

|設定項目          |設定値                   |設定内容|
|------------------|-------------------------|--------|
|caproverIP        |`$(curl -4 ifconfig.co)` |サーバーのグローバルIPアドレス|
|caproverRootDomain|`app.example.com`        |CapRover の Web UI やデプロイしたアプリケーションが稼働するFQDN|
|newPassword       |ランダムな英数字32文字   |コマンドラインインターフェースでログインする際に必要になります|
|caproverName      |ホスト名                 |同上|
|certificateEmail  |`admin@example.com`      |Let’s Encrypt に登録するメールアドレス|

次にDNSレコードを追加します。ホスト名を `app` 以外に変更している場合は読み替えてください。

|ホスト名|種別|内容|
|--------|----|----|
|`*.app` |`A` |サーバーのグローバルIPアドレス|

dig コマンドや [nslookup(dig)テスト【DNSサーバ接続確認】](https://www.cman.jp/network/support/nslookup.html) などで反映されたかを確認してください。

セットアップについては次のコマンドで実行します。もし CapRover を起動してすぐにコマンドを実行した場合はセットアップに失敗することがあります。60秒ほど待ってから再度実行してください。

```console
# caprover serversetup -c /usr/local/captain/config.json ⏎
```

正常に完了したら CapRover の Web UI の URL が表示され `newPassword` で指定したパスワードでログインできます。
e.g. `https://captain.app.example.com`

![CapRover](/assets/images/20221203-caprover-cover.png)

## デプロイしてみる

試しにフィヨルドブートキャンプの課題で作成した https://github.com/maeda-m/sinatra-note-app を次の流れでデプロイしてみます。

1. CapRover の Web UI でアプリケーション（Puma）とデーターベース（PostgreSQL）の枠を作成する
2. CapRover の Web UI でデーターベースをデプロイする
3. 開発端末からコマンド「`caprover deploy`」でアプリケーションをデプロイする

なお [CapRover ではワンクリック用テンプレートにおいて Docker Compose に部分対応しています。](https://caprover.com/docs/docker-compose.html#how-to-run-docker-compose-on-caprover) 例えば Ruby on Rails で構築されている [Redmine のワンクリック用テンプレート](https://github.com/caprover/one-click-apps/blob/master/public/v4/apps/redmine.yml) があり、AP/DB の一括設定ができます。

### 1. CapRover の Web UI でアプリケーション（Puma）とデーターベース（PostgreSQL）の枠を作成する

#### アプリケーションの枠を作成する

次の内容でボタン「Create New App」をクリックして枠を作成します。

|App Name         |Has Persistent Data|
|-----------------|:-----------------:|
|`sinatra-note`   |未チェック|

![Create New App](/assets/images/20221203-sinatra-note-001.png)

#### HTTP Settings

次の内容で入力し、ボタン「Save & Update」をクリックします。

|入力項目                 |入力値|入力内容|
|-------------------------|------|--------|
|Enable HTTPS             |クリックする|HTTPS を有効にする|
|Container HTTP Port      |9292|80番ポート以外で HTTP を受付している場合に設定する|
|Force HTTPS by redirecting all HTTP traffic to HTTPS|チェックを入れる|HTTP でアクセスされたときに強制で HTTPS にする|

![HTTP Settings - after](/assets/images/20221203-sinatra-note-003.png)

#### データーベースの枠を作成する

次の内容でボタン「Create New App」をクリックして枠を作成します。

|App Name         |Has Persistent Data|
|-----------------|:-----------------:|
|`sinatra-note-db`|チェックを入れる|

![Create New App](/assets/images/20221203-sinatra-note-db-001.png)

#### HTTP Settings

次の内容で入力し、ボタン「Save & Update」をクリックします。

|入力項目                 |入力値|入力内容|
|-------------------------|------|--------|
|Do not expose as web-app |チェックを入れる|非 Web アプリケーションとして設定する|

![HTTP Settings - after](/assets/images/20221203-sinatra-note-db-003.png)

### 2. CapRover の Web UI でデーターベースをデプロイする

#### App Configs

[環境変数](https://hub.docker.com/_/postgres) にてユーザー名やデーターベース名を設定します。
またデータの永続化のために VOLUME を設定し、ボタン「Save & Update」をクリックします。

![App Configs - after](/assets/images/20221203-sinatra-note-db-004.png)

#### Deployment

初期化スクリプトや起動オプションの設定を反映した Dockerfile を用意し `🚀 Method 4: Deploy plain Dockerfile` に入力します。

<details>
<summary>Dockerfile</summary>

```Dockerfile
FROM postgres:14.2

ENV POSTGRES_HOST_AUTH_METHOD trust
ENV POSTGRES_INITDB_ARGS --encoding=UTF-8 --locale=C

RUN set -eux; \
  apt update; \
  apt install -y --no-install-recommends \
    ca-certificates \
    wget \
  ; \
  rm -rf /var/lib/apt/lists/*

RUN cd /docker-entrypoint-initdb.d \
  && wget https://raw.githubusercontent.com/maeda-m/sinatra-note-app/main/db/initdb.sql

CMD [ "postgres", "-c", "log_statement=all", "-c", "log_connections=on", "-c", "log_disconnections=on" ]

```

</details>

ボタン「Deploy Now」をクリックするとデプロイ時のログが更新されます。
`Build has finished successfully!` と表示されれば成功です。

![Deployment](/assets/images/20221203-sinatra-note-db-005.png)

### 3. 開発端末からコマンド「`caprover deploy`」でアプリケーションをデプロイする

#### App Configs

環境変数にてデーターベースへの接続情報を設定し、ボタン「Save & Update」をクリックします。

![App Configs - after](/assets/images/20221203-sinatra-note-004.png)

#### Deployment

次の Git ローカルリポジトリを用意してデプロイします。
なおデプロイは [`git archive --format tar`](https://github.com/caprover/caprover-cli/blob/v2.2.3/src/utils/DeployHelper.ts#L105-L112) を経由するためコミットされていないファイルはデプロイされません。

```
captain-example
|--.git
|--captain-definition
|--Dockerfile
```

<details>
<summary>captain-definition</summary>

```json
{
  "schemaVersion": 2,
  "dockerfilePath": "./Dockerfile"
}

```

</details>

<details>
<summary>Dockerfile</summary>

```Dockerfile
FROM ruby:3.1.1-bullseye

ENV RACK_ENV production

RUN set -eux; \
  apt update; \
  apt install -y --no-install-recommends \
    libpq-dev \
  ; \
  rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/maeda-m/sinatra-note-app.git \
   --branch main \
  /opt/sinatra-note-app

WORKDIR /opt/sinatra-note-app

RUN mv /opt/sinatra-note-app/entrypoint.sh /usr/local/bin/docker-entrypoint.sh \
  && chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 9292
CMD [ "bundle", "exec", "puma" ]

```

</details>

開発端末で `caprover login` をしてから `caprover deploy` を実行します。
`Deployed successfully` と表示されれば成功です。

![caprover deploy - start](/assets/images/20221203-sinatra-note-005.png)
![caprover deploy - done](/assets/images/20221203-sinatra-note-006.png)

なお Windows Terminal の場合はブランチ名を入力する前に <kbd>Enter</kbd> を押下する必要があります [^3] 。

---

デプロイ完了後、しばらくしてアプリケーションURLにアクセスすると無事稼働していました🎉

![sinatra-note-app](/assets/images/20221203-caprover-endcard.png)

## おわりに

この記事ではデプロイしたアプリケーションのトラブルシューティングについては記載していません。

ログ管理や `heroku run` のようなことをしたい場合は [公式サイトのトラブルシューティング](https://caprover.com/docs/troubleshooting.html) を参考にしてください。CapRover の Web UI に対するアクセスを制限したい場合は [公式サイトの NGINX Config](https://caprover.com/docs/nginx-customization.html) を参考にしてください。

また [CapRover - Free and Open Source PaaS!](https://caprover.com/) に関わるすべての方に感謝申し上げます🙏

---

[^1]: 課題の目的などは [フィヨルドブートキャンプに「自作サービスを作る」という課題がある理由とフィヨルドブートキャンプの取り組み | FJORD BOOT CAMP（フィヨルドブートキャンプ）](https://bootcamp.fjord.jp/articles/41) に詳しい記事がありますので、そちらを参照ください。
[^2]: 1か月前は1ドル148円台でした。
[^3]: https://github.com/caprover/caprover/issues/1209
