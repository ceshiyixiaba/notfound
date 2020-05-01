+++
title = "HTTP 认证过程"
author = ["likui"]
date = 2021-02-16T16:28:00+08:00
lastmod = 2021-02-16T16:53:02+08:00
tags = ["http"]
draft = false
+++

## HTTP 认证过程 {#http-认证过程}

访问 Tomcat 管理页 <http://localhost:8080/manager/html> 时，大致过程如下：

{{< figure src="/ox-hugo/http-auth.svg" >}}


### 密码编码问题 {#密码编码问题}

主流浏览器基本都是使用 `UTF-8`


### 特殊符号问题冒号 {#特殊符号问题冒号}

用户名中不能包含冒号 `:`


### 参考 {#参考}

-   [WWW-Authenticate](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/WWW-Authenticate)
-   [Authorization](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Authorization)
-   [HTTP 身份验证](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Authentication)
-   [HTTP/HTTPS basic authentication: colon in username](https://stackoverflow.com/questions/11612854/http-https-basic-authentication-colon-in-username)
