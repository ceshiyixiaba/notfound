---
title: "Linux 配置 DNS"
date: 2021-10-17T22:39:08+08:00
lastmod: 2022-01-04T11:14:08+08:00
tags: ["linux"]
---

- Ubuntu 20.04
- Fedora 35

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
# Link 2 (enp2s0): 119.29.29.29
```

- 重启后失效

## 通过 Systemd

查看 DNS 信息:

```bash
systemd-resolve --status
```

设置 Link 2 的 DNS:

```bash
sudo systemd-resolve --interface=2 --set-dns=119.29.29.29
```

- 重启后失效

### 设置全局 DNS

编辑文件 `/etc/systemd/resolved.conf`：

```conf
[Resolve]
DNS=192.168.1.60
FallbackDNS=119.29.29.29
```

重启 systemd-resolved，让配置生效

```text
sudo systemctl restart systemd-resolved.service
```

- 重启后不会失效

## netplan

Ubuntu 20.04 desktop 使用 netplan 管理网络。

编辑 `/etc/netplan/01-network-manager-all.yaml`:

```yaml
# Let NetworkManager manage all devices on this system
# network:
#   version: 2
#   renderer: NetworkManager
network:
  version: 2
  ethernets:
     enp2s0:
        dhcp4: true
        nameservers:
          addresses: [119.29.29.29]
```

先测试配置是否正确，尝试应用配置：

```bash
sudo netplan try
```

测试无误后，应用配置：

```bash
sudo netplan apply
```

## 参考

- https://askubuntu.com/questions/973017/wrong-nameserver-set-by-resolvconf-and-networkmanager
- https://netplan.io/
- https://www.tecmint.com/set-static-ip-address-in-ubuntu/
