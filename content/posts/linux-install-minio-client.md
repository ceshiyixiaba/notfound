---
title: "Linux 安装配置 Minio Client"
date: 2021-09-04T11:47:51+08:00
tags: ["minio"]
---

## 安装

```bash
wget https://dl.min.io/client/mc/release/linux-amd64/mc
sudo install -o root -g root -m 0755 mc /usr/local/bin/mc
```

## 配置

```bash
# 导入环境变量
source /etc/default/minio
# 创建别名 local
mc alias set local http://127.0.0.1:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD --api S3v4
```
- 配置信息保存在  ~/.mc/config.json

只后可以通过别名 `local` 访问 minio

## 基本使用

```bash
# 创建桶 make a bucket
mc mb local/avatars
# 删除桶 remove a bucket
mc rb local/avatars

# 列出对象 list buckets and objects
mc ls local
# 复制对象 copy objects 并指定 content-type 属性
mc cp --attr content-type=image/jpeg  ~/Pictures/0.jpg local/avatars
# 查看对象信息
mc stat local/avatars/0.jpg
# 删除对象
mc rm local/avatars/0.jpg

# 共享下载
mc share download --expire 1h local/avatars/0.jpg
# 共享下载列表
mc share list download local

# 可公开下载
mc policy set download local/avatars
```

- 通过设置 `content-type=image/jpeg` 可以直接通过浏览器查看图片

## 参考

- https://docs.min.io/docs/minio-client-complete-guide.html
