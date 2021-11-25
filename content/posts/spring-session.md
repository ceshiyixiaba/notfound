---
title: "Spring Session"
date: 2021-11-22T22:28:22+08:00
tags: ["spring"]
draft: true
---

## 依赖

```gradle
implementation 'org.springframework.boot:spring-boot-starter-security'
implementation 'org.springframework.boot:spring-boot-starter-web'
implementation 'org.springframework.session:spring-session-data-redis'
implementation 'io.lettuce:lettuce-core'
```

## 代码

`SessionConfig.java`

```java
@EnableRedisHttpSession
public class SessionConfig {
    @Bean
    public LettuceConnectionFactory connectionFactory() {
        return new LettuceConnectionFactory();
    }
}
```

## 过程

### 登陆

登陆时会变更 session id

- `AbstractAuthenticationProcessingFilter#doFilter`
  - `AbstractSessionFixationProtectionStrategy#onAuthentication`
    - `ChangeSessionIdAuthenticationStrategy#applySessionFixation` 变更 session id

### 更新过期时间

每次请求时，会刷新过期时间，session 默认过期时间为 1800s

- `SessionRepositoryFilter#doFilterInternal`
  - `SessionRepositoryRequestWrapper#commitSession`
    - `RedisIndexedSessionRepository#save`
      - `RedisIndexedSessionRepository#saveDelta`
        - `RedisSessionExpirationPolicy#onExpirationUpdated`

