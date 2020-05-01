+++
title = "使用 Systemd 设置 frp 开机启动"
author = ["notfound"]
date = 2018-12-31T15:36:00+08:00
tags = ["systemd", "frp"]
draft = false
+++

系统环境：Ubuntu 18.04

[frp](https://github.com/fatedier/frp) 可以实现内网穿透，通过 Systemd 设置客户端 fprc 和服务端 frps 开机启动。

Systemd 有几篇不错的入门文章：

- [Systemd 入门教程：命令篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
- [Systemd 入门教程：实战篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)

## Systemd 简介

Systemd 配置文件在 `/lib/systemd/system/` 目录下，不同类型的文件使用不同的后缀，如： `.service` `.socket`  `.timer` 。

常用命令如下：

```shell
systemctl status frps.service       # 查看 frps 服务状态
systemctl cat frps.service          # 查看 frps 服务配置
sudo systemctl start frps.service   # 启动 frps 服务
sudo systemctl stop frps.service    # 停止 frps 服务
sudo systemctl daemon-reload        # 重新加载配置，修改 systemd 配置执行
sudo systemctl enable frps.service  # 设置开机启动，根据 install 建立软链
sudo systemctl disable frps.service # 取消开机启动，根据 install 移除软链

man systemd.directives              # 查看帮助
man systemd.service
man systemd.unit
```

## frps Systemd 配置文件

创建 `/lib/systemd/system/frpc.service` 文件，配置如下：

```systemd
[Unit]
Description=frps server daemon
Documentation=https://github.com/fatedier/frp
After=network-online.target

[Service]
ExecStart=/usr/local/bin/frps -c /usr/local/etc/frps.ini
Type=simple
User=nobody
Group=nogroup
WorkingDirectory=/tmp
Restart=on-failure
RestartSec=60s

[Install]
WantedBy=multi-user.target
```

- `[Unit]`
  - `After` 在网络就绪后启动服务，关于网络就绪 [NetworkTarget](https://www.freedesktop.org/wiki/Software/systemd/NetworkTarget)
- `[Service]`
  - `ExecStart` 启动时执行的命令
  - `Type` simple 执行 ExecStart 指定的命令，启动主进程，还有很多其他类别
  - `User` 执行命令的用户为 nobody
  - `Group` 执行命令的组为 nogroup
  - `WorkingDirectory` 命令的工作目录
  - `Restart` 失败后尝试重启，失败是根据退出状态码进行判断的
  - `RestartSec` 失败 60s 后尝试重启
- `[Install]`
  - `WantedBy` 执行 `systemctl enable frps` 命令，会在 `/etc/systemd/system/multi-user.target.wants/frps.service` 目录下创建一个软链

添加或修改配置后需要执行 `sudo systemctl daemon-reload` 重新加载，执行 `sudo systemctl enable frps.service` 之后会开机启动。

## fprc 配置文件

创建 `/lib/systemd/system/frpc.service` 文件，配置和 frps 类似：

```systemd
[Unit]
Description=frpc server daemon
Documentation=https://github.com/fatedier/frp
After=network-online.target

[Service]
ExecStart=/usr/local/bin/frpc -c /usr/local/etc/frpc.ini
Type=simple
User=nobody
Group=nogroup
WorkingDirectory=/tmp
Restart=on-failure
RestartSec=60s

[Install]
WantedBy=multi-user.target
```

添加或修改配置后需要执行 `sudo systemctl daemon-reload` 重新加载，执行 `sudo systemctl enable frpc.service` 之后会开机启动。
