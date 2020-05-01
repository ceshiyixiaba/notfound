---
title: "OAuth 2.0 简介"
date: 2021-09-20T10:12:09+08:00
tags: ["oauth2"]
categories: ["oauth2"]
---

## 术语

- 资源所有者(resource owner): 用户实体
- 资源服务器(resource server): 保存了用户受保护的资源
- 客户端(client): 应用程序，该程序想获取资源所有者(resource owner)在资源服务器(resource server)上的受保护的资源
- 授权服务器(authorization server): 可以验证资源所有者

## 过程

### 资源所有者与资源服务器

资源所有者(resource owner)获取资源流程：

资源所有者(resource owner) --> 登录(用户名+密码) --> 资源服务器(resource server)

能否直接将资源所有者换成客户端?

### 客户端与资源服务器

第三方客户端(client) --> 登录(用户名+密码) --> 资源服务器(resource server)

- 三方客户端为避免重复申请授权，很可能保存用户名和密码
- 三方客户端权限过大，操作不受限制
- 三方客户端的是否能访问资源和用户名、密码强关联
  - 修改密码前，三方客户端可以访问
  - 修改密码后，三方客户端不能访问

### 授权服务器

要解决上述问题，可以给三方客户端(client)一个访问令牌(access token)，并设置过期时间(expires_in)以及访问范围(scope):

第三方客户端(client) --> 访问令牌(access token) --> 资源服务器(resource server)

- 令牌权限有限
- 令牌可随时注销

授权服务器(authorization server)验证资源所有者(resource owner)，并生成一个受限的访问令牌(access token)。在生成令牌前，资源所有者可指定访问令牌的访问范围(scope)，

## OAuth 2.0 协议流程

```text
     +--------+                               +---------------+
     |        |--(A)- Authorization Request ->|   Resource    |
     |        |                               |     Owner     |
     |        |<-(B)-- Authorization Grant ---|               |
     |        |                               +---------------+
     |        |
     |        |                               +---------------+
     |        |--(C)-- Authorization Grant -->| Authorization |
     | Client |                               |     Server    |
     |        |<-(D)----- Access Token -------|               |
     |        |                               +---------------+
     |        |
     |        |                               +---------------+
     |        |--(E)----- Access Token ------>|    Resource   |
     |        |                               |     Server    |
     |        |<-(F)--- Protected Resource ---|               |
     +--------+                               +---------------+

                     Figure 1: Abstract Protocol Flow
```

- A. 客户端向资源所有者请求授权
- B. 资源所有者同意授权给客户端
- C. 客户端通过上一步的授权许可，向认证服务器申请访问令牌
- D. 认证服务器发放访问令牌给客户端
- E. 客户通过访问令牌向资源服务器请求受保护的资源
- F. 资源服务器将受保护的资源发送给客户端

## 参考

- http://www.ruanyifeng.com/blog/2014/05/oauth_2_0.html
- https://www.rfc-editor.org/rfc/rfc6749.txt
