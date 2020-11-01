---
title: "【Hack the Box write-up】Postman"
date:  "2020-10-19T15:04:03+07:00"
author:
  - "さんぽし"
draft: false
tags: ["writeup","Hack the Box"]
categories:
  - "security"
---

筆者は Hack the Box 初心者です。
何か訂正や補足、アドバイスなどありましたら、コメントか Twitter までお願いします。
[さんぽし(@sanpo_shiho) | Twitter](https://twitter.com/sanpo_shiho)

## cheat sheet

以下で cheat sheet としてツールの使い方などをまとめています。参考にしてください。
[github | sanposhiho/MY_CHEAT_SHEET](https://github.com/sanposhiho/MY_CHEAT_SHEET)

## machineについて
難易度は easy です。

![info card](/images/posts/hackthebox-blunder.png)


## nmap

```
kali@kali:~$ nmap -sC -sV 10.10.10.160
Starting Nmap 7.80 ( https://nmap.org ) at 2020-10-19 02:54 EDT
Nmap scan report for 10.10.10.160
Host is up (0.24s latency).
Not shown: 997 closed ports
PORT      STATE SERVICE VERSION
22/tcp    open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 46:83:4f:f1:38:61:c0:1c:74:cb:b5:d1:4a:68:4d:77 (RSA)
|   256 2d:8d:27:d2:df:15:1a:31:53:05:fb:ff:f0:62:26:89 (ECDSA)
|_  256 ca:7c:82:aa:5a:d3:72:ca:8b:8a:38:3a:80:41:a0:45 (ED25519)
80/tcp    open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: The Cyber Geek's Personal Website
10000/tcp open  http    MiniServ 1.910 (Webmin httpd)
|_http-server-header: MiniServ/1.910
|_http-title: Site doesn't have a title (text/html; Charset=iso-8859-1).
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 70.12 seconds
```
