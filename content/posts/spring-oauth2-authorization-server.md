---
title: "Spring OAuth2 认证服务器"
date: 2021-11-20T10:29:42+08:00
tags: ["spring", "oauth2"]
categories: ["oauth2"]
draft: false
---

## 获取 OpenID 配置信息 `/.well-known/openid-configuration`

- `OidcProviderConfigurationEndpointFilter`

## 获取授权码 `/oauth2/authorize`

获取授权码流程如下：

- `OAuth2AuthorizationEndpointFilter#doFilterInternal`
  - `OAuth2AuthorizationCodeRequestAuthenticationConverter#convert` 从请求中提取参数
  - `OAuth2AuthorizationCodeRequestAuthenticationProvider#authenticate`认证，生成 code
    - `OAuth2AuthorizationCodeRequestAuthenticationProvider#authenticateAuthorizationRequest`
      - `JdbcRegisteredClientRepository#findByClientId` 查询客户端
      - `OAuth2AuthenticationValidator#validate` 验证重定向 URL
      - `JdbcOAuth2AuthorizationConsentService#findById`
      - `OAuth2AuthorizationCodeRequestAuthenticationProvider#generateAuthorizationCode` 生成授权码
      - `JdbcOAuth2AuthorizationService#save` 保存 OAuth2Authorization 对象
      - 构建 `OAuth2AuthorizationCodeRequestAuthenticationToken` 对象
  - `OAuth2AuthorizationEndpointFilter#sendAuthorizationResponse` 生成带授权码的重定向 URL

与用户直接相关:

- `JdbcRegisteredClientRepository`
- `JdbcOAuth2AuthorizationConsentService`
- `JdbcOAuth2AuthorizationService`

## 获取访问令牌 `/oauth2/token`

- `OAuth2TokenEndpointFilter#doFilterInternal`
  - `OAuth2AuthorizationCodeAuthenticationConverter#convert` 通过请求内容创建 `OAuth2AuthorizationCodeAuthenticationToken`
  - `OAuth2AuthorizationCodeAuthenticationProvider#authenticate`
    - `JdbcOAuth2AuthorizationService#findByToken`  通过 token 查询 `OAuth2Authorization`
    - `NimbusJwsEncoder#encode` 构建访问令牌
    - `OAuth2AuthorizationCodeAuthenticationProvider#generateRefreshToken` 构建刷新令牌
    - 构建 ID TOKEN
    - `JdbcOAuth2AuthorizationService#save` 保存 `OAuth2Authorization`
    - 返回 `OAuth2AccessTokenAuthenticationToken` 对象
  - `OAuth2TokenEndpointFilter#sendAccessTokenResponse` 响应

与用户直接相关:
- `JdbcOAuth2AuthorizationService`

## 获取 JWKs `/oauth2/jwks`

- `NimbusJwkSetEndpointFilter`
  - `jwkSource` 获取 key 列表
  - jwks 响应

与用户直接相关:

- jwkSource

## 撤销令牌 `/oauth2/revoke`

- `OAuth2TokenRevocationEndpointFilter`

A Filter for the OAuth 2.0 Token Revocation endpoint.

## 令牌内省 `/oauth2/introspect`

- `OAuth2TokenIntrospectionEndpointFilter`

## 客户端动态注册 `/connect/register`

- `OidcClientRegistrationEndpointFilter`

## 请求元数据 `/.well-known/oauth-authorization-server`

- `OAuth2AuthorizationServerMetadataEndpointFilter`

## 用户信息 `/userinfo`

- `OidcUserInfoEndpointFilter`

## 参考

- https://github.com/spring-projects/spring-authorization-server/tree/0.2.0/samples/boot/oauth2-integration
