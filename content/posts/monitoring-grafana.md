---
title: "Ubuntu 安装 Grafana"
date: 2020-05-14T18:39:26+08:00
tags: ["monitoring"]
categories: ["monitoring"]
draft: false
---

- 系统环境 Ubuntu 18.04

## 安装

下载 <https://prometheus.io/download/>

```shell
# 下载
wget https://dl.grafana.com/oss/release/grafana-6.7.3.linux-amd64.tar.gz
# 解压
tar -zxvf grafana-6.7.3.linux-amd64.tar.gz
# 启动
./bin/grafana-server web
```

访问 <http://localhost:9090> ，用户名: admin，密码: admin。

## 配置

1. 添加数据源 Prometheus
2. 添加 Dashboard

## 忘记密码

```bash
grafana-cli admin reset-admin-password <new password>
```
## 参考

- [Install on Debian or Ubuntu](https://grafana.com/docs/grafana/latest/installation/debian/)
