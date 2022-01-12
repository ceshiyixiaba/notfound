---
title: "使用 OpenSSL 生成 Nginx 证书"
date: 2021-11-21T08:11:40+08:00
lastmod: 2022-01-09T08:11:40+08:00
tags: ["nginx", "ssl", "linux"]
---

- fedora 35

## 自签名证书

1. 生成服务器私钥：
```bash
openssl genrsa -out example.com.key 2048
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

## 生成自签名 CA 证书

在目录 ssl 中执行操作

### CA


测试域名为 `example.com`

1. 创建 CA 目录：
```bash
mkdir -p demoCA/{certs,newcerts,crl,private}
touch demoCA/index.txt
echo "01" > demoCA/serial
```

2. 配置 openssl：
```bash
cp /etc/ssl/openssl.cnf .
sed -i 's/\/etc\/pki\/CA/demoCA/g' openssl.cnf
```
- CA 目录从 `/etc/pki/CA` 改为 `demoCA`

3. 生成 CA 私钥和证书：
```bash
openssl req -new -x509 -newkey rsa:2048 -keyout demoCA/private/cakey.pem \
  -out demoCA/cacert.pem -config openssl.cnf
```
- 输出目录与配置文件一致
- 注意输入域名 `Common Name (eg, your name or your server's hostname) []:example.com`

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
openssl genrsa -out example_com.key 2048
```

2. 生成证书签名请求：
```bash
openssl req -new -key example_com.key -out example_com.csr -config openssl.cnf
```
- 注意输入域名 `Common Name (eg, your name or your server's hostname) []: example.com`

3. 使用 CA 根证书签发客户端证书：
```bash
openssl ca -in example_com.csr -out example_com.crt -config openssl.cnf
```

## 多级证书

```bash
mkdir -p ssl/{ca_1,ca_2,client}
```

目录结构：

```ssl
├── ca_1
├── ca_2
└── client
```
### 根 CA

在目录 `ca_1` 中执行

1. 创建目录

```bash
mkdir -p demoCA/{certs,newcerts,crl,private}
```

2. 配置

```bash
cp /etc/ssl/openssl.cnf .
sed -i 's/\/etc\/pki\/CA/demoCA/g' openssl.cnf
touch demoCA/index.txt
echo "01" > demoCA/serial
```

修改 `openssl.cnf`

```diff
-x509_extensions        = usr_cert
+x509_extensions        = v3_ca
```

3. 生成私钥和证书

```bash
openssl req -config openssl.cnf \
  -new -x509 -newkey rsa:2048 \
  -keyout demoCA/private/cakey.pem \
  -out demoCA/cacert.pem
```

### 二级 CA

在目录 `ca_2` 中执行

1. 创建目录

```bash
mkdir -p demoCA/{certs,newcerts,crl,private} 
```

2. 配置

```bash
cp /etc/ssl/openssl.cnf .
sed -i 's/\/etc\/pki\/CA/demoCA/g' openssl.cnf
touch demoCA/index.txt
echo "01" > demoCA/serial
```

3. 生成私钥和证书请求

```bash
openssl genrsa -out demoCA/private/cakey.pem 2048
openssl req -config openssl.cnf \
  -new -key demoCA/private/cakey.pem \
  -out second.csr
```

#### 二级 CA 签名

通过根  CA 对二级 CA 证书请求进行签名，在目录 `ca_1` 中执行

```bash
openssl ca -config openssl.cnf -in ../ca_2/second.csr -out ../ca_2/demoCA/cacert.pem
```

### 客户端

在目录 `client` 中执行

```bash
cp /etc/ssl/openssl.cnf .
openssl genrsa -out client.key 2048
openssl req -config openssl.cnf -new -key client.key -out client.csr
```

#### 客户端签名

在目录 `ca_2` 中执行

```bash
openssl ca -config openssl.cnf \
  -in ../client/client.csr -out ../client/client.crt 
```

## 配置 Nginx

```nginx
server {
  listen       443 ssl http2;
  listen       [::]:443 ssl http2;
  server_name  client.example.com;

  ssl_certificate client.crt;
  ssl_certificate_key client.key;
  # ...
}
```

配置多级证书时，需要将中间证书也添加到 `client.crt`，该文件包含两个证书：ca_2 和 client。也就是将 `ca_2/demoCA/cacert.pem` 和 `client/client.crt` 两个文件中的 `-----BEGIN CERTIFICATE-----` 和 `-----END CERTIFICATE-----` 部分放到同一个文件。根证书是可选的。

测试证书有效性

```bash
openssl s_client -connect client.example.com:443
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
