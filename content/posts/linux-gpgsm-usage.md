---
title: "Linux gpgsm 使用"
date: 2021-11-26T09:59:36+08:00
tags: ["gpg","gpgsm"]
---

- Ubuntu 20.04

## 生成自签名证书

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
```

## 导入证书

```bash
gpgsm --import notfound.cn.pem
```

查看证书列表:

```bash
gpgsm --list-keys
```

输出结果：

```text
           ID: 0xD4C585CE
          S/N: 4D22E0B20A614E91
       Issuer: /CN=notfound.cn
      Subject: /CN=notfound.cn
          aka: notfound@notfound.cn
     validity: 2021-11-26 02:49:05 through 2063-04-05 17:00:00
     key type: 3072 bit RSA
    key usage: digitalSignature nonRepudiation keyEncipherment dataEncipherment
 chain length: unlimited
  fingerprint: 32:C8:B0:FC:89:E7:5C:77:27:F9:64:39:0B:D6:75:B7:D4:C5:85:CE
```

## 添加到信任列表

### 方法 1: gpgsm 签名时添加

利用 gpgsm 弹出框，自动添加

```bash
gpgsm -bsau 0xD4C585CE --sign README.md
```
- `b(detach-sign)` 内容和签名分离
- `s(sign)` 签名
- `a(armor)` 输出ASCII 文本
- `u(local-user)`: KEY ID

### 方法 2: 手动添加

编辑文件 `~/.gnupg/trustlist.txt`

```text
# CN=notfound.cn
32:C8:B0:FC:89:E7:5C:77:27:F9:64:39:0B:D6:75:B7:D4:C5:85:CE S relax
```
- 指纹
- `S` 一个标识，作用未知
- `relax` 放宽对根证书的检查

重新加载 `gpg-agent`

```bash
gpgconf --reload gpg-agent
```

## 参考

- `info gpgsm`
