---
title: "Ubuntu 配置 DNS"
date: 2021-10-17T22:39:08+08:00
tags: ["linux"]
---

- Ubuntu 20.04

可通过 `resolvectl` 或者 `systemd-resolve` 对 DNS 进行配置。

## 通过 resolvectl

获取不同接口 DNS:

```bash
resolvectl dns
# 输出:
# Global: 192.168.1.254
# Link 2 (enp2s0):
```

设置 Link 2 的 DNS:

```bash
sudo resolvectl dns 2 119.29.29.29

resolvectl dns                    
# 输出:
# Global:
# Link 2 (wlp0s20f3): 119.29.29.29
```

## 通过 Systemd

查看 DNS 信息:

```bash
systemd-resolve --status
```

设置 Link 2 的 DNS:

```bash
sudo systemd-resolve --interface=2 --set-dns=119.29.29.29
```

设置全局 DNS:

```bash
# 编辑 DNS
sudo vim /etc/systemd/resolved.conf
# 重启 systemd-resolved，让配置生效
sudo service systemd-resolved restart
systemd-resolve --status
```

## 参考

- https://askubuntu.com/questions/973017/wrong-nameserver-set-by-resolvconf-and-networkmanager
