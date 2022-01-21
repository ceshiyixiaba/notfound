---
title: "Linux Pgbouncer 使用"
date: 2022-01-20T18:21:25+08:00
tags: ["database", "postgresql"]
---

- Ubuntu 20.04
- PostgreSQL 14

## 编译安装

```bash
sudo apt install libevent-dev

wget https://www.pgbouncer.org/downloads/files/1.16.1/pgbouncer-1.16.1.tar.gz
cd pgbouncer-1.16.1
./configure --prefix=/usr/local --with-systemd
make -j8
sudo make install
```
- `--with-systemd` systemd 集成

## 配置

1. `pgbouncer.ini`

编辑 `etc/pgbouncer.ini`：

```ini
[databases]
example_db= host=127.0.0.1 port=5432 dbname=example_db

[pgbouncer]
auth_type = scram-sha-256
auth_file = /usr/local/etc/pgbouncer/userlist.txt
;; max_client_conn    ;; 客户端最大连接数
;; default_pool_size  ;; 链接池大小
```
- 添加 example_db
- `auth_type` 来自 PostgreSQL 配置文件 `/etc/postgresql/14/main/pg_hba.conf`
- 修改 `auth_files` 路径

2. `userlist.txt`

查询用户名和密码：

```sql
SELECT usename, passwd FROM pg_shadow WHERE usename='example';
=> example | SCRAM-SHA-256$4096:****
```

编辑 `etc/userlist.txt`，填写查询到的结果：

```text
"example" "SCRAM-SHA-256$4096:****"
```

3. 复制配置文件到指定位置

```bash
sudo mkdir /usr/local/etc/pgbouncer
sudo cp etc/pgbouncer.ini /usr/local/etc/pgbouncer
sudo cp etc/userlist.txt /usr/local/etc/pgbouncer
```

### systemd

添加 systemd 配置，[参考](https://github.com/pgbouncer/pgbouncer/blob/master/etc/pgbouncer.service)。新建文件 `etc/pgbouncer.service`：

```systemd
[Unit]
Description=connection pooler for PostgreSQL
Documentation=man:pgbouncer(1)
Documentation=https://www.pgbouncer.org/
After=network.target
#Requires=pgbouncer.socket

[Service]
Type=notify
User=postgres
ExecStart=/usr/local/bin/pgbouncer /usr/local/etc/pgbouncer/pgbouncer.ini
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
RuntimeDirectory=pgbouncer
#LimitNOFILE=1024

[Install]
WantedBy=multi-user.target
```

将配置文件复制到 systemd 目录，并创建日志目录：

```bash
sudo cp etc/pgbouncer.service /lib/systemd/system/
sudo mkdir /var/log/pgbouncer
sudo chown postgres:postgres /var/log/pgbouncer
```

## 启动

```bash
sudo systemctl start pgbouncer.service
```

通过 pgbouncer 链接数据库：

```bash
psql -h 127.0.0.1 -p 6432 -d example_db
```

## 连接测试

1. 查看配置文件路径
```text
show config_file;
               config_file
-----------------------------------------
 /etc/postgresql/14/main/postgresql.conf
(1 row)
```

2. 修改 PostgreSQL 链接数

编辑文件 `/etc/postgresql/14/main/postgresql.conf`
```conf
# sudo vim /etc/postgresql/14/main/postgresql.conf
max_connections = 1000
```

3. 测试脚本

安装 gem

```bash
sudo gem install pg
```

测试脚本

```ruby
#!/usr/bin/env ruby

require 'pg'

connection_hash = {
  host: '127.0.0.1',
  port: 5432, # 6432
  user: 'example',
  password: 'YOUR_PASSWORD',
  dbname: 'example_db'
}

1000.times.map do |i|
  puts("#{i} ---------------------")
  conn = PG.connect(connection_hash)
  conn.exec('SELECT * FROM pg_stat_activity') do |result|
    puts '     PID | User             | Query'
    result.each do |row|
      puts(' %7d | %-16s | %s' % row.values_at('pid', 'state', 'current_query'))
    end
  end
  conn
end
sleep 10
```

直接连接 PostgreSQL 时，创建 1000 个连接导致创建 1000 个进程，内存变化：2.06G -> 4.16G

## 参考

- https://www.pgbouncer.org/
- [PostgreSQL 为什么接受大量连接到数据库需要连接池](https://cloud.tencent.com/developer/article/1674779)
- [PgBouncer 原理与深入](https://cloud.tencent.com/developer/article/1620394)
