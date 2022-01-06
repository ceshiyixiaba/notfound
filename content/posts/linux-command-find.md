---
title: "Linux Find 命令"
date: 2021-11-30T16:42:44+08:00
tags: ["linux"]
---

## 删除空目录

```bash
find . -maxdepth 1 -mindepth 1 -type d -empty -print -delete
```
- `maxdepth` 目录最大深度
- `mindepth` 目录最小深度
- `type` 类型 `d` 为目录
- `empty` 空文件或者目录
- `print` 标准输出打印文件路径
- `delete` 执行删除操作

## 删除 30 天前的所有文件

```bash
find . -mindepth 1 -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;
```

## 清空所有文件

```bash
find logs/ -name "*.log" -type f -exec truncate -s 0 {} \;
```
- 对 `logs` 目录下以 `.log` 结尾的文件执行截断操作

## 参考

- man find
- https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html
