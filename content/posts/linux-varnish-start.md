---
title: "Ubuntu 安装 varnish LTS"
date: 2022-02-16T17:57:10+08:00
tags: ["tool", "linux", "http"]
---

- 环境 Ubuntu 20.04

varnish 6.0.x 为长期支持版，而系统自带的版本 6.2.x 并非长期支持版，详情可查看[发行说明](https://varnish-cache.org/releases/)。

## 安装 varnish 6.0.x LTS

官方通过 packagecloud 维护 varnish 安装包。

1. 添加公钥：
```bash
curl -s -L https://packagecloud.io/varnishcache/varnish60lts/gpgkey | sudo apt-key add -
```

2. 添加源，并提升源的优先级：

```bash
. /etc/os-release
sudo tee /etc/apt/sources.list.d/varnishcache_varnish60lts.list > /dev/null <<-EOF
deb https://packagecloud.io/varnishcache/varnish60lts/$ID/ $VERSION_CODENAME main
EOF
sudo tee /etc/apt/preferences.d/varnishcache > /dev/null <<-EOF
Package: varnish varnish-*
Pin: release o=packagecloud.io/varnishcache/*
Pin-Priority: 1000
EOF
```

3. 安装
```bash
sudo apt update
sudo apt install varnish
# 检查版本
varnishd -V
```

## 启动

varnishd 通过 systemd 管理。

```bash
sudo systemctl status varnish.service
sudo systemctl start varnish.service
sudo systemctl reload varnish.service
sudo systemctl restart varnish.service
sudo systemctl stop varnish.service
```

## 配置

```bash
# 修改默认编辑器
sudo update-alternatives --config editor
# 编辑 systemd 配置文件
sudo systemctl edit --full varnish
# 修改配置后重启
sudo systemctl restart varnish.service
```
- 通过 systemd 配置文件可修改端口、缓存大小


编辑文件 `/etc/varnish/default.vcl`：

```vcl
backend default {
    .host = "127.0.0.1";
    .port = "8080";
}
```
- 可修改后端服务

## 测试

```bash
$ curl -I http://localhost:6081
# HTTP/1.1 503 Backend fetch failed
# Date: Thu, 17 Feb 2022 03:50:14 GMT
# Server: Varnish
# Content-Type: text/html; charset=utf-8
# Retry-After: 5
# X-Varnish: 17
# Age: 0
# Via: 1.1 varnish (Varnish/6.0)
# Content-Length: 279
# Connection: keep-alive
```

## 参考

- <https://www.varnish-software.com/developers/tutorials/installing-varnish-ubuntu/>
