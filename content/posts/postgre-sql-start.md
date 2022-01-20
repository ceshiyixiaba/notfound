---
title: "PostgreSQL 安装与使用"
date: 2021-10-16T19:17:49+08:00
tags: ["database"]
draft: false
---

- Ubuntu 20.04

## 安装

### postgresql

```bash
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install postgresql
```

### pgadmin4

```bash
sudo curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
sudo apt install pgadmin4
```

- pgadmin4 图形客户端

## Shell 命令创建用户和数据库

```bash
# 创建用户
sudo -u postgres createuser --interactive --password $USER
# 创建数据库并指定所有者
sudo -u postgres createdb example_db -O $USER
```

当前用户 `$USER` 可直接登陆 PostgreSQL，无需输入密码：

```bash
psql -d example_db
# 查看数据库基本信息
\l example_db
```

这是因为 `/etc/postgresql/14/main/pg_hba.conf` 默认开启了 `peer` 认证，PostgreSQL 通过操作系统获取用户名将其作为数据库用户名直接登陆。

## 常用命令

通过用户 `postgres` 启动客户端:

```bash
sudo su - postgres
psql
```

`\?`:

```psql
\?    -- 帮助
\l    -- 列出所有数据库
\du   -- 列出角色
```

以指定角色（用户）登录指定数据库

```bash
psql -h 127.0.0.1 -U example -d example_db
```

创建具备登录权限的角色:

 ```psql
 CREATE ROLE example LOGIN PASSWORD 'YOUR_PASSWORD';
 ```
删除角色:

```psql
DROP ROLE example;
```

修改密码:

```psql
ALTER ROLE example PASSWORD 'NEW_PASSWORD';
```

创建数据库并指定所有者:

```psql
CREATE DATABASE example_db WITH owner = example;
```

删除数据库:

```psql
DROP DATABASE example_db;
```

## .pgpass 免密登录

新建 `~/.pgpass` 文件，添加：

```text
127.0.0.1:5432:example_db:example:YOUR_PASSWORD
```

修改文件权限：

```bash
chmod 0600 ~/.pgpass
```

免密登录：

```bash
psql -h 127.0.0.1 -U example -d example_db
```

## Q

1. sql: 错误: 致命错误:  用户 "sample" Ident 认证失败

编辑 `/var/lib/pgsql/data/pg_hba.conf`：
```conf
host    all             sample          127.0.0.1/32            md5
```

## 参考

- [Linux downloads (Ubuntu)](https://www.postgresql.org/download/linux/ubuntu/)
- [The Password File](https://www.postgresql.org/docs/12/libpq-pgpass.html)
- [pgAdmin 4 (APT)](https://www.pgadmin.org/download/pgadmin-4-apt/)
