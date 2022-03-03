---
title: "Linux Varnish 添加 Prometheus 监控"
date: 2022-02-22T18:02:04+08:00
tags: ["varnish", "monitoring"]
categories: ["varnish"]
---

## 安装

根据 [prometheus exporter 列表](https://prometheus.io/docs/instrumenting/exporters/) 选择第三方维护的[Varnish exporter](https://github.com/jonnenauha/prometheus_varnish_exporter/)。

```bash
wget https://github.com/jonnenauha/prometheus_varnish_exporter/releases/download/1.6.1/prometheus_varnish_exporter-1.6.1.linux-amd64.tar.gz
tar -zxvf prometheus_varnish_exporter-1.6.1.linux-amd64.tar.gz
cd prometheus_varnish_exporter-1.6.1.linux-amd64/
```

varnish 以用户 `vcache` 身份运行，因此，需要以用户 `vcache` 身份运行 prometheus_varnish_exporter。[参考](https://github.com/jonnenauha/prometheus_varnish_exporter/issues/62)

prometheus_varnish_exporter 使用命令 varnishstat 采集数据，先通过用户 `vcache` 测试 varnishstat：
```bash
sudo -u vcache varnishstat -j
```

通过用户 `vcache` 测试 exporter：
```bash
sudo -u vcache ./prometheus_varnish_exporter -test
```

确定无误后，启动 exporter ：
```bash
sudo -u vcache ./prometheus_varnish_exporter
```

访问 exporter 数据 <http://127.0.0.1:9131/metrics>

### Systemd 管理 exporter

1. 新文件 exporter 配置文件 `/usr/local/etc/prometheus_varnish_exporter`：
```conf
OPTIONS="-web.listen-address :9131"
```

2. 新建 systemd 配置文件 `/usr/lib/systemd/system/prometheus_varnish_exporter.service`：
```systemd
[Unit]
Description=Prometheus Varnish Exporter
After=network.target

[Service]
User=vcache
EnvironmentFile=/usr/local/etc/prometheus_varnish_exporter
ExecStart=/usr/local/bin/prometheus_varnish_exporter $OPTIONS

[Install]
WantedBy=multi-user.target
```
- 通过环境变量传递参数

3. 启动 exporter

```bash
sudo systemctl start prometheus_varnish_exporter.service
```

## 配置指标

exporter 提供了 [grafana dashboard.json](https://github.com/jonnenauha/prometheus_varnish_exporter/blob/master/dashboards/jonnenauha/dashboard.json)，复制即可使用

![](https://raw.githubusercontent.com/jonnenauha/prometheus_varnish_exporter/master/dashboards/jonnenauha/dashboard.png)

## 参考

- https://github.com/jonnenauha/prometheus_varnish_exporter
