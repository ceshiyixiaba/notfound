---
title: "Spring 记住登陆状态"
date: 2021-10-23T11:02:25+08:00
tags: ["spring"]
categories: ["spring"]
draft: false
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

## 代码

配置 rememberMe `SecurityConfig.java`:

```java
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {
    @Autowired
    private UserDetailsService userDetailsService;

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        super.configure(http);
        http.rememberMe()
                .key("1234567890")
                .userDetailsService(userDetailsService);
    }
}
```
- 配置 RememberMe `key` 以及 `userDetailsService`
- 将会使用 `TokenBasedRememberMeServices` 处理 rememberMe token

受保护的资源 `HomeController.java`:

```java
@RestController
public class HomeController {
    @GetMapping("/")
    public ResponseEntity<String> index(Authentication authentication) {
        return ResponseEntity.ok("Hello, " + authentication.getName());
    }
}
```

RememberMe token 格式:

```text
base64(username + ":" + expirationTime + ":" +
  md5Hex(username + ":" + expirationTime + ":" password + ":" + key))
```
- password 为持久化所保存的被 hash 的 `password`

## 过程

### 登陆

`UsernamePasswordAuthenticationFilter` 处理登陆：
- `UsernamePasswordAuthenticationFilter#doFilter`
  - `UsernamePasswordAuthenticationFilter#successfulAuthentication`
    - `TokenBasedRememberMeServices#loginSuccess` 记住登陆状态
      - `TokenBasedRememberMeServices#onLoginSuccess` 计算 rememberMe 的 token，并添加到 cookie

### 认证

`RememberMeAuthenticationFilter` 处理认证:
- `RememberMeAuthenticationFilter#doFilter`
  - `TokenBasedRememberMeServices#autoLogin`
    - `TokenBasedRememberMeServices#processAutoLoginCookie` 从 cookie 中提取 token 并验证过期以及签名
    - `TokenBasedRememberMeServices#createSuccessfulAuthentication` 创建 `Authentication`(RememberMeAuthenticationToken)
  - `RememberMeAuthenticationProvider#authenticate` 验证 `key`
  - `SecurityContextHolder.getContext().setAuthentication()` 设置 authentication
  - `RememberMeAuthenticationFilter#onSuccessfulAuthentication`
