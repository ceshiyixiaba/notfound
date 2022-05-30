---
title: "Linux 使用 efibootmgr 管理 UEFI"
date: 2022-05-03T10:32:32+08:00
tags: ["linux"]
---

- Ubuntu 22.04

## 安装

```bash
sudo apt install efibootmgr
```

## 操作

### 查看引导项

```text
$ efibootmgr
BootCurrent: 0002
Timeout: 0 seconds
BootOrder: 0002,0003,2001,2002,2003,0000
Boot0000* Fedora
Boot0002* ubuntu
Boot0003* Windows Boot Manager
Boot2001* EFI USB Device
Boot2002* EFI DVD/CDROM
Boot2003* EFI Network
```

### 删除引导项

```text
$ sudo efibootmgr -b 0000 -B
BootCurrent: 0002
Timeout: 0 seconds
BootOrder: 0002,0003,2001,2002,2003
Boot0002* ubuntu
Boot0003* Windows Boot Manager
Boot2001* EFI USB Device
Boot2002* EFI DVD/CDROM
Boot2003* EFI Network
Boot2004* Huawei Firmware Update Program
```
- `-b` 指定引导项
- `-B` 删除引导项

## 参考

- <https://www.linuxbabe.com/command-line/how-to-use-linux-efibootmgr-examples>
