---
layout: post
title: "Vultr.com の Free Tier Program で Ruby on Rails + PostgreSQL を試してみた"
date:  2023-03-14 13:15:00 +0900
---

この記事は [Free Tier Program - Vultr.com](https://www.vultr.com/free-tier-program/) [^1] で次の環境を試した記録です。

[^1]: https://www.vultr.com/?ref=9396011-8H からアカウント登録をすると $100 分のお試しができるようです。

**表. 環境概要**

|項目||
|----|----|
|OS|Debian 11 x64|
|DB|PostgreSQL v15.2|
|Web,AP|Puma|
|App|[RedMica](https://github.com/redmica/redmica) [^2]|

[^2]: Ruby on Rails で作られている Redmine の次期バージョンの新機能を先行して使える RedMica を使用します。

## Free Tier Program について

2要素認証とクレジットカード情報を設定すると無料プラン（早期アクセス版）をリクエストできます。
承認されると下表の制限事項（1年間のみ、1インスタンスの制限など）が明らかになります。また今のところは特定ロケーションのみ有効です。

**表. Free Tier Program の制限事項**

|制限項目|制限内容|
|---|---|
|有効期間|承認後、1年間|
|サービス種類|Cloud Compute のみ|
|CPUの種類|Regular Performance のみ|
|サーバーロケーション|Miami, Seattle, Frankfurt のいずれか|
|サーバーイメージ|Debian などCPUやメモリ要件を満たすもののみ|
|サーバーサイズ|1 vCPU/512.00 MB RAM/10 GB SSD のみ|

|▼ 図. サービス種類 ～ サーバーロケーション|▼ 図. サーバーイメージ ～ サーバーサイズ|
|:---:|:---:|
|![](/assets/images/20230314-vultr-on-rails-with-free-tier-program-001.png)|![](/assets/images/20230314-vultr-on-rails-with-free-tier-program-002.png)|

ボタン「Deploy Now」をクリックすると、下図のようにサーバーが稼働します。

|▼ 図. サーバー稼働画面|
|:---:|
|![](/assets/images/20230314-vultr-on-rails-with-free-tier-program-003.png)|

## Debian の基本的な設定

まずは root でサーバーに SSH 接続（パスワード認証）します。

```shell
ssh root@${VULTR_IP_ADDRESS} -p 22
```

上記のコマンドのように環境に依存する設定内容を環境変数で代替しています。環境変数は下表のとおりとなりますので、適宜読み替えてください。

|環境変数|設定内容|
|--------|--------|
|`VULTR_IP_ADDRESS`|SSH 接続されるサーバーのグローバル IP アドレス|
|`CLIENT_IP_ADDRESS`|SSH 接続するクライアントのグローバル IP アドレス|
|`SSH_USER_NAME`|新規作成する SSH 用のユーザー|
|`CLIENT_PUB_KEY`|SSH で使用する公開鍵（ed25519などで作成したキーペアの公開鍵）<br>|
|`REDMINE_ROOT`|RedMica を配置するディレクトリ<br> e.g. `/var/lib/redmine`|
|`REDMINE_DB_PASSWORD`|DB用のユーザーのパスワード|

なお初回 OS 起動時は次の状態でした。

```console
root@vultr:~# uname -a
Linux vultr 5.10.0-21-amd64 #1 SMP Debian 5.10.162-1 (2023-01-21) x86_64 GNU/Linux

root@vultr:~# timedatectl status
               Local time: Thu 2023-03-16 02:37:00 UTC
           Universal time: Thu 2023-03-16 02:37:00 UTC
                 RTC time: Thu 2023-03-16 02:37:00
                Time zone: UTC (UTC, +0000)
System clock synchronized: no
              NTP service: n/a
          RTC in local TZ: no

root@vultr:~# localectl status
   System Locale: LANG=en_US.UTF-8
       VC Keymap: n/a
      X11 Layout: us
       X11 Model: pc105

root@vultr:~# df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            220M     0  220M   0% /dev
tmpfs            48M  1.3M   47M   3% /run
/dev/vda1       9.4G  2.7G  6.2G  30% /
tmpfs           237M     0  237M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs            48M     0   48M   0% /run/user/0

root@vultr:~# journalctl --priority err --boot
-- Journal begins at Thu 2023-03-16 02:35:34 UTC, ends at Thu 2023-03-16 02:37:15 UTC. --
-- No entries --

root@vultr:~# systemctl list-units --type=service
  UNIT                               LOAD   ACTIVE SUB     DESCRIPTION
  apparmor.service                   loaded active exited  Load AppArmor profiles
:
  cron.service                       loaded active running Regular background program processing daemon
  dbus.service                       loaded active running D-Bus System Message Bus
  getty@tty1.service                 loaded active running Getty on tty1
  ifupdown-pre.service               loaded active exited  Helper to synchronize boot up for ifupdown
  keyboard-setup.service             loaded active exited  Set the console keyboard layout
  kmod-static-nodes.service          loaded active exited  Create list of static device nodes for the current kern...
  ntp.service                        loaded active running Network Time Service
  rdnssd.service                     loaded active running IPv6 Recursive DNS Server discovery Daemon
  resolvconf.service                 loaded active exited  Nameserver information manager
  rsyslog.service                    loaded active running System Logging Service
  ssh.service                        loaded active running OpenBSD Secure Shell server
  systemd-journal-flush.service      loaded active exited  Flush Journal to Persistent Storage
  systemd-journald.service           loaded active running Journal Service
:
  ufw.service                        loaded active exited  Uncomplicated firewall
  unattended-upgrades.service        loaded active running Unattended Upgrades Shutdown
  user-runtime-dir@0.service         loaded active exited  User Runtime Directory /run/user/0
  user@0.service                     loaded active running User Manager for UID 0

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.
41 loaded units listed. Pass --all to see loaded but inactive units, too.
To show all installed unit files use 'systemctl list-unit-files'.
```

タイムゾーンやキーボード入力、ログ出力の設定をします。

**XXX-ctl**

日本用の設定をします。

```shell
timedatectl set-timezone Asia/Tokyo
localectl set-locale ja_JP.UTF-8
```

**Logrotate**

ログの保存期間を1年程度にします。

```shell
sed /etc/logrotate.conf --in-place=.$(date +%Y%m%d) \
  --expression='s/rotate 4/rotate 60/g' \
  --expression='s/#compress/compress/g'
```

**IPv6**

IPv6 を無効 [^3] にします。

[^3]: IPv6 は慣れていないため、 IPv4 に限った設定をしています。

```shell
sysctl -w net.ipv6.conf.all.disable_ipv6=0
sysctl -w net.ipv6.conf.default.disable_ipv6=0
sysctl -w net.ipv6.conf.lo.disable_ipv6=0
cp /etc/sysctl.conf /etc/sysctl.conf.$(date +%Y%m%d)
cat << EOS >> /etc/sysctl.conf
# Disable IPv6
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
EOS
```

## セキュリティ対策設定

必要最低限の設定をします。より詳しい解説は [Linuxセキュリティ標準教科書 | LPI-Japan](https://linuc.org/textbooks/security/) などを参照してください。

### SSH のポート変更とパスワード認証の拒否

SSH 用のユーザーを作成し、SSH のポート変更などします。

|設定項目|初期値|設定内容|
|--------|------|--------|
|ポート番号|22|8181|
|root 接続可否|Yes|No|
|パスワード認証|Yes|No|
|公開鍵認証|Yes|Yes|
|許可ユーザー|任意|`SSH_USER_NAME` のみ|

SSH 用のユーザーを作成します。

```shell
adduser ${SSH_USER_NAME} --disabled-password --uid 4545 --gecos ""
usermod -aG sudo ${SSH_USER_NAME}
sudo -u ${SSH_USER_NAME} ssh-keygen -t ed25519 \
  -f /home/${SSH_USER_NAME}/.ssh/id_ed25519 -N ""
```

```shell
AUTHORIZED_KEYS=/home/${SSH_USER_NAME}/.ssh/authorized_keys

echo ${CLIENT_PUB_KEY} >> ${AUTHORIZED_KEYS}
chown ${SSH_USER_NAME}:${SSH_USER_NAME} ${AUTHORIZED_KEYS}
chmod 600 ${AUTHORIZED_KEYS}
```

`sudo` を実行するためのパスワードを設定してください。

```shell
passwd ${SSH_USER_NAME}
```

SSH のポート変更などします。

```shell
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%Y%m%d)
cat << EOS >> /etc/ssh/sshd_config

# Custom Config
Port 8181
AddressFamily inet
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no
UseDNS no
PubkeyAuthentication yes
UsePAM yes
AllowUsers ${SSH_USER_NAME}
EOS
```

### 受信する通信を必要なもの以外拒否

ファイアウォールを設定します。あわせて SSH のポート変更にも対応させます。

```shell
ufw default deny
ufw delete allow 22/tcp
ufw allow from ${CLIENT_IP_ADDRESS} to any port 8181 proto tcp comment 'SSH'
ufw allow 3000/tcp comment 'HTTP'

ufw limit 8181/tcp
ufw logging medium
ufw enable
systemctl enable ufw
ufw status verbose
```

### サーバーの再起動と SSH 用のユーザーで接続

設定が反映されるように、サーバーを再起動します。

```shell
reboot
```

SSH 用のユーザーで接続します。

```shell
ssh ${SSH_USER_NAME}@${VULTR_IP_ADDRESS} -p 8181 -i CLIENT_PUB_KEYで指定したキーペアの秘密鍵
```

## RedMica のセットアップ

共通して使用するライブラリをインストールしておきます。

```shell
sudo apt update
sudo apt upgrade -y
sudo apt install -y \
  ca-certificates \
  build-essential \
  lsb-release \
  unzip \
  git \
  wget \
  curl \
  vim
```

### Ruby のインストール

[rbenv](https://github.com/rbenv/rbenv) や [ruby-build](https://github.com/rbenv/ruby-build/wiki#ubuntudebianmint) を参考にして Ruby をインストールします（処理時間は10分程度です）。

```shell
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
source ~/.bashrc
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

```shell
sudo apt install -y \
  autoconf bison patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev \
  zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev

rbenv install 3.2.1
rbenv global 3.2.1
```

なお Ruby のインストール中のロードアベレージは次のとおりです。

```console
$ top
top - 09:30:05 up 10 min,  2 users,  load average: 1.00, 0.85, 0.46
Tasks: 123 total,   2 running, 121 sleeping,   0 stopped,   0 zombie
%Cpu(s): 96.0 us,  1.7 sy,  0.0 ni,  0.0 id,  2.0 wa,  0.0 hi,  0.3 si,  0.0 st
MiB Mem :    473.3 total,    150.0 free,    128.4 used,    194.9 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.    332.2 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
  14551 nakamur+  20   0  116088  48264   7008 R  97.7  10.0   0:04.55 ruby
     12 root      20   0       0      0      0 I   0.3   0.0   0:00.77 rcu_sched
      1 root      20   0   98252   4652   2428 S   0.0   1.0   0:01.59 systemd
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.00 kthread
:
```

### PostgreSQL のインストール

[PostgreSQL: Linux downloads (Debian)](https://www.postgresql.org/download/linux/debian/) を参考にしてリポジトリを追加し、データベースを導入します。

```shell
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
sudo apt -y install postgresql-15
```

念のため、各設定ファイルが複数ないことを確認します [^4]。

[^4]: [postgres - Official Image | Docker Hub](https://hub.docker.com/_/postgres) などを参考にした場合は `initdb` でデータディレクトリを指定してまうため、複数の設定ファイルが存在します。そのため、どの設定ファイルが読み込まれているかわかりづらくなり、混乱を招く可能性があります。

```shell
sudo ls -la /etc/postgresql/15/main/
sudo ls -la /var/lib/postgresql/15/main/

sudo find / -print | grep pg_hba.conf
sudo find / -print | grep postgresql.conf
```

[PGTune](https://pgtune.leopard.in.ua/) を参考にメモリ 512MB で動作するようにチューニングします。あわせて [ログの出力設定](https://www.postgresql.org/docs/current/runtime-config-logging.html) をします。

```shell
sudo tee --append /etc/postgresql/15/main/postgresql.conf << EOS >/dev/null

listen_addresses = 'localhost'
logging_collector = on
log_connections = on
log_disconnections = on
log_hostname = on
log_line_prefix = '[%t] %u %d %p-%l '
log_statement = 'ddl'
log_min_duration_statement = 3000

max_connections = 20
shared_buffers = 128MB
effective_cache_size = 384MB
maintenance_work_mem = 32MB
checkpoint_completion_target = 0.9
wal_buffers = 3932kB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 3276kB
min_wal_size = 1GB
max_wal_size = 4GB
EOS
```

設定の反映と自動起動の設定をします。

```shell
sudo systemctl restart postgresql
sudo systemctl enable postgresql
```

### RedMica のインストール

[Redmineのインストール - Redmineガイド](http://guide.redmine.jp/RedmineInstall/) や [Redmine.JP Blog](https://blog.redmine.jp/articles/mica-1_2/install/ubuntu/) を参考にします。

まず DB とDB用のユーザーを作成します。

```shell
sudo --preserve-env --user postgres psql \
  --command "create user redmine_owner with password '${REDMINE_DB_PASSWORD}';"
sudo -u postgres createdb --owner redmine_owner --template template0 redmine
```

必要なライブラリをインストールします。

```shell
sudo apt update
sudo apt install -y \
  libpq-dev \
  direnv \
  fonts-noto-cjk fonts-noto-color-emoji \
  imagemagick
```

ソースコードの配置と設定ファイルを追加します。

```shell
sudo git clone https://github.com/redmica/redmica.git ${REDMINE_ROOT}
sudo tee ${REDMINE_ROOT}/config/database.yml << EOS >/dev/null
production:
  adapter: postgresql
  database: redmine
  host: localhost
  username: redmine_owner
  password: "${REDMINE_DB_PASSWORD}"
  encoding: utf8
EOS

sudo tee ${REDMINE_ROOT}/Gemfile.local << EOS >/dev/null
gem 'puma'
EOS
sudo chown -R ${SSH_USER_NAME}:${SSH_USER_NAME} ${REDMINE_ROOT}
```

RedMica の準備をして起動します（`bundle install` が強制終了になる場合は再度実行します）。

```shell
cd ${REDMINE_ROOT}
bundle config set --local without 'development test'
bundle install
bin/rake generate_secret_token
RAILS_ENV=production bin/rake db:migrate
RAILS_ENV=production bin/rails server --binding ${VULTR_IP_ADDRESS}
```

ブラウザでアクセスできました～🎉

![](/assets/images/20230314-vultr-on-rails-with-free-tier-program-004.png)

なお puma 起動時のディスク使用量とメモリ使用量は次のとおりでした。

```shell
df -h
ファイルシス   サイズ  使用  残り 使用% マウント位置
udev             220M     0  220M    0% /dev
tmpfs             48M  672K   47M    2% /run
/dev/vda1        9.4G  3.7G  5.2G   42% /
tmpfs            237M  1.1M  236M    1% /dev/shm
tmpfs            5.0M     0  5.0M    0% /run/lock
tmpfs             48M     0   48M    0% /run/user/4545
```

```shell
free -m
               total        used        free      shared  buff/cache   available
Mem:             473         248          24          28         199         172
Swap:              0           0           0
```

## おわりに

無料の仮想サーバーと考えると大変ありがたいですね😆
さらに [サーバー到達前のファイアウォール設定](https://www.vultr.com/docs/vultr-firewall/) など便利な機能があるようです。

ただし、ビルド処理などを行なう場合はロードアベレージが1以上になり、強制終了することがあります。
そのため、軽量な用途やセットアップ時にビルド処理などが少ない場合に限って利用するとよさそうです。
また DBサーバーなど、特定の用途に限定して利用することも考慮してみると良いかもしれません🚀

---
