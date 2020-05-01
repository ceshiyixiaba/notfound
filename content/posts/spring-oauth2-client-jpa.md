---
title: "Spring Oauth2 Client JPA"
date: 2021-10-31T14:52:09+08:00
tags: ["spring"]
categories: ["spring"]
draft: false
---

- Spring Boot 2.5.5
- PostgreSQL

## 依赖

```gradle
implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
implementation 'org.springframework.boot:spring-boot-starter-security'
implementation 'org.springframework.boot:spring-boot-starter-web'
implementation 'org.springframework.boot:spring-boot-starter-oauth2-client'
runtimeOnly 'org.postgresql:postgresql'
```

## 配置

创建数据库:

```sql
-- 创建角色
CREATE ROLE example LOGIN PASSWORD 'YOUR_PASSWORD';
-- 创建数据了
CREATE DATABASE example_db WITH owner = example;
```

修改 `application.properties`:

```properties
spring.datasource.username=example
spring.datasource.password=YOUR_PASSWORD
spring.datasource.url=jdbc:postgresql://127.0.0.1/example_db
spring.jpa.generate-ddl=true
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

spring.security.oauth2.client.registration.github.client-id=CLIENT_ID
spring.security.oauth2.client.registration.github.client-secret=CLIENT_SECRET
spring.security.oauth2.client.registration.github.scope=read:user
```

## 代码

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        super.configure(http);
        http.oauth2Login();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return PasswordEncoderFactories.createDelegatingPasswordEncoder();
    }
}
```
- 开启基本认证、表单登陆和 oauth2 登陆
- 配置密码加密方式

```java
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;
    @Column(unique = true)
    private String username;
    private String password;
    private String provider;
    private String uid;
    // getter and setter
}
```
- `provider` registration id，如 `github`
- `uid` 三方平台上的用户 id

```java
public interface UserRepository extends CrudRepository<User, Integer> {
    Optional<User> findByUsername(String username);
    Optional<User> findByProviderAndUid(String provider, String uid);
}
```
- 两个基本查询

```java
public class CustomUser implements UserDetails, OAuth2User {
    private final String username;
    private final String password;

    public CustomUser(String username, String password) {
        this.username = username;
        this.password = password;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return AuthorityUtils.createAuthorityList("ROLE_USER");
    }
    // 省略其其他接口实现
}
```
- `CustomUser` 实现两个 `UserDetails` 和 `OAuth2User`，`UserDetails` 用于表单登陆和基本认证，`OAuth2User` 用于 OAuth2 登陆

```java
@Service
public class CustomUserDetailsService implements UserDetailsService {
    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() ->
                        new UsernameNotFoundException(username));

        return new CustomUser(user.getUsername(), user.getPassword());
    }
}
```
- 使用用户名密码登陆以及基本认证时，从数据库中查询用户

```java
@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {
    @Autowired
    private UserRepository userRepository;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);

        String provider = userRequest.getClientRegistration().getRegistrationId();
        String uid = oAuth2User.getName();

        User user = userRepository.findByProviderAndUid(provider, uid).orElse(null);
        if (user != null)
            return new CustomUser(user.getUsername(), user.getPassword());

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null)
            throw new OAuth2AuthenticationException("error");

        Object principal = authentication.getPrincipal();
        if (!(principal instanceof CustomUser))
            throw new OAuth2AuthenticationException("error");

        user = userRepository.findByUsername(((CustomUser) principal).getUsername()).get();
        if (user.getProvider() != null || user.getUid() != null)
            throw new OAuth2AuthenticationException("error");

        user.setProvider(provider);
        user.setUid(uid);
        userRepository.save(user);

        return new CustomUser(user.getUsername(), user.getPassword());
    }
}

```
- OAuth2 登陆，访问 URL http://localhost:8080/oauth2/authorization/github 时：
  - 账号已经绑定，直接登陆
  - 账号未绑定且已经登陆，绑定账号并登陆

## 参考

- https://spring.io/guides/tutorials/spring-boot-oauth2/
