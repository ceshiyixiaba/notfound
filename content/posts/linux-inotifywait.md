---
title: "Linux 使用 inotifywait 监控文件变更"
date: 2021-12-07T17:24:24+08:00
tags: ["linux", "tool"]
draft: false
---

- fedora 35

## 安装 

```bash
sudo dnf install inotify-tools
```

`inotify-tools` 包含两个工具：
- `inotifywait` 使用 inotify 等待文件更改
- `inotifywatch` 使用 inotify 收集文件系统访问统计信息

## 使用

```bash
inotifywait -m -r -e create -e modify -e move -e delete ~/test
```
- `-m --monitor` 保持监控状态
- `-r --recursive` 监控所有子目录
- `-e --event` 事件
  - `create` 创建文件或者目录
  - `modify` 修改文件
  - `move` 文件或者目录移入或者移出监控目录
  - `delete` 删除文件或者目录

## 参考

- `man inotifywatch`
- `man inotifywait`
- `rpm -ql inotify-tools`
