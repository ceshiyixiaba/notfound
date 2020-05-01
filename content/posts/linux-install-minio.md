---
title: "Linux 安装配置 Minio"
date: 2021-09-04T09:59:50+08:00
tags: ["minio", "linux"]
---

## 安装

```bash
wget https://dl.min.io/server/minio/release/linux-amd64/minio
sudo install -o root -g root -m 0755 minio /usr/local/bin/minio
```

## 配置 Systemd

添加文件 `/etc/default/minio`：

```bash
# Volume to be used for MinIO server.
MINIO_VOLUMES="/srv/minio/"
# Use if you want to run MinIO on a custom port.
MINIO_OPTS="--address 127.0.0.1:9000 --console-address 127.0.0.1:9001"
# Root user for the server.
MINIO_ROOT_USER=Root-User
# Root secret for the server.
MINIO_ROOT_PASSWORD=Root-Password
```
- 文件中的环境变量会通过 Systemd 传给 minio，根据进行需要修改
- `console-address` 管理页面使用的监听地址

添加文件 `/etc/systemd/system/minio.service`:

```toml
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
WorkingDirectory=/usr/local/

User=minio-user
Group=minio-user
ProtectProc=invisible

EnvironmentFile=/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"

ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target

# Built for ${project.name}-${project.version} (${project.name})
```

- 根据需要修改 `User` 以及 `Group`

```bash
# 启动
sudo systemctl start minio.service
# 查看服务状态
systemctl status minio.service
# 开机启动
sudo systemctl enable minio.service
# 禁用开机启动
sudo systemctl disable minio.service
```

通过 http://127.0.0.1:9000 可进入 minio 页面。

## Nginx 配置

添加文件 `/etc/nginx/conf.d/minio.conf`:

```nginx
server {
	listen 80;
	server_name example.com;

	# To allow special characters in headers
	ignore_invalid_headers off;
	# Allow any size file to be uploaded.
	# Set to a value such as 1000m; to restrict file size to a specific value
	client_max_body_size 100m;
	# To disable buffering
	proxy_buffering off;

	location / {
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_set_header Host $http_host;

		proxy_connect_timeout 300;
		# Default is HTTP/1, keepalive is only enabled in HTTP/1.1
		proxy_http_version 1.1;
		proxy_set_header Connection "";
		chunked_transfer_encoding off;

		proxy_pass http://localhost:9000; # If you are using docker-compose this would be the hostname i.e. minio
		# Health Check endpoint might go here. See https://www.nginx.com/resources/wiki/modules/healthcheck/
		# /minio/health/live;
	}
}
```

## 参考

- https://docs.min.io/docs/minio-quickstart-guide.html
- https://docs.min.io/docs/setup-nginx-proxy-with-minio.html
- https://github.com/minio/minio-service/tree/master/linux-systemd
