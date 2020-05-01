---
title: "Nginx CORS 配置"
date: 2020-05-01T12:23:24+08:00
tags: ["nginx", "cors"]
draft: false
---

Nginx CORS 配置

### 配置

```nginx 
add_header 'Access-Control-Allow-Origin' '*';
add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS';
add_header 'Access-Control-Allow-Headers' 'Authorization,Content-Type,Accept,Origin,User-Agent,Cache-Control';

if ($request_method = 'OPTIONS') {
	return 204;
}
```

- `Access-Control-Allow-Origin`: `*` 表示允许所有站点。也可以设置为具体的站点，如 `http://example.com`。
- `Access-Control-Allow-Methods`: 允许客户端发起 `GET`、`POST` 和 `OPTIONS` 请求。
- `Access-Control-Allow-Headers`: 允许携带的头部。

## Q

### 添加后无效 `Access-Control-Allow-Origin` 依旧无效

```text
Access to fetch at 'http://api.git.test/users' from origin 'http://git.test' has been blocked by CORS policy: The 'Access-Control-Allow-Origin' header contains multiple values 'git.com, git.test', but only one is allowed. Have the server send the header with a valid value, or, if an opaque response serves your needs, set the request's mode to 'no-cors' to fetch the resource with CORS disabled.
```

```nginx
add_header ‘Access-Control-Allow-Origin’ '*' always;
```

- 无论何时都生效。

### 携带认证信息

1. 一般而言，对于跨域 XMLHttpRequest 或 Fetch 请求，浏览器不会发送身份凭证信息。如果要发送凭证信息，需要设置 XMLHttpRequest 的某个特殊标志位。
2. 对于附带身份凭证的请求，服务器不得设置 Access-Control-Allow-Origin 的值为“*”。

## 参考

- [跨域资源共享 CORS 详解](https://www.ruanyifeng.com/blog/2016/04/cors.html)
- [HTTP访问控制（CORS）](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Access_control_CORS)
- [nginx 配置add_header 'Access-Control-Allow-Origin' '*' 依然存在跨域问题](https://blog.csdn.net/xiojing825/article/details/83383524)
- [CORS on Nginx](https://enable-cors.org/server_nginx.html)
