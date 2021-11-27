---
title: "使用 OpenSSL 生成 Nginx 证书"
date: 2021-11-21T08:11:40+08:00
tags: ["nginx", "ssl"]
---

- fedora 35

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

## 生成自签名 CA 证书


### CA

测试域名为 `ca.test` 以及 `demo.ca.test`

1. 创建 CA 目录：

```bash
mkdir -p ~/ssl/demoCA/{certs,newcerts,crl,private}
cd ~/ssl/demoCA
touch index.txt
echo "01" > serial
```

2. 配置 ssl：

```bash
cp /etc/ssl/openssl.cnf ~/ssl/openssl.cnf
sed -i 's/\/etc\/pki\/CA/demoCA/g' openssl.cnf
```
- CA 目录从 `/etc/pki/CA` 改为 `demoCA`

3. 生成 CA 私钥和证书：

```bash
openssl req -new -x509 -newkey rsa:4096 -keyout demoCA/private/cakey.pem \
  -out demoCA/cacert.pem -config openssl.cnf
```
- 输出目录与配置文件一致
- 注意输入域名 `Common Name (eg, your name or your server's hostname) []:ca.test`

4. 查看 key 和证书：

```bash
# 查看 rsa 私钥
openssl rsa -noout -text -in demoCA/private/cakey.pem
# 查看证书
openssl x509 -noout -text -in demoCA/cacert.pem
```

目录结构

```
ssl
├── demoCA
│   ├── cacert.pem
│   ├── certs
│   ├── crl
│   ├── index.txt
│   ├── newcerts
│   ├── private
│   │   └── cakey.pem
│   └── serial
└── openssl.cnf
```

### 客户端

1. 生成客户端私钥：
```bash
openssl genrsa -out demo.ca.test.key 4096
```

2. 生成证书签名请求：
```bash
openssl req -new -key demo.ca.test.key -out demo.ca.test.csr -config openssl.cnf
```
- 注意输入域名 `Common Name (eg, your name or your server's hostname) []: demo.ca.test`

3. 使用 CA 根证书签发客户端证书：

```bash
openssl ca -in demo.ca.test.csr -out demo.ca.test.crt -config openssl.cnf
```

目录结构


```text
.
├── demoCA
│   ├── cacert.pem
│   ├── certs
│   ├── crl
│   ├── index.txt
│   ├── index.txt.attr
│   ├── index.txt.old
│   ├── newcerts
│   │   └── 01.pem
│   ├── private
│   │   └── cakey.pem
│   ├── serial
│   └── serial.old
├── demo.ca.test.crt
├── demo.ca.test.csr
├── demo.ca.test.key
└── openssl.cnf
```

### 配置 Nginx

```nginx
server {
  listen       443 ssl http2;
  listen       [::]:443 ssl http2;
  server_name  demo.ca.test;

  ssl_certificate demo.ca.test.crt;
  ssl_certificate_key demo.ca.test.key;
  # ...
}
```

## 添加 CA 到 Linux 系统

- fedora 35

```bash
sudo cp demoCA/cacert.pem /usr/share/pki/ca-trust-source/anchors/
sudo update-ca-trust
```
- curl、Firefox 可生效, 但 Chrome 依旧有警告

## 参考

- https://docs.azure.cn/zh-cn/articles/azure-operations-guide/application-gateway/aog-application-gateway-howto-create-self-signed-cert-via-openssl
- https://nginx.org/en/docs/http/configuring_https_servers.html
- https://docs.fedoraproject.org/en-US/quick-docs/using-shared-system-certificates/
