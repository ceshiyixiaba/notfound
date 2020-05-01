---
title: "GPG 使用"
date: 2019-02-16T22:19:00+08:00
tags: ["gpg"]
categories: [""]
draft: false
---

- Ubuntu

本文仅介绍 GPG 基本的使用。

## 安装 GPG 2.x

需要确保使用 GnuPG 2.x

```bash
sudo apt install gnupg2 # Ubuntu 16.04
sudo apt install gnupg  # Ubuntu 18.04
```

## 生成密钥（快速）

一次生成多个密钥：

```bash
gpg --full-generate-key
```

## 生成密钥（分步）

### 1. 生成主密钥

```bash
gpg --quick-generate-key 'NotFound <notfound@notfound.cn>' rsa4096 cert
```

输出：

```text
pub   rsa4096 2019-02-16 [C] [有效至：2021-02-15]
      E609071A680F01521759F2AD6845FD9F1A3352AF
uid                      NotFound <notfound@notfound.cn>
```

- `E609071A680F01521759F2AD6845FD9F1A3352AF` 为密钥 ID，分为三种形态：
  - 指纹：完整的 40 个字符的密钥标识符
  - 长密钥 ID：指纹的最后 16 个字符
  - 短密钥 ID：指纹的最后 8 个字符
- uid 为身份，可以拥有多个身份，其中第一个为主 UID

### 2. 生成子密钥

```bash
gpg --quick-add-key E609071A680F01521759F2AD6845FD9F1A3352AF rsa2048 encr # [E]加密子密钥
gpg --quick-add-key E609071A680F01521759F2AD6845FD9F1A3352AF rsa2048 sign # [S]签名子密钥
gpg --quick-add-key E609071A680F01521759F2AD6845FD9F1A3352AF rsa2048 auth # [A]验证子密钥
```

## 查看

查看 GPG Key 信息：

```bash
gpg --list-key E609071A680F01521759F2AD6845FD9F1A3352AF
gpg --with-keygrip --list-key E609071A680F01521759F2AD6845FD9F1A3352AF
gpg --with-subkey-fingerprint --list-key E609071A680F01521759F2AD6845FD9F1A3352AF
```

## UID(身份)

一个 GPG KEY 可以拥有多个UID。
添加 UID：

```bash
gpg --quick-add-uid E609071A680F01521759F2AD6845FD9F1A3352AF 'Found <found@notfound.cn>'
```

选择主 UID：

```bash
gpg --quick-set-primary-uid E609071A680F01521759F2AD6845FD9F1A3352AF "Found <found@notfound.cn>"
```

## 导入与导出

### 导出

```bash
# 导出公钥
gpg --export --armor --output public.gpg E609071A680F01521759F2AD6845FD9F1A3352AF
# 导出私钥
gpg --export-secret-key --armor --output private.gpg E609071A680F01521759F2AD6845FD9F1A3352AF
```

可以将导出的公钥添加到 GitHub\GitLab\Gitee 等

### 导入

```bash
# 导入公钥
gpg --import public.gpg
# 导入私钥
gpg --import --import-options restore private.gpg 
```

## 删除

```bash
# 删除私钥
gpg --delete-secret-key E609071A680F01521759F2AD6845FD9F1A3352AF
# 删除公钥
gpg --delete-key E609071A680F01521759F2AD6845FD9F1A3352AF
```
## 参考

[Linux 中国](https://linux.cn/)上有关于 PGP(GPG) 详细介绍，强烈推荐：
- [用 PGP 保护代码完整性（一）：基本概念和工具](https://linux.cn/article-9524-1-rel.html)
- [用 PGP 保护代码完整性（二）：生成你的主密钥](https://linux.cn/article-9529-1-rel.html)
- [用 PGP 保护代码完整性（三）：生成 PGP 子密钥](https://linux.cn/article-9607-1.html)
- [用 PGP 保护代码完整性（四）：将主密钥移到离线存储中](https://linux.cn/article-10402-1.html)
- [用 PGP 保护代码完整性（五）：将子密钥移到一个硬件设备中](https://linux.cn/article-10415-1.html)
- [用 PGP 保护代码完整性（六）：在 Git 上使用 PGP](https://linux.cn/article-10421-1.html)
- [用 PGP 保护代码完整性（七）：保护在线帐户](https://linux.cn/article-10432-1.html)

## 参考
