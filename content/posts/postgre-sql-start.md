---
title: "PostgreSQL 安装与使用"
date: 2021-10-16T19:17:49+08:00
lastmod: 2022-01-24T14:41:26+08:00
tags: ["database"]
---

- Ubuntu 20.04

## 安装

### postgresql

添加 Ubuntu 源、GPG KEY，然后安装最新版。

```bash
sudo sh -c 'echo "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install postgresql
```

### pgadmin4

添加 Ubuntu 源、GPG KEY，然后安装最新版。

```bash
sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'
sudo curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
sudo apt-get update
sudo apt install pgadmin4
```

## Shell 命令创建用户和数据库

```bash
# 创建用户
sudo -u postgres createuser --interactive --pwprompt $USER
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

查看配置文件路径：
```sql
show config_file;
-- host-based authentication 基于主机认证
show hba_file;
```

以指定角色（用户）登录指定数据库：
```bash
psql -h 127.0.0.1 -U example -d example_db
```

创建具备登录权限的角色:
```sql
CREATE ROLE example LOGIN PASSWORD 'YOUR_PASSWORD';
```

删除角色:
```sql
DROP ROLE example;
```

修改密码:
```sql
ALTER ROLE example PASSWORD 'NEW_PASSWORD';
```

创建数据库并指定所有者:
```sql
CREATE DATABASE example_db WITH owner = example;
```

删除数据库:
```sql
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

编辑 `/etc/postgresql/14/main/pg_hba.conf`：
```conf
host    all             sample          127.0.0.1/32            md5
```

## 参考

- <https://www.postgresql.org/download/linux/ubuntu>
- <https://www.postgresql.org/docs/12/libpq-pgpass.html>
- <https://www.pgadmin.org/download/pgadmin-4-apt>
