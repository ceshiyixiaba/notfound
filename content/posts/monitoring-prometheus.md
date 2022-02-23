---
title: "Ubuntu 搭建 Prometheus"
date: 2020-05-14T18:38:20+08:00
lastmod: 2022-02-22T16:50:07+08:00
tags: ["monitoring"]
categories: ["monitoring"]
draft: false
---

- 系统环境 Ubuntu 20.04

## 安装

下载 <https://prometheus.io/download/>

```shell
wget https://github.com/prometheus/prometheus/releases/download/v2.33.3/prometheus-2.33.3.linux-amd64.tar.gz
tar -zxvf prometheus-2.33.3.linux-amd64.tar.gz
# 启动
./prometheus --config.file=prometheus.yml
```

访问 <http://localhost:9090> 即可。

目录结构如下：

```text
....
├── data            # 数据目录
├── prometheus      # 执行文件
├── prometheus.yml  # 配置文件
├── promtool        # 工具（没用过
...
```

## 配置

```yml
global:
  scrape_interval:     15s # 收集数据的时间间隔

scrape_configs:
  - job_name: 'prometheus' # 作业名称

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['localhost:9090']
```

### Metric 类型

#### Counter

累加 metric。累加，如 `prometheus_http_requests_total`。

#### Gauge

常规 metric。某个值，如 `go_goroutines`。

#### Histogram

直方图。请求处理时间，如 `prometheus_http_request_duration_seconds_bucket{handler="/",le="0.1"}`

#### Summary

类似于 Histogram, 典型的应用如：请求持续时间，响应大小。如 `prometheus_http_response_size_bytes_bucket{handler="/api/v1/query_range",le="100"}`

## PromQL

## 参考

- [GETTING STARTED](https://prometheus.io/docs/prometheus/latest/getting_started/)
- [Prometheus 入门与实践](https://www.ibm.com/developerworks/cn/cloud/library/cl-lo-prometheus-getting-started-and-practice/index.html)
