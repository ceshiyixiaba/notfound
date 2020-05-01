---
title: "OAuth2 授权码模式"
date: 2021-09-20T14:54:17+08:00
tags: ["oauth2"]
categories: ["oauth2"]
draft: true
---

## 术语

- 资源所有者(Resources Owner): 用户实体
- 用户代理(User-Agent): 通常为浏览器
- 认证服务器(Authentication Server): 可以验证资源所有者，生成访问令牌
- 客户端(Client): 第三方客户端，向资源所有者的在资源服务器上的资源

## 流程

```text
     +----------+
     | Resource |
     |   Owner  |
     |          |
     +----------+
          ^
          |
         (B)
     +----|-----+          Client Identifier      +---------------+
     |         -+----(A)-- & Redirection URI ---->|               |
     |  User-   |                                 | Authorization |
     |  Agent  -+----(B)-- User authenticates --->|     Server    |
     |          |                                 |               |
     |         -+----(C)-- Authorization Code ---<|               |
     +-|----|---+                                 +---------------+
       |    |                                         ^      v
      (A)  (C)                                        |      |
       |    |                                         |      |
       ^    v                                         |      |
     +---------+                                      |      |
     |         |>---(D)-- Authorization Code ---------'      |
     |  Client |          & Redirection URI                  |
     |         |                                             |
     |         |<---(E)----- Access Token -------------------'
     +---------+       (w/ Optional Refresh Token)

   Note: The lines illustrating steps (A), (B), and (C) are broken into
   two parts as they pass through the user-agent.

                     Figure 3: Authorization Code Flow
```

## 三方

```text
Client     <--  Client ID and Client Secret --> Authentication Server

User-Agent <--      Username and password   --> Authentication Server
```

## 示例

```text
GET http://localhost:8080/oauth2/authorization/github

HTTP/1.1 302
Location: https://github.com/login/oauth/authorize?response_type=code&client_id=532062cd2c5d82582dd5&scope=read:user&state=X2baH-bvudIw-ClUpxfzUf1wJr-fLAhI5FCmon79TA8%3D&redirect_uri=http://localhost:8080/login/oauth2/code/github
```
第三方客户端(Client)通过浏览器(User-Agent)重定向认证服务器(Authentication Server) 传递参数:
- `response_type` 授权类型 `code`
- `client_id` 客户端标识 `532062cd2c5d82582dd5`
- `scope` 权限范围 `read:user`
- `state` `X2baH-bvudIw-ClUpxfzUf1wJr-fLAhI5FCmon79TA8%3D`
- `redirect_uri` <http://localhost:8080/login/oauth2/code/github>

```text
GET https://github.com/login/oauth/authorize?response_type=code&client_id=532062cd2c5d82582dd5&scope=read:user&state=X2baH-bvudIw-ClUpxfzUf1wJr-fLAhI5FCmon79TA8%3D&redirect_uri=http://localhost:8080/login/oauth2/code/github

HTTP/1.1 302
location: http://localhost:8080/login/oauth2/code/github?code=f141bfa1a77d7edbab6f&state=X2baH-bvudIw-ClUpxfzUf1wJr-fLAhI5FCmon79TA8%3D
```
认证服务器(Authentication Server) 通过重定向资源服务器传递参数:
- `code` `f141bfa1a77d7edbab6f`
- `state` 原封不动的传送回来 `X2baH-bvudIw-ClUpxfzUf1wJr-fLAhI5FCmon79TA8%3D`

```text
GET http://localhost:8080/login/oauth2/code/github?code=f141bfa1a77d7edbab6f&state=X2baH-bvudIw-ClUpxfzUf1wJr-fLAhI5FCmon79TA8%3D

HTTP/1.1 302
Location: http://localhost:8080/
```
- 用户拿到 `code` 后，向认证服务器请求访问令牌(Access Token)

```text
GET http://localhost:8080/
HTTP/1.1 200
```
