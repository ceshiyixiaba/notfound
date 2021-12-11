---
title: "Spring Session"
date: 2021-12-11T16:28:22+08:00
tags: ["spring", "java"]
---

- spring boot 2.6.1

## 依赖

```gradle
implementation 'org.springframework.boot:spring-boot-starter-data-redis'
implementation 'org.springframework.boot:spring-boot-starter-security'
implementation 'org.springframework.boot:spring-boot-starter-web'
implementation 'org.springframework.session:spring-session-data-redis'
```
- `spring-boot-starter-data-redis` 包含 redis 驱动

## 配置

```properties
spring.security.user.name=admin
spring.security.user.password=123456
```
- redis 会使用默认配置

## 代码

配置 Spring Session：

```java
@EnableRedisHttpSession
public class HttpSessionConfig {
    @Bean
    public HttpSessionIdResolver httpSessionIdResolver() {
        return HeaderHttpSessionIdResolver.xAuthToken();
    }
}
```
- 使用 HTTP 头部 `X-Auth-Token` 保存会话信息，适用于 RESTful APIs:

配置 Spring Security：

```java
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests((requests) -> requests
                .antMatchers("/guest/*").permitAll()
                .anyRequest().authenticated()
        );
        http.httpBasic();
    }
}
```
- `/guest/*` 无需认证，其他都需要认证
- 开启 basic 认证

添加控制器：

```java
@RestController
public class HomeController {
    @Autowired
    private HttpSession httpSession;

    @GetMapping("/")
    public String index(Authentication authentication) {
        return "Hello, " + authentication.getName();
    }

    @GetMapping("/guest/ping")
    public String ping() {
        return "Pong";
    }

    @GetMapping("/guest/session")
    public String guest() {
        return "Hello, " + httpSession.getId();
    }
}
```
- `/` 需要认证
- `/guest/ping` 无需认证
- `/guest/session` 无需认证，但会读取 session

## 过程

### 无认证信息且路由无需认证

不会生成 Session
 
```text
curl -v http://localhost:8080/guest/ping
> GET /guest/ping HTTP/1.1
> Host: localhost:8080
> 
< HTTP/1.1 200 
< 
Pong
```

### 认证错误且路由无需认证

此时会创建 session

```text
curl -v -u admin:12345 http://localhost:8080/guest/ping
*   Trying 127.0.0.1:8080...
> GET /guest/ping HTTP/1.1
> Host: localhost:8080
> Authorization: Basic YWRtaW46MTIzNDU=
> 
< HTTP/1.1 401 
< WWW-Authenticate: Basic realm="Realm"
< X-Auth-Token: 720424bb-cd6f-44c2-8e65-9fb71fb8a434
< 
```
返回 session id：
- `ExceptionTranslationFilter#doFilter`
  - `ExceptionTranslationFilter#handleSpringSecurityException`
    - `ExceptionTranslationFilter#sendStartAuthentication`
      - `BasicAuthenticationEntryPoint#commence`
        - `HttpSessionSecurityContextRepository$SaveToSessionResponseWrapper#sendError`
          - `SessionRepositoryFilter$SessionRepositoryRequestWrapper#commitSession`
            - `HeaderHttpSessionIdResolver#setSessionId` 创建 `X-Auth-Token` 头部

### 无认证信息且路由无需认证，获取 session

此时会创建 session

```text
$ curl -v http://localhost:8080/guest/session
> GET /guest/session HTTP/1.1
> Host: localhost:8080
> 
< HTTP/1.1 200 
< X-Auth-Token: 6ae5475f-3a17-4703-8c68-bdfc5c67bc24
< 
Hello, 6ae5475f-3a17-4703-8c68-bdfc5c67bc24
```
返回 session id：
- `SessionRepositoryFilter$SessionRepositoryResponseWrapper#checkContentLength`
  - `SessionRepositoryFilter$SessionRepositoryRequestWrapper#commitSession`
    - `HeaderHttpSessionIdResolver#setSessionId` 创建 `X-Auth-Token` 头部

### 携带认证信息访问受保护的路由

此时会创建 session

```text
curl -v -u admin:123456 http://localhost:8080
> GET / HTTP/1.1
> Host: localhost:8080
> Authorization: Basic YWRtaW46MTIzNDU2
> 
< HTTP/1.1 200 
< X-Auth-Token: 92d42f7a-0ac9-4044-bb66-9645dd42ba0e
< 
Hello, admin
```
- `SessionRepositoryFilter$SessionRepositoryResponseWrapper#checkContentLength`
  - `SessionRepositoryFilter$SessionRepositoryRequestWrapper#commitSession`
    - `HeaderHttpSessionIdResolver#setSessionId` 创建 `X-Auth-Token` 头部

### 携带 `X-Auth-Token` 访问受保护的路由

```text
$ curl -v -H "X-Auth-Token: 84deb00a-8b71-4dd9-af1a-2cef9cb029a4" http://localhost:8080
> GET / HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.79.1
> Accept: */*
> X-Auth-Token: 84deb00a-8b71-4dd9-af1a-2cef9cb029a4
> 
< HTTP/1.1 200 
< 
Hello, admin
```
通过 Token 认证：
- `SecurityContextPersistenceFilter#doFilter`
  - `HttpSessionSecurityContextRepository#loadContext`
    - `SessionRepositoryFilter$SessionRepositoryRequestWrapper#getSession`
      - `SessionRepositoryFilter$SessionRepositoryRequestWrapper#getRequestedSession`
        - `RedisIndexedSessionRepository#findById` 通过 session id 查询 session

更新过期时间：
- `SessionRepositoryFilter#doFilterInternal`
  - `SessionRepositoryFilter$SessionRepositoryRequestWrapper#commitSession`
    - `RedisIndexedSessionRepository#save`
      - `RedisIndexedSessionRepository$RedisSession#save`
        - `RedisIndexedSessionRepository$RedisSession#saveDelta`
          - `RedisSessionExpirationPolicy#onExpirationUpdated` 更新过期时间

### 携带认证信息和 `X-Auth-Token` 访问受保护的路由

`X-Auth-Token` 是认证未通过时返回的 Token

认证未通过 session id 保持不变：

```text
$ curl -v -u admin:12345 -H "X-Auth-Token: ea7a8601-420a-4e37-95d6-c716cacd7f9c" http://localhost:8080 
> GET / HTTP/1.1
> Host: localhost:8080
> Authorization: Basic YWRtaW46MTIzNDU=
> X-Auth-Token: ea7a8601-420a-4e37-95d6-c716cacd7f9c
> 
< HTTP/1.1 401 
< WWW-Authenticate: Basic realm="Realm"
< 
```

认证通过 session id 变更：

```text
$ curl -v -u admin:123456 -H "X-Auth-Token: ea7a8601-420a-4e37-95d6-c716cacd7f9c" http://localhost:8080
> GET / HTTP/1.1
> Host: localhost:8080
> Authorization: Basic YWRtaW46MTIzNDU2
> X-Auth-Token: ea7a8601-420a-4e37-95d6-c716cacd7f9c
> 
< HTTP/1.1 200 
< X-Auth-Token: ce43a60a-98db-4eae-a48d-e54bdecde9d4
< 
Hello, admin
```
变更 session id：
- `SessionManagementFilter#doFilter`
  - `CompositeSessionAuthenticationStrategy#onAuthentication`
    - `ChangeSessionIdAuthenticationStrategy#onAuthentication`
      - `ChangeSessionIdAuthenticationStrategy#applySessionFixation` 变更 session id

返回新的 session id：
- `SessionRepositoryFilter$SessionRepositoryResponseWrapper#checkContentLength`
  - `SessionRepositoryFilter$SessionRepositoryRequestWrapper#commitSession`
    - `HeaderHttpSessionIdResolver#setSessionId` 创建 `X-Auth-Token` 头部

## 参考

- https://docs.spring.io/spring-session/reference/http-session.html
