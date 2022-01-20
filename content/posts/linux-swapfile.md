---
title: "Linux Swapfile"
date: 2022-01-19T15:26:50+08:00
tags: [""]
categories: [""]
draft: true
---

```bash
sudo swapoff -v /swapfile
sudo rm /swapfile


sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon --show
```

```fstab
/swapfile                                 none            swap    sw              0       0
```

## 参考

- https://linuxize.com/post/create-a-linux-swap-file/
