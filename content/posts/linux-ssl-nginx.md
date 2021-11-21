---
title: "使用 OpenSSL 生成 Nginx 证书"
date: 2021-11-21T08:11:40+08:00
tags: ["nginx"]
---

- fedora

## 自签名证书

1. 生成服务器私钥：

```bash
openssl genrsa -out example.com.key 4096
```

2. 生成证书签名请求：

```bash
openssl req -new -key example.com.key -out example.com.csr
```
- `Common Name (eg, your name or your server's hostname)` 填写域名 `example.com`

3. 使用证书签名请求以及私钥签发证书

```bash
openssl x509 -req -days 365 -in example.com.csr -signkey example.com.key -out example.com.crt
```

4. 配置 Nginx

```nginx
server {
  listen       443 ssl http2;
  listen       [::]:443 ssl http2;
  server_name  example.com;

  ssl_certificate example.com.crt;
  ssl_certificate_key example.com.key;
  # ...
}
```
## 参考

- [如何用 OpenSSL 创建自签名证书](https://docs.azure.cn/zh-cn/articles/azure-operations-guide/application-gateway/aog-application-gateway-howto-create-self-signed-cert-via-openssl)
- http://nginx.org/en/docs/http/configuring_https_servers.html
