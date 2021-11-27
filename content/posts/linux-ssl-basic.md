---
title: "SSL 证书格式与转换"
date: 2021-11-27T15:04:03+08:00
tags: ["ssl"]
---

- [X.509](https://zh.wikipedia.org/wiki/X.509) 公钥证书的标准格式

## 编码

也用作文件扩展名

- `DER` 二进制编码，用于证书。可能带有`.cer`或者`.crt`的扩展名
- `PEM` Base64 编码，用于证书、私钥
- `PFX(PKCS#12)` 二进制编码，同时包含证书和私钥

## 文件扩展名

- `.der` `.cer` 二进制格式，只保存证书，不保存私钥
- `.crt` 二进制或文本格式，只保存证书，不保存私钥
- `.pem` 文本格式，可保存证书、私钥，或者都包含
- `.key` 文本格式，仅保存私钥
- `.pfx` `.p12` 二进制格式，同时包含证书和私钥

## 转换

PEM 转换为 DER：
```bash
openssl x509 -in demoCA/cacert.pem -outform der -out demoCA/cacert.der
```

DER 转换为 PEM：
```bash
openssl x509 -in demoCA/cacert.der -inform der -outform pem -out cert.pem
```

PEM 转换为 PKCS12：
```bash
openssl pkcs12 -inkey demo.ca.test.key -in demo.ca.test.crt --export --out demo.ca.test.pfx
```

PKCS12 转换为 PEM：
```bash
openssl pkcs12 -in demo.ca.test.pfx -out for-iis.pem -nodes
```

## 查看

查看 DER 格式证书：
```bash
openssl x509 -in demoCA/cacert.der -inform der -text -noout
```

查看 PEM 格式证书：
```bash
openssl x509 -in demoCA/cacert.pem -text -noout
```

查看 PKCS12 ：
```bash
openssl pkcs12 -in demo.ca.test.pfx 
```

## 参考

- https://blog.freessl.cn/ssl-cert-format-introduce/
- https://zh.wikipedia.org/wiki/PKCS_12
