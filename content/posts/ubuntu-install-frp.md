+++
title = "使用 frp 实现内网穿透"
author = ["notfound"]
date = 2018-04-05T13:30:00+08:00
tags = ["frp"]
draft = false
+++

## 简介

[frp](https://github.com/fatedier/frp) 是一个可用于内网穿透的高性能的反向代理应用，支持 tcp, udp, http, https 协议。本文主要介绍如何使用 frp 搭建 http 和 ssh 服务。

## 工作过程

用户 -> 外网服务器(frps) -> 内网服务器(frpc)

![frp](/images/ubuntu-install-frp-architecture.png)

## 搭建

下载地址为: <https://github.com/fatedier/frp/releases> ，作者提供了不同平台的编译版本。

当前最新版本为 v0.16.1，本人环境为 Ubuntu 16.04，下载的版本为 [frp\_0.16.1\_linux\_amd64.tar.gz](https://github.com/fatedier/frp/releases/download/v0.16.1/frp%5F0.16.1%5Flinux%5Famd64.tar.gz)。

目录结构如下：

```text
.
├── frpc            # 内网服务器可执行程序
├── frpc.ini        # 内网服务器配置文件
├── frpc_full.ini   # 内网服务器完整配置文件
├── frps            # 外网服务器可执行程序
├── frps.ini        # 外网服务器配置文件
├── frps_full.ini   # 外网服务器完整配置文件
└── LICENSE
```

### 内网服务器

#### 文件

内网服务器只需要如下三个文件:

```text
.
├── frpc
├── frpc_full.ini
└── frpc.ini
```

#### 配置

`frpc.ini` 配置如下：

```ini
[common]
server_addr = x.x.x.x
server_port = 7000

# 第一个 web 服务，访问地址为: http://app1.example.com
[web01]
type = http
local_ip = 127.0.0.1
local_port = 3000
subdomain = app1

# 第二个 web 服务，访问地址为：http://app2.example.com
[web02]
type = http
local_ip = 127.0.0.1
local_port = 4000
subdomain = app2

# ssh 服务，访问方式为 ssh -oPort=6000 $USER@x.x.x.x
[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6000
```

- frpc 通过 `server_addr` (IP) 和 `server_port` (端口号) 与外网服务器(frps)建立网络连接
- web 配置可以通过 `subdomain` 指定子域名
- ssh 配置中 `remote_port` 是外网服务器(frps)监听端口号，用来提供 ssh 服务使用的端口。用户通过该端口与外网服务器(frps)建立网络连接，再由外网服务器(frps)将数据转发到内网服务器(frpc)

#### 启动

```shell
./frpc -c ./frpc.ini
```

### 外网服务器

#### 文件

外网服务器只需要如下三个文件：

```text
.
├── frps
├── frps_full.ini
└── frps.ini
```

#### 配置

`frps.ini` 配置如下：

```text
[common]
bind_port =7000
vhost_http_port = 8000

subdomain_host = example.com
```

- `bind_port` frps 监听端口号，用来与内网服务器（frpc）建立网络连接
- `vhost_http_port` frps 监听端口，用来与客户端（浏览器）建立网络连接
- `subdomain_host` 指定域名

通过域名和端口号 <http://example.com:8000> 可以访问该服务。

#### 启动

```shell
./frps -c ./frps.ini
```

#### 使用 nginx 转发

客户端（浏览器） -> 外网服务器（nginx[80 端口] -> frps[8000 端口]） -> 内网服务器(frpc)

```nginx
server {
    server_name app1.example.com;

    listen 80;
    listen [::]:80;

    root /var/www/html;
    index index.html;

    location / {
        proxy_set_header  Host $host:80;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_hide_header X-Powered-By;

        proxy_pass http://127.0.0.1:8000;
    }
}
```

### 效果

可用通过 <http://app1.example.com> 访问内网服务。

## 参考

- <https://github.com/fatedier/frp/blob/master/README%5Fzh.md>
