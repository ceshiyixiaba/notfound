---
title: "监控 socket 连接数"
date: 2020-05-18T20:20:37+08:00
lastmod: 2022-02-22T16:50:07+08:00
tags: ["monitoring", "ruby"]
categories: ["monitoring"]
draft: false
---

- 系统环境 Ubuntu 18.04

通过 gem [raindrops](https://gems.ruby-china.com/gems/raindrops) 可以获取连接数量，包括正在建立的连接数和已完成的连接数。

## 连接数

包括两种连接: UNIX domain socket 和 TCP socket。

### UNIX domain socket

####  用法

```ruby
require 'raindrops'

paths = ['/run/containerd/containerd.sock']
Raindrops::Linux.unix_listener_stats(paths)
# {"/run/containerd/containerd.sock"=>#<struct Raindrops::ListenStats active=2, queued=0>}
```

active=2, queued=0

#### 原理

UNIX domain sockets 连接信息保存在 `/proc/net/unix` 中，需要解析该文件。

如：

```text
$ cat /proc/net/unix | grep "containerd.sock"
  Num             RefCount Protocol Flags   Type  St Inode Path
0000000000000000: 00000002 00000000 00010000 0001 01 26912 /run/containerd/containerd.sock
0000000000000000: 00000003 00000000 00000000 0001 03 31496 /run/containerd/containerd.sock
0000000000000000: 00000003 00000000 00000000 0001 03 28660 /run/containerd/containerd.sock
```

每个字段的含义，可以参考 `man 5 proc`：

```man
The fields are as follows:

Num:      the kernel table slot number.
RefCount: the number of users of the socket.
Protocol: currently always 0.
Flags:    the internal kernel flags holding the status of the socket.
Type:     the socket type.  For SOCK_STREAM sockets, this is 0001; for SOCK_DGRAM sockets, it is  0002;  and  for  SOCK_SEQ‐
          PACKET sockets, it is 0005.
St:       the internal state of the socket.
Path:     the  bound path (if any) of the socket.  Sockets in the abstract namespace are included in the list, and are shown
          with a Path that commences with the character '@'.
```

因此可以通过字段 `St` 获取连接状态信息，man page 中没有说明数字的具体含义，好在[raindrops 源码注释](https://yhbt.net/raindrops.git/tree/lib/raindrops/linux.rb#n19)中有提到：

```text
Get ListenStats from an array of +paths+

Socket state mapping from integer => symbol, based on socket_state
enum from include/linux/net.h in the \Linux kernel:
    typedef enum {
            SS_FREE = 0,              /* not allocated                */
            SS_UNCONNECTED,           /* unconnected to any socket    */
            SS_CONNECTING,            /* in process of connecting     */
            SS_CONNECTED,             /* connected to socket          */
            SS_DISCONNECTING          /* in process of disconnecting  */
    } socket_state;
* SS_CONNECTING maps to ListenStats#queued
* SS_CONNECTED maps to ListenStats#active
```

所以 `St` 数字的含义为：
- `2` 正在连接
- `3` 连接已建立

### TCP socket

#### 用法

```ruby
require 'raindrops'

Raindrops::Linux.tcp_listener_stats("127.0.0.1:6379")
# {"127.0.0.1:6379"=>#<struct Raindrops::ListenStats active=1, queued=0>}
```

#### 原理

从源码来看，是使用 `recvmsg` 向内核发送消息来获取 socket 的信息，看起来有点复杂，至少 man page 没有介绍，暂且搁置。

### 其他

通过 `lsof` 命令也可以看到每个连接状态信息：

```text
$ sudo lsof -i:6379
COMMAND    PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
redis-ser 1035 redis    6u  IPv4  25872      0t0  TCP localhost:6379 (LISTEN)
redis-ser 1035 redis    7u  IPv6  25877      0t0  TCP ip6-localhost:6379 (LISTEN)
redis-ser 1035 redis    8u  IPv4  67074      0t0  TCP localhost:6379->localhost:59232 (ESTABLISHED)
redis-cli 6313 me       3u  IPv4  70052      0t0  TCP localhost:59232->localhost:6379 (ESTABLISHED)
```

## 参考

- [raindrops](https://yhbt.net/raindrops.git)
- [Netlink编程-使用NETLINK_INET_DIAG协议](http://edsionte.com/techblog/archives/4140)
- [netlink 编程介绍(V0.2)](http://www.cnitblog.com/chlclan/archive/2006/06/20/12546.aspx)
