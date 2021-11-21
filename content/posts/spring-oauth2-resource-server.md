---
title: "Spring OAuth2 资源服务器"
date: 2021-11-20T10:30:05+08:00
tags: ["spring", "oauth2"]
categories: ["oauth2"]
draft: false
---

## TOKEN 认证过程

- `BearerTokenAuthenticationFilter#doFilterInternal` 验证 Token
  - `JwtAuthenticationProvider#authenticate`
    - `JwtAuthenticationProvider#getJwt`
      - `NimbusJwtDecoder#decode` 将字符串 TOKEN 转换为 Jwt
        - `NimbusJwtDecoder#parse` 解析TOKEN 获得 SignedJWT 对象
          - `NimbusJwtDecoder.parse`
            - `SignedJWT#parse` 创建 SignedJWT
        - `JwtAuthenticationProvider#createJwt` 通过 SignedJWT 创建 JWT
         - `DefaultJWTProcessor#process` 验证签名
         - 使用 `Jwt.Builder` 创建 Jwt 返回
        - `JwtAuthenticationProvider#validateJwt` 验证 Jwt
          - `DelegatingOAuth2TokenValidator#validate`
            - `JwtTimestampValidator#validate` 验证是否过期
            - `JwtIssuerValidatorv#validate`
              - `JwtClaimValidator#validate` 验证声明
    - `JwtAuthenticationConverter#convert` 使用 jwt 创建认证对象 JwtAuthenticationToken

## 参考

- https://github.com/spring-projects/spring-authorization-server/tree/0.2.0/samples/boot/oauth2-integration
