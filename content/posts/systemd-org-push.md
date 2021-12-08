---
title: "使用 Systemd 定时同步 git 仓库"
date: 2018-12-31T16:31:00+08:00
tags: ["systemd", "linux"]
---

系统环境：Ubuntu 18.04

`Org` 文档保存在 `~/Documents/org/` 目录下，包含了 TODOs 和一些笔记，是一个 git 仓库，希望每天下班前自动推送到服务器。

Systemd 定时器教程可参考：

- [Systemd 定时器教程](http://www.ruanyifeng.com/blog/2018/03/systemd-timer.html)

## Systemd timer 简介

Systemd timer 配置文件在 `/lib/systemd/system/` 目录下，以 `.timer` 结尾。

常用命令如下：

```shell
systemctl status org-push.timer        # 查看 org-push 定时器状态
sudo systemctl start org-push.timer    # 启动 org-push 定时器
sudo systemctl stop org-push.timer     # 停止 org-push 定时器
sudo systemctl enable org-push.timer   # 开机启动
sudo systemctl disable org-push.timer  # 取消开机启动

man systemd.timer                      # 帮助
```

## 配置

需要先添加一个 Service Unit，然后在 Timer 中使用这个 Unit。

### 添加 service

创建 `/lib/systemd/system/org-push.service` 文件，配置如下：

```systemd
[Unit]
Description=Org push service

[Service]
ExecStart=/home/notfound/Documents/org/push.sh
WorkingDirectory=/home/notfound/Documents/org
User=notfound
Group=notfound
```

- `[Service]`
  - `ExecStart` push.sh 是包含提交和推送命令的脚本
  - `WorkingDirectory` 工作目录为 org 文档目录
  - `User` 执行命令的用户
  - `Group` 执行命令的组

执行 `sudo systemctl daemon-reload` 重新加载配置。


### 添加 timer

创建 `/lib/systemd/system/org-push.timer` 文件，配置如下：

```systemd
[Unit]
Description=Org push timer

[Timer]
OnCalendar=*-*-* 18:00
Unit=org-push.service

[Install]
WantedBy=timers.target
```

- `[Timer]`
  - `OnCalendar` Timer 执行时间为每天 18:00
  - `Unit` Timer 使用 org-push.service
- `[Install]`
  - `WantedBy` 执行 `sudo systemctl enable org-push.timer` 会在 `/etc/systemd/system/timers.target.wants` 目录下创建一个软链

执行 `sudo systemctl daemon-reload` 重新加载配置。

开启定时任务 `sudo systemctl enable org-push.timer` 。
