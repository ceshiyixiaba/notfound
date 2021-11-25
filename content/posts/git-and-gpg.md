---
title: "Git 使用 GPG 进行签名"
date: 2019-02-16T22:43:00+08:00
tags: ["gpg", "git"]
---

本文仅介绍 Git 使用 GPG 进行签名，关于 GPG 参考 [GPG 使用](/posts/linux-gpg-usage/)。

## 配置 Git

配置 GPG 密钥。密钥 ID 可以为主密钥 ID 或者签名密钥 ID，签名时始终使用签名密钥 ID。

```bash
# Ubuntu 16.04 需要配置为 gpg2, Ubuntu 18.04+ 为 gpg
git config --global gpg.program gpg 
git config --global user.signingkey 64D29C1A5D25743C4F9B0758FB65859A38C36152
# 默认对标签进行签名
git config --global tag.forceSignAnnotated true 
# 默认对提交进行签名
git config --global commit.gpgSign true
```

## GPG 签名

### 签名标签

```bash
# 添加签名
git tag -s [tagname]
# 验证签名
git verify-tag [tagname]
```
### 签名提交

```bash
# 添加签名
git commit -S
# 验证提交
git verify-commit [hash]
# 显示签名
git log --show-signature
# 合并时强制签名检查并对合并操作进行签名
git merge --verify-signatures -S merged-branch
```

### Git 签名内容

```text
$ git cat-file -p c90a0f54861da37c123dce74f62a4c6d711fc65e
tree f93e3a1a1525fb5b91020da86e44810c87a2d7bc
author notfound <notfound@notfound.cn> 1637032587 +0800
committer notfound <notfound@notfound.cn> 1637032587 +0800
gpgsig -----BEGIN PGP SIGNATURE-----

 iQGzBAABCgAdFiEEZNKcGl0ldDxPmwdY+2WFmjjDYVIFAmGTIpIACgkQ+2WFmjjD
 YVJUmQv5AXzavXJLE8JY3mGk3GpZDaPqe+kowkYoi7tQ2XvsVoIb5PVA3Koje58x
 L5Zn37Nhiwr2mBXR/AqZvndo+tY7t4NAxdLUjeFD4k4bPWsFuNbtgrd1hBNrVtoZ
 ByHjV+iFQc4l1Drtay9vNz3auSp1QjrYOZQWWBve8VyjU4UJJP4jMYBeWoC72ipq
 6Hugj48xYnrC8hSjxn0JeF2XtRT2kIJxS2HeVtPxNS8ca6sKuqHK+H5MjnS5vmM3
 wZjJWuBUh5Rc9vYpaZAYBxcBOt6sM+XHRUzgV4FgF+z6mpyWenCV7/NIE4gFL1Fe
 y37Jfk+HVOfbzp5XuG/o4mKhLMit0eAYd/cX9gxudpt6qfuVf2gsMyDIWkRu/ddq
 CXIa8aqEESF3CTWwbmfcTsANDvdKJ6aGRqgry3F9fTHAA6VzUYU7uQoUviRobvVD
 u4ZOo7U43hAzc0g+GFi4jbJIIqLdCp6srq+ydHgy12KwPqdW3msYv3BuWzSEXxSD
 QodaraZg
 =pQxS
 -----END PGP SIGNATURE-----

GPG test
```

其中签名为(gpgsig.txt)：

```text
-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEEZNKcGl0ldDxPmwdY+2WFmjjDYVIFAmGTIpIACgkQ+2WFmjjD
YVJUmQv5AXzavXJLE8JY3mGk3GpZDaPqe+kowkYoi7tQ2XvsVoIb5PVA3Koje58x
L5Zn37Nhiwr2mBXR/AqZvndo+tY7t4NAxdLUjeFD4k4bPWsFuNbtgrd1hBNrVtoZ
ByHjV+iFQc4l1Drtay9vNz3auSp1QjrYOZQWWBve8VyjU4UJJP4jMYBeWoC72ipq
6Hugj48xYnrC8hSjxn0JeF2XtRT2kIJxS2HeVtPxNS8ca6sKuqHK+H5MjnS5vmM3
wZjJWuBUh5Rc9vYpaZAYBxcBOt6sM+XHRUzgV4FgF+z6mpyWenCV7/NIE4gFL1Fe
y37Jfk+HVOfbzp5XuG/o4mKhLMit0eAYd/cX9gxudpt6qfuVf2gsMyDIWkRu/ddq
CXIa8aqEESF3CTWwbmfcTsANDvdKJ6aGRqgry3F9fTHAA6VzUYU7uQoUviRobvVD
u4ZOo7U43hAzc0g+GFi4jbJIIqLdCp6srq+ydHgy12KwPqdW3msYv3BuWzSEXxSD
QodaraZg
=pQxS
-----END PGP SIGNATURE-----
```

被签名的文本为(commit.txt)：

```text
tree f93e3a1a1525fb5b91020da86e44810c87a2d7bc
author notfound <notfound@notfound.cn> 1637032587 +0800
committer notfound <notfound@notfound.cn> 1637032587 +0800

GPG test
```

### 验证签名

```text
$ gpg --verify gpgsig.txt commit.txt
gpg: Signature made 2021年11月16日 星期二 11时16分34秒 CST
gpg:                using RSA key 64D29C1A5D25743C4F9B0758FB65859A38C36152
gpg: Good signature from "notfound (tester) <notfound@notfound.cn>" [ultimate]
```

### 生成签名

```text
$ cat commit.txt | gpg --status-fd=2 -bsau 64D29C1A5D25743C4F9B0758FB65859A38C36152
[GNUPG:] KEY_CONSIDERED 64D29C1A5D25743C4F9B0758FB65859A38C36152 2
[GNUPG:] BEGIN_SIGNING H10
[GNUPG:] SIG_CREATED D 1 10 00 1637032960 64D29C1A5D25743C4F9B0758FB65859A38C36152
-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEEZNKcGl0ldDxPmwdY+2WFmjjDYVIFAmGTJAAACgkQ+2WFmjjD
YVLGcgv/b+65unPl2vQd1EPFYCBZXfKtEQWSqNOzCHmoUp0giv0dTaGHVdVVGgJm
OE9R1qG2vWL0P8ANSii49Oz8mUL3kA1TwiEQ7RFfwgTJWf7TvkLJijsMnB9hd0yB
wc95XwoIbXxTq3cAPTpwYVnzjLxQBYAiVuKzNsnIsNjTytCPnGfWnyfmE1vVrCJr
YH4tc+DBugow5fNoEJpdVK5UbW8vZty3BH9NwDpXNz9assH2heaKS4DEyUm9oxge
15QvOvSJVuBCDouXmO0f0+G2MHJwAS5CoDrxd+PFKqnjI3l6D355Snx0krK9WSCn
iMCRrlwOANEX+kFXE03o0FGp+bRRyU8YDfJQ2+rVmUS7q1pTTuN+USC4xgjjt9wS
AiCEymLtDDHsYXdX2mm3+TdVqSGVw8p+VgSuAUmSn//zW7CbaxiH+x8YkCuOlh53
n0t80IEHsZhpzmyhzTemvw24myssV651BNuZH75CwdN73ztMKF4IiI4/VDIGQbfw
ngr2VUXo
=9WhE
-----END PGP SIGNATURE-----
```
- `status-fd` 将状态信息打印到 stderr(2)
- `b(detach-sign)` 内容和签名分离
- `s(sign)` 签名
- `a(armor)` 输出ASCII 文本
- `u(local-user)`: 用户名或者 KEY ID

参考 https://github.com/git/git/blob/v2.34.0/gpg-interface.c#L854

## GitHub GPG 公钥

-   GPG 公钥包含的邮箱与用户已激活邮箱一致，GPG 公钥才能验证通过。
-   提交的 committer 邮箱包含在验证通过的 GPG 公钥中，提交才能验证通过。而本地使用 git 命令查看签名时只会验证签名是否有效，不会对邮箱进行验证。

## X.509 (gpgsm)

### 生成自签名证书

```bash
gpgsm --generate-key --output=notfound.cn.pem
```
- `-output` 将证书信息保存到 `notfound.cn.pem`

创建自签名证书，输入内容如下：

```text
Create self-signed certificate? (y/N) y
These parameters are used:
    Key-Type: RSA
    Key-Length: 3072
    Key-Usage: sign, encrypt
    Serial: random
    Name-DN: CN=notfound.cn
    Name-Email: notfound@notfound.cn
    Name-DNS: notfound.cn
    Name-URI: notfound.cn
```

### 导入证书

```
gpgsm --import notfound.cn.pem
```

查看证书列表:

```bash
gpgsm --list-keys
```

输出结果：

```text
           ID: 0x6A5ECD01
          S/N: 2FECBBE7B6829327
       Issuer: /CN=notfound.cn
      Subject: /CN=notfound.cn
          aka: (uri notfound.cn)
          aka: (dns-name notfound.cn)
          aka: notfound@notfound.cn
     validity: 2021-11-25 09:30:23 through 2063-04-05 17:00:00
     key type: 3072 bit RSA
    key usage: digitalSignature nonRepudiation keyEncipherment dataEncipherment
 chain length: unlimited
  fingerprint: 64:3B:BC:23:AC:6A:67:04:5C:EF:31:8B:C9:A6:6A:A7:6A:5E:CD:01
```

### 添加到信任列表

#### 方法1: 尝试签名

```bash
gpgsm -bsau 0x6A5ECD01 --sign README.md
```

利用弹出框，自动添加

#### 方法2: 手动添加

编辑 `~/.gnupg/gpg-agent.conf`

```text
# CN=notfound.cn
64:3B:BC:23:AC:6A:67:04:5C:EF:31:8B:C9:A6:6A:A7:6A:5E:CD:01 S relax
```

之后重新加载 `gpg-agent`

```bash
gpgconf --reload gpg-agent
```

### 配置 Git

```
git config gpg.format x509
git config user.signingKey 0x6A5ECD01
```

## SSH 签名

- Git 2.34+

### 配置

```bash
# 签名格式 ssh
git config gpg.format ssh

# 签名私钥路径
git config user.signingKey ~/.ssh/id_ed25519

# 信任的公钥列表，验证时使用
git config gpg.ssh.allowedSignersFile  ~/.ssh/allowed_signers_file
```

文件 `~/.ssh/allowed_signers_file` 格式如：

```text
notfound@notfound.cn ssh-rsa AAAAX1...
```

## 参考

- http://git-scm.com/docs/git-config
