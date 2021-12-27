---
title: "Linux GRUB2"
date: 2021-12-01T09:58:09+08:00
tags: ["linux"]
draft: true
---

## 更新 grub.cfg

- fedora 35

```bash
sudo grub2-mkconfig -o /etc/grub2.cfg
sudo grub2-mkconfig -o /etc/grub2-efi.cfg
```

fedora 34+ 不要执行 `grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg`，该文件会使用 `/boot/grub2/grub.cfg`：

```bash
$ cat /boot/efi/EFI/fedora/grub.cfg
search --no-floppy --fs-uuid --set=dev 70ae6847-1c61-49f9-a09a-d5c65d04de28
set prefix=($dev)/boot/grub2

export $prefix
configfile $prefix/grub.cfg
```

参考：
- https://fedoraproject.org/wiki/GRUB_2#Updating_the_GRUB_configuration_file

