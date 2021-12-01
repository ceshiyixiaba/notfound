---
title: "Linux 编译安装 Ruby"
author: ["likui"]
date: 2021-03-18T20:00:00+08:00
lastmod: 2021-03-20T11:42:07+08:00
tags: ["ruby", "linux"]
---

## Linux 编译安装 Ruby

- Ubuntu 20.04
- Ruby 3.0.0

### 直接编译安装

```bash
wget http://cache.ruby-china.com/pub/ruby/3.0/ruby-3.0.0.tar.gz
tar -zxvf ruby-3.0.0.tar.gz
cd ruby-3.0.0
./configure --prefix=/opt/ruby-3.0.0
make -j8
make install
```

### 集成 jemalloc

jemalloc 可以大幅度减少 sidekiq 内存碎片。

```bash
sudo apt install libjemalloc-dev
```

#### 编译方式

编译时添加 `--with-jemalloc` 参数即可：

```bash
./configure --prefix=/opt/ruby-3.0.0 --with-jemalloc
```

检查 jemalloc:

```bash
/opt/ruby-3.0.0/bin/ruby -r rbconfig -e "puts RbConfig::CONFIG['MAINLIBS']"
# 低版本
# ruby -r rbconfig -e "puts RbConfig::CONFIG['LIBS']"
```

输出：

```text
-lz -lpthread - lrt -lrt -ljemalloc -lgmp -ldl -lcrypt -lm
```

#### 环境变量方式

设置环境变量 `LD_PRELOAD` 即可

```bash
export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so
```


### 指定 openssl 版本

编译 openssl：

```bash
wget https://www.openssl.org/source/openssl-1.1.1j.tar.gz
tar -zxvf openssl-1.1.1j.tar.gz
cd openssl-1.1.1j
./config shared --prefix=/opt/openssl-1.1.1j
make -j8
```

通过 `--with-openssl-dir` 参数指定 openssl 路径：

```bash
./configure --prefix=/opt/ruby-3.0.0 --with-openssl-dir=/opt/openssl-1.1.1j
```

#### 可能遇到问题

```text
$ gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
Error fetching https://gems.ruby-china.com/:
SSL_connect returned=1 errno=0 state=error: certificate verify failed (https://gems.ruby-china.com/specs.4.8.gz)
```

导入环境变量即可：

```bash
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_DIR=/etc/ssl/certs
```

## 环境变量

输出 gem 信息：

```bash
gem env
gem env path
gem env home
```

通过设置 `GEM_PATH` 修改 gem 查找路径：

```bash
export GEM_PATH=/home/notfound/app/vendor/bundle/ruby/2.7.0
```

## gem 配置

### 修改源

```bash
gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
```

### 不安装文档

编辑 `~/.gemrc` 或者 `/etc/gemrc` 或者 `~/.config/gem/gemrc`(fedora 35)，添加：

```gemrc
gem: --no-document
```

## 参考

- <https://github.com/rbenv/ruby-build/issues/1215>
- <https://wiki.openssl.org/index.php/Compilation%5Fand%5FInstallation>
- <https://github.com/jemalloc/jemalloc/wiki/Getting-Started>
- <https://www.cyningsun.com/07-07-2018/memory-allocator-contrasts.html>
- <https://stackoverflow.com/questions/11277227/whats-the-difference-between-gem-home-and-gem-path>
