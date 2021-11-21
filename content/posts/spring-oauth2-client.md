---
title: "Spring OAuth2 Client"
date: 2021-10-26T21:44:13+08:00
tags: ["spring", "oauth2"]
categories: ["spring"]
draft: false
---

- Spring Boot 2.5.5

## 依赖

```gradle
implementation 'org.springframework.boot:spring-boot-starter-security'
implementation 'org.springframework.boot:spring-boot-starter-web'
implementation 'org.springframework.boot:spring-boot-starter-oauth2-client'
```

## 配置

修改 `application.properties`

```properties
spring.security.oauth2.client.registration.github.client-id=CLIENT_ID
spring.security.oauth2.client.registration.github.client-secret=CLIENT_SECRET
spring.security.oauth2.client.registration.github.scope=read:user
```

## 代码

添加 `SecurityConfig.java` 开启 oauth2 登陆功能:

```java
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests((requests) -> requests.anyRequest().authenticated());
        http.oauth2Login();
    }
}
```

添加 `HomeController.java` 获取当前用户:

```java
@RestController
public class HomeController {
    @GetMapping("/")
    public ResponseEntity<String> index(Authentication authentication) {
        return ResponseEntity.ok("Hello, " + authentication.getName());
    }
}
```
## 登陆过程

客户端将浏览器重定向到授权端点：

```text
GET http://localhost:8080/oauth2/authorization/github
Referer: http://localhost:8080/login

# 响应
HTTP/1.1 302
https://github.com/login/oauth/authorize?response_type=code&client_id=532062cd2c5d82582dd5&scope=read:user public_repo&state=yDLHE9yFhA8X6P3hoTeZdirVXp2XTER1IghdjIM6W5A=&redirect_uri=http://localhost:8080/login/oauth2/code/github
```

- `OAuth2AuthorizationRequestRedirectFilter#doFilterInternal`
  - `DefaultOAuth2AuthorizationRequestResolver#resolve` 创建 OAuth2AuthorizationRequest
    - `DefaultOAuth2AuthorizationRequestResolver#resolve` 创建 OAuth2AuthorizationRequest
      - `InMemoryClientRegistrationRepository#findByRegistrationId` 通过 `registrationId`(github) 查询 ClientRegistration
      - `DefaultOAuth2AuthorizationRequestResolver#expandRedirectUri` 计算 redirect url
      - `OAuth2AuthorizationRequest.Build` 通过 builder 构建 `OAuth2AuthorizationRequest`
  - `OAuth2AuthorizationRequestRedirectFilter#sendRedirectForAuthorization`
    - `HttpSessionOAuth2AuthorizationRequestRepository#saveAuthorizationRequest` 将 `authorizationRequest` 保存到 session
    - DefaultRedirectStrategy#sendRedirect 重定向

资源所有者向授权服务器进行身份认证，并向客户端授权，授权服务器将浏览器重定向到客户端，并携带授权码：

```text
GET https://github.com/login/oauth/authorize?response_type=code&client_id=532062cd2c5d82582dd5&scope=read:user%20public_repo&state=yDLHE9yFhA8X6P3hoTeZdirVXp2XTER1IghdjIM6W5A%3D&redirect_uri=http://localhost:8080/login/oauth2/code/github
Referer: http://localhost:8080/

# 响应
HTTP/1.1 302
Location: http://localhost:8080/login/oauth2/code/github?code=2208a051c97858d376b9&state=yDLHE9yFhA8X6P3hoTeZdirVXp2XTER1IghdjIM6W5A%3D
```

客户端将授权码和自身凭据发送至令牌端点，授权服务器向客户端发送令牌，客户端向首保护资源发送令牌：

```text
GET http://localhost:8080/login/oauth2/code/github?code=2208a051c97858d376b9&state=yDLHE9yFhA8X6P3hoTeZdirVXp2XTER1IghdjIM6W5A%3D
Referer: http://localhost:8080/

# 响应
HTTP/1.1 302
Location: http://localhost:8080/
Set-Cookie: JSESSIONID=2DABF2CECF52AB6AF4F16351202F4435; Path=/; HttpOnly
```

- `OAuth2LoginAuthenticationFilter#requiresAuthentication`
  - `HttpSessionOAuth2AuthorizationRequestRepository#removeAuthorizationRequest` session 中读取 OAuth2AuthorizationRequest 后移除
    - `HttpSessionOAuth2AuthorizationRequestRepository#getAuthorizationRequests` 从 session 中获取 `OAuth2AuthorizationRequest`
  - `InMemoryClientRegistrationRepository#findByRegistrationId` 查询 Registration
  - `new OAuth2LoginAuthenticationToken` 创建认证对象
  - `OAuth2LoginAuthenticationToken#setDetails` 创建认证对象
  - `OAuth2LoginAuthenticationProvider#authenticate` 认证
    - `OAuth2AuthorizationCodeAuthenticationProvider#authenticate` 对比 state
      - `DefaultAuthorizationCodeTokenResponseClient#getTokenResponse` 获取 token
      - `DefaultOAuth2UserService#loadUser` 加载用户信息
        - `DefaultOAuth2UserService#getResponse` 使用 token 查询用户信息
        - 通过返回的用户信息创建 `DefaultOAuth2User`
      - 创建 `OAuth2LoginAuthenticationToken`，设置后返回
- `AbstractAuthenticationProcessingFilter#successfulAuthentication`
  - `SecurityContextHolder.getContext().setAuthentication()` 在 context 中设置认证信息

需要 session 保存 OAuth2AuthorizationRequest 对象，`/oauth2/authorization/github` 和 `/login/oauth2/code/github` 要使用同一个 session

## 参考

- 《OAuth2 实战》
- https://spring.io/guides/tutorials/spring-boot-oauth2/
