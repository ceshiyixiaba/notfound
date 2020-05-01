---
title: "Spring 基本认证"
date: 2021-10-17T21:05:26+08:00
tags: ["spring"]
categories: ["spring"]
---

- Spring Boot 2.5.5


HTTP 基本认证(Basic Authentication)，通过头部设置认证信息 `Authorization: Basic <凭证>`，凭证为 `base64("username:password")`

## 依赖

```gradle
implementation 'org.springframework.boot:spring-boot-starter-security'
implementation 'org.springframework.boot:spring-boot-starter-web'
```

## 配置

修改 `application.properties`，设置用户名和密码

```properties
spring.security.user.name=admin
spring.security.user.password=123456
```
- `echo -n "admin:123456" | base64` 结果为 `YWRtaW46MTIzNDU2`

## 代码

添加 `HomeController.java` :

```java
@RestController
public class HomeController {
    @GetMapping("/")
    public ResponseEntity<String> index(Authentication authentication) {
        return ResponseEntity.ok("Hello, " + authentication.getName());
    }
}
```

## 测试

```bash
curl -I --header "Authorization: Basic YWRtaW46MTIzNDU2" http://localhost:8080
```

## 登陆过程

`BasicAuthenticationFilter` 认证：

- `BasicAuthenticationFilter#doFilterInternal`
  - `BasicAuthenticationConverter#convert` 从请求中提取用户名和密码生成 authRequest
  - `AuthenticationManager#authenticate` 验证 authRequest
    - `ProviderManager#authenticate`
      - `DaoAuthenticationProvider#authenticate` 查询用户，检查用户状态，认证
        - `DaoAuthenticationProvider#retrieveUser` 查询用户
          - `UserDetailsService#loadUserByUsername` (InMemoryUserDetailsManager) 通过用户名查询用户
        - `DaoAuthenticationProvider#additionalAuthenticationChecks` 用户名、密码认证
  - `SecurityContextHolder.getContext().setAuthentication` 在 context 中设置认证信息
  - `RememberMeServices#loginSuccess` 记住登陆状态

主要操作

- 可通过 `UserDetailsService` 配置用户查询方式
- 可通过 `SecurityContextHolder.getContext().setAuthentication()` 设置认证状态
- 可通过 `RememberMeServices` 记住登陆登陆状态
