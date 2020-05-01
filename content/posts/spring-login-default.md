---
title: "Spring 默认表单登陆"
date: 2021-10-17T17:10:56+08:00
tags: ["spring"]
categories: ["spring"]
---

- Spring Boot 2.5.5

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

## 登陆页面

`DefaultLoginPageGeneratingFilter` 生成登陆页面：

- 生成登陆页面
- 设置用户名和密码参数名称

## 登陆过程

`UsernamePasswordAuthenticationFilter` 处理登陆：

- `UsernamePasswordAuthenticationFilter#doFilter`
  - `UsernamePasswordAuthenticationFilter#attemptAuthentication` 认证， 得到 Authentication
    - 从表单中获取用户名和密码
    - 使用 `username` 和 `password` 创建 `UsernamePasswordAuthenticationToken` (authRequest)
    - `AuthenticationManager#authenticate` 验证 authRequest
      - `ProviderManager#authenticate`
        - `DaoAuthenticationProvider#authenticate` 查询用户，检查用户状态，认证
          - `DaoAuthenticationProvider#retrieveUser` 查询用户
            - `UserDetailsService#loadUserByUsername` (InMemoryUserDetailsManager) 通过用户名查询用户
          - `DaoAuthenticationProvider#additionalAuthenticationChecks` 用户名、密码认证
  - `SessionAuthenticationStrategy#onAuthentication` session 与用户建立关联
  - `UsernamePasswordAuthenticationFilter#successfulAuthentication`
    - `SecurityContextHolder.getContext().setAuthentication` 在 context 中设置认证信息
    - `RememberMeServices#loginSuccess` 记住登陆状态
    - `SavedRequestAwareAuthenticationSuccessHandler#onAuthenticationSuccess`
      - 之后会通过 `SaveToSessionResponseWrapper#saveContext` 将 `SecurityContext` 保存到 session 中，key 为 `SPRING_SECURITY_CONTEXT`

主要操作

- 可通过 `UserDetailsService` 配置用户查询方式
- 可通过 `SecurityContextHolder.getContext().setAuthentication()` 设置认证状态
- 可通过 `RememberMeServices` 记住登陆登陆状态

## session

认证成功后会通过 `SaveToSessionResponseWrapper#saveContext` 将 `SecurityContext` 保存到 session 中，key 为 `SPRING_SECURITY_CONTEXT`

下次请求从 session 中读取 `SecurityContext`

- `SecurityContextPersistenceFilter#doFilter`
  - `HttpSessionSecurityContextRepository#loadContext`
  - `HttpSessionSecurityContextRepository#readSecurityContextFromSession`

