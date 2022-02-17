---
title: "Linux Varnish Config"
date: 2022-02-17T13:58:27+08:00
tags: ["tool", "linux", "http"]
draft: true
---

## 参数

```bash
ExecStart=/usr/sbin/varnishd \
      -a :6081 \
      -a localhost:8443,PROXY \
      -p feature=+http2 \
      -f /etc/varnish/default.vcl \
      -s malloc,256m
```
- `-a` 监听地址
- `-f` VCL 文件路径 
- `-s` 后端存储
  - `malloc` 通过内存存储对象，内存不足是会使用交换分区。限制大小为 256m。

## 存储后端

[官方文档](https://varnish-cache.org/docs/6.0/users-guide/storage-backends.html)

### malloc

`malloc[,size]` 通过内存存储对象，内存不足时会使用交换分区。
- `size` 内存限制大小

如 `malloc,256m`。

### file

`file,path[,size[,granularity[,advice]]]`  将对象存储在由磁盘，通过 mmap 访问。
- `path` 文件路径。
  - 指定 `path` 未指定 `size` 时，将会使用已存在的文件大小
  - 指定 `size` 且文件已经存在，则文件将会被截断或者扩充。
  - 指定 `path` 和 `size` 时，文件会创建
- `granularity` 分配粒度，字节为单位。默认为 VM 页面大小
- `advice` 如何使用映射区域，以便内和可以选择适当的预读和缓存技术。可能的值为 `normal` `random` 以及 `sequential`。默认为 `random`。Linux 系统上，大对象以及机械硬盘选择 `sequential` 可能会受益。

<https://varnish-cache.org/docs/6.0/users-guide/sizing-your-cache.html>

### 调整缓存大小

<https://varnish-cache.org/docs/6.0/users-guide/sizing-your-cache.html>

通过 `sudo varnishstat` 观察 `n_lru_nuked` 计数器，观察是否有大量对象被淘汰。

## 头部

```http
HTTP/1.1 200 OK
Content-Type: text/html;charset=utf-8
Content-Length: 7
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Server: thin 1.5.1 codename Straight Razor
Date: Thu, 17 Feb 2022 08:55:48 GMT
X-Varnish: 98417 98405
Age: 35
Via: 1.1 varnish (Varnish/6.0)
Accept-Ranges: bytes
Connection: keep-alive
```
- `X-Varnish` 当前请求 ID 和填充缓存的请求 ID
- `Age` 对象在 Varnish 中保存的时间

### 配置 HIT 和 MISS

添加 HTTP 头部 `X-Cache: HIT`

```vcl
sub vcl_recv {
    unset req.http.X-Cache;
}

sub vcl_deliver {
    set resp.http.X-Cache = req.http.X-Cache;
}

sub vcl_hit {
    set req.http.X-Cache = "HIT";
}

sub vcl_miss {
    set req.http.X-Cache = "MISS";
}

sub vcl_pass {
    set req.http.X-Cache = "PASS";
}
```

## 参考

- <https://docs.varnish-software.com/tutorials/hit-miss-logging/>
