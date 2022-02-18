---
title: "Linux Varnish Config"
date: 2022-02-17T13:58:27+08:00
tags: ["tool", "linux", "http"]
draft: true
---

## 参数
    
systemd 文件默认参数如下：

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
- `-t TTL` 缓存对象默认生存时间，默认为 120s

### 存储后端


可配置为内存或者文件存储。[官方文档](https://varnish-cache.org/docs/6.0/users-guide/storage-backends.html)

`malloc[,size]` 通过内存存储对象，内存不足时会使用交换分区，如 `malloc,256m`。
- `size` 内存限制大小

`file,path[,size[,granularity[,advice]]]`  将对象存储在由磁盘，通过 mmap 访问。
- `path` 文件路径。
  - 指定 `path` 未指定 `size` 时，将会使用已存在的文件大小
  - 指定 `size` 且文件已经存在，则文件将会被截断或者扩充。
  - 指定 `path` 和 `size` 时，文件会创建
- `granularity` 分配粒度，字节为单位。默认为 VM 页面大小
- `advice` 如何使用映射区域，以便内和可以选择适当的预读和缓存技术。可能的值为 `normal` `random` 以及 `sequential`。默认为 `random`。Linux 系统上，大对象以及机械硬盘选择 `sequential` 可能会受益。

### 缓存大小


通过 `sudo varnishstat` 观察 `n_lru_nuked` 计数器，观察是否有大量对象被淘汰。[官方文档](https://varnish-cache.org/docs/6.0/users-guide/sizing-your-cache.html)

## 命令

### varnishstat

```bash
sudo varnishstat
```

- `MAIN.cache_hit` 缓存命中计数
- `MAIN.cache_miss` 缓存未命中数
- `MAIN.threads` 线程池中线程总数
- `MAIN.n_object` 缓存中的 HTTP 对象（标头 + 正文，如果存在）的近似数量。
- `MAIN.n_lru_nuked` 有多少对象被强制从存储中驱逐，以便为新对象腾出空间。
- `SMA.s0.g_bytes` 从存储中分配的字节数
- `SMA.s0.g_space` 存储中剩余的字节数


### varnishtop

```bash
sudo varnishtop
# 查看 URL 列表
sudo varnishtop -i ReqURL
# 查看 User-Agent
sudo varnishtop -C -I ReqHeader:User-Agent
```

## 头部

Varnish 会添加 HTTP 方便排查问题：

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
- `Age` 对象在 Varnish 中保存的时间，单位秒
- `Via` 缓存服务名称和版本

### 添加自定义 HTTP 头部

编辑 `/etc/varnish/default.vcl`：

```vcl
sub vcl_recv {
    # 接收到客户端请求
    unset req.http.X-Cache;
}

sub vcl_deliver {
    set resp.http.X-Cache = req.http.X-Cache;
    set resp.http.Via = "1.1 varnish";
    unset resp.http.X-Varnish;
}

sub vcl_hit {
    # 命中缓存
    set req.http.X-Cache = "HIT";
}

sub vcl_miss {
    # 未命中缓存
    set req.http.X-Cache = "MISS";
}

sub vcl_pass {
    set req.http.X-Cache = "PASS";
}
```

- 添加 HTTP 头部 `X-Cache: HIT`
- 隐藏版本号
- 移除头部 `X-Varnish`


[状态说明](https://varnish-cache.org/docs/6.0/reference/states.html)


## 多后端服务器

directors 可将多个后端作为一组后端。

编辑 `/etc/varnish/default.vcl`：

```vcl
import directors;

backend s1 {
    .host = "127.0.0.1";
    .port = "8080";
}

backend s2 {
    .host = "127.0.0.1";
    .port = "8081";
}

sub vcl_init {
    new bar = directors.round_robin();
    bar.add_backend(s1);
    bar.add_backend(s2);
}

sub vcl_recv {
    set req.backend_hint = bar.backend();
}
```
- round_robin 轮询

[官方文档](https://varnish-cache.org/docs/6.0/users-guide/vcl-backends.html)

## 参考

- <https://varnish-cache.org/docs/6.0/reference/varnishd.html>
- <https://varnish-cache.org/docs/6.0/reference/states.html>
- <https://varnish-cache.org/docs/6.0/users-guide/increasing-your-hitrate.html>
- <https://docs.varnish-software.com/tutorials/hit-miss-logging>
- <https://www.varnish-software.com/developers/tutorials/multiple-backends>
