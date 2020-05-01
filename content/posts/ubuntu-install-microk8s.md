+++
title = "Ubuntu 安装配置 microk8s"
author = ["notfound"]
date = 2018-11-10T15:31:00+08:00
tags = ["kubernetes"]
draft = false
+++

系统环境：Ubuntu 18.04

为方便本地开发 Kubernete，Ubuntu 提供了 [microk8s](https://microk8s.io/)。

## 安装

```shell
sudo snap install microk8s --classic
```

## 查看 microk8s 服务状态

```shell
systemctl status snap.microk8s.daemon-docker.service
```

## 设置 http 代理

由于众所周知的原因，Kubernetes 无法拉去镜像，可通过设置 http 代理来解决。

在 Linux 中可通过环境变量 `http_proxy` 或 `https_proxy` 设置 http(s) 代理。microk8s 是通过 systemd 管理的，因此可在 systemd 配置文件传入环境变量。

http 转发服务可使用 `privoxy` 。

编辑 `/etc/systemd/system/snap.microk8s.daemon-docker.service` ，添加环境变量：

```conf
[Service]
Environment=http_proxy="http://127.0.0.1:8118"
Environment=https_proxy="http://127.0.0.1:8118"
```

## 重启服务

```shell
sudo systemctl daemon-reload
sudo systemctl restart snap.microk8s.daemon-docker.service
```

## 参考

- microk8s <https://microk8s.io/>
- 命令行配置代理服务器 <https://yevon-cn.github.io/2017/05/05/set-proxy-of-cmd.html>
