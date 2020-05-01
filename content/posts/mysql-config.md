---
title: "Mysql 设置"
date: 2021-02-08T11:04:23+08:00
tags: ["mysql", "database"]
draft: true
---

### 超时

```mysql
show global variables like '%timeout%';
```
- 查看超时相关变量

```mysql
set global wait_timeout=3600;
```
- `wait_timeout`: 服务器在关闭非交互式连接之前等待活动的秒数

```mysql
set global interactive_timeout=3600;
```
- `interactive_timeout`: 服务器在关闭交互式连接之前等待活动的秒数

### 连接数

```
show full processlist;
```
- 查看所有连接数

```mysql
kill processlist_id;
```
- kill 指定连接线程

```mysql
show variables like '%max_connections%';
```
- 查看最大连接数

```mysql
set global max_connections = 200;
```
- 设置最大连接数

## 参考

- [Mysql连接超时解决方案1: 修改默认超时时间](https://blog.csdn.net/Huozhiwu_11/article/details/104530746)
- [MySQL 连接数满情况的处理](https://www.jianshu.com/p/6689474434f7)
- [Server System Variables](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html)
- [SHOW PROCESSLIST Statement](https://dev.mysql.com/doc/refman/8.0/en/show-processlist.html)
- [KILL Statement](https://dev.mysql.com/doc/refman/8.0/en/kill.html)
