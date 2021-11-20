---
title: "Spring OpenID Connect 请求过程"
date: 2021-11-14T22:13:10+08:00
tags: ["oauth2", "spring", "java"]
categories: [""]
draft: false
---

- 认证服务器 <http://auth-server:9000>
- 客户端 <http://127.0.0.1:8080>
- 资源服务器 <http://127.0.0.1:8090>

## 客户端启动

1.1 客户端请求认证服务器，获取 OpenID Connect 配置信息：

```http
GET /.well-known/openid-configuration HTTP/1.1
Accept: application/json, application/*+json
Host: auth-server:9000
```
1.2 认证服务器响应，返回 OpenID Connect 配置：

```text
HTTP/1.1 200 
Content-Type: application/json

{
  "issuer": "http://auth-server:9000",
  "authorization_endpoint": "http://auth-server:9000/oauth2/authorize",
  "token_endpoint": "http://auth-server:9000/oauth2/token",
  "token_endpoint_auth_methods_supported": [
    "client_secret_basic",
    "client_secret_post"
  ],
  "jwks_uri": "http://auth-server:9000/oauth2/jwks",
  "response_types_supported": [
    "code"
  ],
  "grant_types_supported": [
    "authorization_code",
    "client_credentials",
    "refresh_token"
  ],
  "subject_types_supported": [
    "public"
  ],
  "id_token_signing_alg_values_supported": [
    "RS256"
  ],
  "scopes_supported": [
    "openid"
  ]
}
```

## 资源服务器启动

1.1 资源服务器请求认证服务器，获取 OpenID Connect 配置信息：

```http
GET /.well-known/openid-configuration HTTP/1.1
Accept: application/json, application/*+json
Host: auth-server:9000
```

1.2 认证服务器响应，返回 OpenID Content 配置：

```text
HTTP/1.1 200 
Content-Type: application/json

{
  "issuer": "http://auth-server:9000",
  "authorization_endpoint": "http://auth-server:9000/oauth2/authorize",
  "token_endpoint": "http://auth-server:9000/oauth2/token",
  "token_endpoint_auth_methods_supported": [
    "client_secret_basic",
    "client_secret_post"
  ],
  "jwks_uri": "http://auth-server:9000/oauth2/jwks",
  "response_types_supported": [
    "code"
  ],
  "grant_types_supported": [
    "authorization_code",
    "client_credentials",
    "refresh_token"
  ],
  "subject_types_supported": [
    "public"
  ],
  "id_token_signing_alg_values_supported": [
    "RS256"
  ],
  "scopes_supported": [
    "openid"
  ]
}
```

2.1 资源服务器请求认证服务器，获取 jwk(JSON Web Key)：

```http
GET /oauth2/jwks HTTP/1.1
Host: auth-server:9000
```

2.2 认证服务器响应，返回 jwk 信息：

```text
HTTP/1.1 200 
Content-Type: application/json;charset=ISO-8859-1

{
  "keys": [
    {
      "kty": "RSA",
      "e": "AQAB",
      "kid": "34714270-1e78-444a-9eca-4bc33523f5e2",
      "n": "0eiWxWDlrl2WuMp6fJiWDZiwaDKio38U1_yWWI-3yPw3nNL41xTLwxb0dNQ5LGkJhuZfdz4QFQlDnH7vGxJp2VH2H1HgmwuTcN4kIExVxP9Br1e93DIruWCnTXD_CP4S-SQ39_JtsvEpJ5VO4we2KmaN9TX0RUpUlGW5kQyDbpltKo-CwUR9rGfzgR0AxEQ1MWyGaWHyJ-KH3pmQbCRzqkU00zFa1W0NHiXSGzbTmoTuLUlS11EUz8RpK-fVTPdEE2QknLkj25PfmeLFTa6Ql6MNBUWCIQ0B8x4thOHJacs3GgkOs3DZandIUEzr71oRXWPnZqe3JYBIyNUfgVdSZw"
    }
  ]
}
```

- `kty` (key type) Key 类型为 RSA
- `e` (exponent) 指数 Base64urlUInt 编码。65537(0x10001) 分成每八位一组 [1,0,1]，再进行 base64url 编码 `Base64.urlsafe_encode64("\x01\x00\x01")`
- `kid` Key id
- `n` (modulus) 模

## 认证过程

1.1 浏览器请求客户端：

```http
GET / HTTP/1.1
Host: 127.0.0.1:8080
```

1.2 客户端响应。当前未认证，要求浏览器重定向到客户端认证端点：

```text
HTTP/1.1 302 
Set-Cookie: JSESSIONID=397EF385FF26BB3E552A048CB1DCB04E; Path=/; HttpOnly
Location: http://127.0.0.1:8080/oauth2/authorization/messaging-client-oidc
```

2.1 浏览器访问客户端认证端点：

```http
GET /oauth2/authorization/messaging-client-oidc HTTP/1.1
Host: 127.0.0.1:8080
Cookie: JSESSIONID=397EF385FF26BB3E552A048CB1DCB04E
```

2.2 客户端响应，要求浏览器携带参数重定向到认证服务器：

```text
HTTP/1.1 302 
Location: http://auth-server:9000/oauth2/authorize?
  response_type=code&
  client_id=messaging-client&
  scope=openid&
  state=IkcKi7_mUAE3cecByi6irNz9_Vnn0tKt9XgkflNOrN4%3D&
  redirect_uri=http://127.0.0.1:8080/login/oauth2/code/messaging-client-oidc&
  nonce=23Bmm-8v6xnn2QI2DL9FEfxBQPpaFlfMo8obYcMrSxk
```
- `response_type` 为 `code` 授权码模式
- `client_id` 当前 client 的 id
- `scope` 为 `openid`，身份认证
- `state` 状态码，用于跨站保护，防止暴力搜索客户端有效的授权码
- `redirect_uri` 重定向 URI
- `nonce` 随机数，防止重放攻击

3.1 浏览器携带参数访问认证服务器：

```http
GET /oauth2/authorize?response_type=code&client_id=messaging-client&scope=openid&state=IkcKi7_mUAE3cecByi6irNz9_Vnn0tKt9XgkflNOrN4%3D&redirect_uri=http://127.0.0.1:8080/login/oauth2/code/messaging-client-oidc&nonce=23Bmm-8v6xnn2QI2DL9FEfxBQPpaFlfMo8obYcMrSxk HTTP/1.1
Host: auth-server:9000
User-Agent: Mozilla/5.0
Cookie: JSESSIONID=39A32337C6E044BA18F7E3E7B670CD2D
```

3.2 认证通过，认证服务器响应，要求浏览器携带授权码和状态码重定向到客户端：

```text
HTTP/1.1 302 
Location: http://127.0.0.1:8080/login/oauth2/code/messaging-client-oidc?
  code=ywHSK_g_PqqRqKLQh0UKogrQrrmUJFlLz5zDHeeWFJ5KrBv5QhLiqONhPKGzbSMeWWQt7bCf-yj9uvzibyu0rVwvQR_s4k-VzDIBwD5PwOTu3d8jLehxS1_L2vlRrWgu&
  state=IkcKi7_mUAE3cecByi6irNz9_Vnn0tKt9XgkflNOrN4%3D
```
- `code` 授权码
- `state` 状态码，原样返回

4.1 浏览器携带授权码和状态码请求客户端：

```http
GET /login/oauth2/code/messaging-client-oidc?code=ywHSK_g_PqqRqKLQh0UKogrQrrmUJFlLz5zDHeeWFJ5KrBv5QhLiqONhPKGzbSMeWWQt7bCf-yj9uvzibyu0rVwvQR_s4k-VzDIBwD5PwOTu3d8jLehxS1_L2vlRrWgu&state=IkcKi7_mUAE3cecByi6irNz9_Vnn0tKt9XgkflNOrN4%3D HTTP/1.1
Host: 127.0.0.1:8080
Cookie: JSESSIONID=397EF385FF26BB3E552A048CB1DCB04E
```

4.1.1 客户端使用授权码请求认证服务器：

```http
POST /oauth2/token HTTP/1.1
Accept: application/json;charset=UTF-8
Content-Type: application/x-www-form-urlencoded;charset=UTF-8
Authorization: Basic bWVzc2FnaW5nLWNsaWVudDpzZWNyZXQ=
User-Agent: Java/11.0.13
Host: auth-server:9000

grant_type=authorization_code&
code=ywHSK_g_PqqRqKLQh0UKogrQrrmUJFlLz5zDHeeWFJ5KrBv5QhLiqONhPKGzbSMeWWQt7bCf-yj9uvzibyu0rVwvQR_s4k-VzDIBwD5PwOTu3d8jLehxS1_L2vlRrWgu&
redirect_uri=http%3A%2F%2F127.0.0.1%3A8080%2Flogin%2Foauth2%2Fcode%2Fmessaging-client-oidc
```
- `Authorization`  为 `base64(client-id:client-secret)` 用于客户端的认证
- `grant_type` `authorization_code` 授权码模式
- `code` 授权码
- `redirect_uri` 仅用于验证，要求与注册的客户端重定向 URI 一致

4.1.2 认证服务器响应，返回访问令牌：

```text
HTTP/1.1 200 
Set-Cookie: JSESSIONID=F9937A6ECF3F2E6EE885C81265A92754; Path=/; HttpOnly

{
  "access_token": "eyJraWQiOiI5OTQyMTFiYi05YzIzLTQyY2MtYThlYy1jMjI0YzE5NGE4ZWUiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ1c2VyIiwiYXVkIjoibWVzc2FnaW5nLWNsaWVudCIsIm5iZiI6MTYzNjg4MTExNCwic2NvcGUiOlsib3BlbmlkIl0sImlzcyI6Imh0dHA6XC9cL2F1dGgtc2VydmVyOjkwMDAiLCJleHAiOjE2MzY4ODE0MTQsImlhdCI6MTYzNjg4MTExNH0.tSgV4Ng2e07f3DnMd3SOEflyS57JtpssFb0_0kWn1ZxBHSp0hU6dninjQgJ2w0lrHmD10K32THqPR7WcFfjvb1tWFKFaLRUGyuuBTnjnc_dMaoJqfdbtwZriW_-gHOs_vLAKo6QbXM9d9FnQ2ugLtzYiBru2ls1qjN6BWBeHaQv04lr-XaPHFL01Sm92mURg0XaxzQ0sjjWLZUjWtnSYjCojXLdA9Z_wlA97xWhZCpdWR33pv3ACosxDyc3ZL69Rs1Jbrcyi1HcN8G8-RUpLoBJJTOGKZ0HI1AV3YVlpxqG07z6gxXV2Iqp4v-d1KYdkQvgoxDTfRgu-CUmAeGVfgQ",
  "refresh_token": "TRkqpUbOm7cGH23VTxBq1eaOXyz9089pNbhVspuMQIZb8_byYgzr6Amc8HZK_PsFkpgJ9MseyMfO45vWDjq0ciTFIovQZ4MvjQDWHXfmKot7f6MN0xtA7rDkbEd6pjTA",
  "scope": "openid",
  "id_token": "eyJraWQiOiI5OTQyMTFiYi05YzIzLTQyY2MtYThlYy1jMjI0YzE5NGE4ZWUiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ1c2VyIiwiYXVkIjoibWVzc2FnaW5nLWNsaWVudCIsImF6cCI6Im1lc3NhZ2luZy1jbGllbnQiLCJpc3MiOiJodHRwOlwvXC9hdXRoLXNlcnZlcjo5MDAwIiwiZXhwIjoxNjM2ODgyOTE0LCJpYXQiOjE2MzY4ODExMTQsIm5vbmNlIjoiMjNCbW0tOHY2eG5uMlFJMkRMOUZFZnhCUVBwYUZsZk1vOG9iWWNNclN4ayJ9.AmaVU49JU1ajktaRmcNXZqN7UhhyDVhAd7tIDF-WvzUjgQTSsEqe117hiAXI-ST-7mkdmVQoI5YBkm90FwEUgA_Me4d4TUl8eX5IWLoV9kJLGgYaD7_fCV4pjI9mBcBvy8tTj5ro-PGB82X7Cx-CQeD8dcGvw9WPujdES7fPEV4ZUFguEnUx4TAPJDWgbaQ4vcE8EYxhWj3feGJ_QysQZ0gOIiZGjq6rrOTB27Dm-0UX_bPbkE5y3V2nHDI1t-iqIrvwlFUO927-ULH0nDSJf6RcMFKlb6aJV4GaF5hR0g8AP88cxgspRjp1RjkUSGIQ1sm_vHV-wM1vdicQMkP9gg",
  "token_type": "Bearer",
  "expires_in": 299
}
```
- `access_token` 访问令牌, JWT 格式
- `refresh_token` 刷新令牌
- `scope` openid
- `id_token` 包含身份认证信息，JWT 格式
- `token_type` 令牌类型
- `expires_in` 过期时间 299 秒后过期

4.2 认证通过，客户端响应，要求浏览器重定向

```text
HTTP/1.1 302 
Set-Cookie: JSESSIONID=47DFC20A3B3D54C4C6F4B5F1287EF663; Path=/; HttpOnly
Location: http://127.0.0.1:8080/
```

5.1 浏览器请求客户端

```http
GET / HTTP/1.1
Host: 127.0.0.1:8080
Cookie: JSESSIONID=47DFC20A3B3D54C4C6F4B5F1287EF663
```

5.2 客户端响应

```text
HTTP/1.1 200 

Hello, user
```

## 请求资源

1.1 客户端请求资源：

```http
GET /messages HTTP/1.1
Authorization: Bearer eyJraWQiOiIzNDcxNDI3MC0xZTc4LTQ0NGEtOWVjYS00YmMzMzUyM2Y1ZTIiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ1c2VyIiwiYXVkIjoibWVzc2FnaW5nLWNsaWVudCIsIm5iZiI6MTYzNzE1NTg2MSwic2NvcGUiOlsib3BlbmlkIl0sImlzcyI6Imh0dHA6XC9cL2F1dGgtc2VydmVyOjkwMDAiLCJleHAiOjE2MzcxNTYxNjEsImlhdCI6MTYzNzE1NTg2MX0.PfpiwdStUcuKdB5kAChWAzWaoSV_vmBaQyjUATsi-LPSZRAUu7vOVED5LrtLqHqqyfgM_GIR61RxCxwt3u3zGfEzhmqSIcMQRs-yZUc977zBPBZsT9zM0Wff1cP-tX7yhWRC8lBhcLHyYrDLXhTteg788WBXNBwXOrvUjTm9icSU_2rvm9YkQkxbfaxKrtxZ1sMMcFIMZlIpn2hjA5irYaLqoVnf4d_RlM5_H73kzt3VC12DUyulA4jCkqxqdyfdddmO6F8HrKKbMaDqLOmJfcztBsPG4HRappqKniFmSQevSUMj_cIUxS5HgQJE2Zi_2wHCG4jPpRXa1SR_LBhCRQ
Host: 127.0.0.1:8090
```
- `Authorization` 格式为 `Bearer TOKEN`

1.1.1 资源服务器请求认证服务器，获取 jwk：

```http
GET /oauth2/jwks HTTP/1.1
Accept: application/json, application/jwk-set+json
Host: auth-server:9000
```

1.1.2 认证服务器响应 jwk 信息：

```text
HTTP/1.1 200 

{
  "keys": [
    {
      "kty":"RSA",
      "e":"AQAB",
      "kid":"34714270-1e78-444a-9eca-4bc33523f5e2",
      "n":"0eiWxWDlrl2WuMp6fJiWDZiwaDKio38U1_yWWI-3yPw3nNL41xTLwxb0dNQ5LGkJhuZfdz4QFQlDnH7vGxJp2VH2H1HgmwuTcN4kIExVxP9Br1e93DIruWCnTXD_CP4S-SQ39_JtsvEpJ5VO4we2KmaN9TX0RUpUlGW5kQyDbpltKo-CwUR9rGfzgR0AxEQ1MWyGaWHyJ-KH3pmQbCRzqkU00zFa1W0NHiXSGzbTmoTuLUlS11EUz8RpK-fVTPdEE2QknLkj25PfmeLFTa6Ql6MNBUWCIQ0B8x4thOHJacs3GgkOs3DZandIUEzr71oRXWPnZqe3JYBIyNUfgVdSZw"
    }
  ]
}
```

1.2 认证通过，资源服务器响应：

```text
HTTP/1.1 200 

["Message 1","Message 2","Message 3"]
```

## JWT

JWT 格式 `header.payload.signature`

### Access Token

```text
"access_token": "eyJraWQiOiI5OTQyMTFiYi05YzIzLTQyY2MtYThlYy1jMjI0YzE5NGE4ZWUiLCJhbGciOiJSUzI1NiJ9
  .eyJzdWIiOiJ1c2VyIiwiYXVkIjoibWVzc2FnaW5nLWNsaWVudCIsIm5iZiI6MTYzNjg4MTExNCwic2NvcGUiOlsib3BlbmlkIl0sImlzcyI6Imh0dHA6XC9cL2F1dGgtc2VydmVyOjkwMDAiLCJleHAiOjE2MzY4ODE0MTQsImlhdCI6MTYzNjg4MTExNH0
  .tSgV4Ng2e07f3DnMd3SOEflyS57JtpssFb0_0kWn1ZxBHSp0hU6dninjQgJ2w0lrHmD10K32THqPR7WcFfjvb1tWFKFaLRUGyuuBTnjnc_dMaoJqfdbtwZriW_-gHOs_vLAKo6QbXM9d9FnQ2ugLtzYiBru2ls1qjN6BWBeHaQv04lr-XaPHFL01Sm92mURg0XaxzQ0sjjWLZUjWtnSYjCojXLdA9Z_wlA97xWhZCpdWR33pv3ACosxDyc3ZL69Rs1Jbrcyi1HcN8G8-RUpLoBJJTOGKZ0HI1AV3YVlpxqG07z6gxXV2Iqp4v-d1KYdkQvgoxDTfRgu-CUmAeGVfgQ"
```

- 第一部分 `Base64.decode64(access_token.split('.')[0])`
  ```json
  {
    "kid": "994211bb-9c23-42cc-a8ec-c224c194a8ee",
    "alg": "RS256"
  }
  ```
  - `kid` key id
  - `alg` 签名算法


### ID Token

```text
"id_token": "eyJraWQiOiI5OTQyMTFiYi05YzIzLTQyY2MtYThlYy1jMjI0YzE5NGE4ZWUiLCJhbGciOiJSUzI1NiJ9
  .eyJzdWIiOiJ1c2VyIiwiYXVkIjoibWVzc2FnaW5nLWNsaWVudCIsImF6cCI6Im1lc3NhZ2luZy1jbGllbnQiLCJpc3MiOiJodHRwOlwvXC9hdXRoLXNlcnZlcjo5MDAwIiwiZXhwIjoxNjM2ODgyOTE0LCJpYXQiOjE2MzY4ODExMTQsIm5vbmNlIjoiMjNCbW0tOHY2eG5uMlFJMkRMOUZFZnhCUVBwYUZsZk1vOG9iWWNNclN4ayJ9
  .AmaVU49JU1ajktaRmcNXZqN7UhhyDVhAd7tIDF-WvzUjgQTSsEqe117hiAXI-ST-7mkdmVQoI5YBkm90FwEUgA_Me4d4TUl8eX5IWLoV9kJLGgYaD7_fCV4pjI9mBcBvy8tTj5ro-PGB82X7Cx-CQeD8dcGvw9WPujdES7fPEV4ZUFguEnUx4TAPJDWgbaQ4vcE8EYxhWj3feGJ_QysQZ0gOIiZGjq6rrOTB27Dm-0UX_bPbkE5y3V2nHDI1t-iqIrvwlFUO927-ULH0nDSJf6RcMFKlb6aJV4GaF5hR0g8AP88cxgspRjp1RjkUSGIQ1sm_vHV-wM1vdicQMkP9gg"
```

- 第一部分 `Base64.decode64 id_token.split('.')[0]`
  ```json
  {
    "kid": "994211bb-9c23-42cc-a8ec-c224c194a8ee",
    "alg": "RS256"
  }
  ```
  - `kid` key id
  - `alg` 签名算法
- 第二部分 `Base64.decode64 id_token.split('.')[1]`
  ```json
  {
    "sub": "user",
    "aud": "messaging-client",
    "azp": "messaging-client",
    "iss": "http:\/\/auth-server:9000",
    "exp": 1636882914,
    "iat": 1636881114,
    "nonce":"23Bmm-8v6xnn2QI2DL9FEfxBQPpaFlfMo8obYcMrSxk"
  }
  ```
  - `sub(subject)` 令牌的主体。令牌是关于谁的
  - `aud(audience)` 令牌的受众。令牌的接受者
  - `azp(authorized party)`
  - `iss(issuer)` 令牌的颁发者
  - `exp(expiration time)` 令牌过期时间戳
  - `iat(issued at)` 令牌颁发时间戳
  - `nonce` 随机数
- 第三部分为签名信息


## 参考

- [示例来源，有改动](https://github.com/spring-projects/spring-authorization-server/tree/0.2.0/samples/boot/oauth2-integration)
- https://openid.net/specs/openid-connect-discovery-1_0.html
- https://datatracker.ietf.org/doc/html/rfc7518#section-6.3 
