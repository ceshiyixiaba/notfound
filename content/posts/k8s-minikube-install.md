---
title: "Minikube 安装"
date: 2021-10-08T11:27:56+08:00
tags: ["kubernetes"]
draft: false
---

系统环境 Manjaro Linux

## 安装

### docker

```bash
sudo pacman -Sy docker
```
- 安装 docker

```bash
sudo usermod -aG docker $USER
```
- 将当前用户添加到 docker 组，避免每次执行 docker 命令时添加 sudo (需重新登录才会生效)

编辑 `/etc/docker/daemon.json`:
```json
{
  "registry-mirrors": ["https://ustc-edu-cn.mirror.aliyuncs.com/"]
}
```
- 可选，在 minikube 中并不会生效

### kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```
- 下载 kubectl 二进制文件并安装

### minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```
- 下载 minikube 二进制文件并安装

## 启动

```bash
minikube start --registry-mirror=https://ustc-edu-cn.mirror.aliyuncs.com --image-mirror-country=cn
```
- `registry-mirror` 指定 minikube 使用的 docker 镜像地址
- `image-mirror-country` 设置 gcr.io 镜像地区，将会从 `registry.cn-hangzhou.aliyuncs.com/google_containers` 下载

minikube 生成的配置文件 `~/.minikube/machines/minikube/config.json`

### docker

默认情况下 `docker ps` 无法看到 minikube 中的 docker，可执行：

```bash
eval $(minikube -p minikube docker-env)
```

之后可通过执行 `docker` 相关命令操作 minikube 相关 docker

## 参考

- https://minikube.sigs.k8s.io/docs/start/
- https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
