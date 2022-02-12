---
title: "SSH 配置"
date: 2020-05-01T14:45:05+08:00
tags: ["ssh", "git"]
draft: false
---

系统环境 Ubuntu

## 客户端配置 KEY

可以实现：
  1. 同一主机使用不同 KEY。
  1. 不同主机使用不同 KEY。

编辑文件 `~/.ssh/config`：

```ssh
Host gh1
  User git
  Hostname github.com
  Port 22
  IdentityFile ~/.ssh/id_ecdsa
Host gh2
  User git
  Hostname github.com
  Port 22
  IdentityFile ~/.ssh/id_ed25519
```

SSH 客户端通过 Host 即可使用对应的配置。

```bash
git clone gh1:owner/repo.git
git clone gh2:owner/repo.git
```

- git 调用了 ssh 命令

## 服务器免密登录

在服务器编辑文件 `~/.ssh/authorized_keys`，添加客户端的 SSH 公钥(如 `~/.ssh/id_ed25519.pub`)：

```text
ssh-ed25519 AAAA***************************************************************7 notfound@ubuntu
```

- `~/.ssh/authorized_keys` 文件或者 `~/.ssh` 目录权限过大或者不正确时不会生效。

在客户端上编辑文件 `~/.ssh/config`：

```ssh
Host notfound
  User notfound
  Hostname notfound.cn
  Port 22
  IdentityFile ~/.ssh/id_ecdsa
```

直接执行 `ssh notfound` 即可登录服务器。

## 远程执行命令

配置好服务器免密登录后，通过 `ssh -T HOST command` 可以直接在服务器 HOST 上执行 command 命令。

如 hugo 编译，省去了手动登录的步骤：

```bash
ssh -T notfound hugo -s work/notfound.cn -d /var/www/notfound.cn
```
## 客户端心跳

客户端上编辑文件 `~/.ssh/config`：

```ssh
  ServerAliveInterval 60
```

- `ServerAliveInterval` 客户端 60s 未接收到服务端数据时，发送一个数据包给服务端

## 连接复用

客户端上编辑文件 `~/.ssh/config`：

```ssh
  ControlMaster auto
  ControlPath ~/.ssh/connection-%r@%h:%p
  ControlPersist 4h
```

- 终端多个窗口连接同一个服务器可以复用一个网络连接。
- 连接保持 4 小时

## 自建服务器保存 Git 仓库

配置服务器免密，登录服务器创建 git 仓库，在 `$HOME` 目录执行：

```bash
git init --bare demo.git
```

客户端配置 `~/.ssh/config` 后， 执行：

```bash
git clone notfound:demo.git
# 如果未配置 `~/.ssh/config`, 则执行
git clone user@notfound.cn:demo.git
```

## 将本地公钥复制到远程

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub notfound@notfound.cn
```

## ProxyCommand

```ssh
Host host_a
   User a
   Port 22
   HostName a.notfound.cn
Host host_b
   User b
   Port 22
   HostName b.notfound.cn
   ProxyCommand ssh -W %h:%p host_a
```
- 通过 `host_a` 跳转到 `host_b`

## 隧道

### 本地端口转发

```bash
ssh -L 3001:localhost:3000 192.168.1.2
# 等效
ssh -L 127.0.0.1:3001:localhost:3000 192.168.1.2
```

在本地机器使用 `127.0.0.1:3001` 如同在远程机器 192.168.1.2 上通过 `localhost:3000` 访问

### 远程端口转发

```bash
ssh -R localhost:3000:127.0.0.1:3001 192.168.1.2
```

在远程机器 192.168.1.2 上使用 `localhost:3001` 如同在本地通过 `127.0.0.1:3000` 访问

## 签名

- OpenSSH 8.0+

### 签名

```bash
# ssh-keygen -Y sign -f key_file -n namespace file
ssh-keygen -Y sign -f ~/.ssh/id_ed25519 -n git README.md
```
- `-f` 私钥文件路径 `~/.ssh/id_ed25519`
- `-n` namespace 为 `git`
- 被签名的文件路径为 `README.md`

### 验证

1. 新建文件 `~/.ssh/allowed_signers_file`

```text
notfound@notfound.cn ssh-ed25519 AAAAC3N*************************************************************
```
- 邮箱(可使用其他值)与 SSH 公钥映射

2. 验证

```bash
# ssh-keygen -Y verify -f allowed_signers_file -I signer_identity -n namespace -s signature_file [-r revocation_file]
ssh-keygen -Y verify -f ~/.ssh/allowed_signers_file -I notfound@notfound.cn -n git -s README.md.sig < README.md
```
- `-f` 邮箱(可使用其他值)与 SSH 公钥映射文件路径
- `-I` 邮箱(可使用其他值)
- `-n` namespace
- `-s` 签名
- 被签名的内容，从标准输入读取

输出

```text
Good "git" signature for notfound@notfound.cn with ED25519 key SHA256:q0FZbVN2eFXQYON1n85nYhMAFfV1hk65Wt88YuQ2WF0
```

## 参考

- <https://man.openbsd.org/ssh_config#ServerAliveInterval>
- <https://einverne.github.io/post/2017/05/ssh-keep-alive.html>
- <https://askubuntu.com/questions/87956/can-you-set-passwords-in-ssh-config-to-allow-automatic-login>
- <https://wangdoc.com/ssh/basic.html>
- <https://www.agwa.name/blog/post/ssh_signatures>
- <https://www.cnblogs.com/f-ck-need-u/p/10482832.html>
