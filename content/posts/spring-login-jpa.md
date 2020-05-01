---
title: "Spring 默认表单以及 JPA 登陆"
date: 2021-10-17T17:15:20+08:00
tags: ["spring"]
categories: ["spring"]
---

- Spring Boot 2.5.5
- PostgreSQL

通过实现 `UserDetailsService` 接口从 PostgreSQL 中查询用户。

## 依赖

```gradle
implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
implementation 'org.springframework.boot:spring-boot-starter-security'
implementation 'org.springframework.boot:spring-boot-starter-web'
runtimeOnly 'org.postgresql:postgresql'
```

## 配置

修改 `application.properties`，设置用户名和密码

```properties
spring.datasource.username=example
spring.datasource.password=YOUR_PASSWORD
spring.datasource.url=jdbc:postgresql://127.0.0.1/example_db
spring.jpa.generate-ddl=true
```
- 需要在 PostgreSQL 中创建数据库 `example_db`
- `generate-ddl` 自动生成表结构

## 基本过程

### 1. 创建 `User.java`:

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
    // 省略 getter 和 setter
}
```
- `application.properties` 已配置自动生成表结构

### 2. 创建 `UserRepository.java`

```java
public interface UserRepository extends CrudRepository<User, Integer> {
    Optional<User> findByUsername(String username);
}
```
- JPA 自动生成查询: 通过用户名查询 User

### 3. 创建 `CustomUserDetailsService.java` 实现 `UserDetailsService` 接口:

```java
@Component
public class CustomUserDetailsService implements UserDetailsService {
    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException(username));
        return new org.springframework.security.core.userdetails.User(user.getUsername(), user.getPassword(), AuthorityUtils.NO_AUTHORITIES);
    }
}
```
- Spring 通过 `UserDetailsService#loadUserByUsername` 查询登陆用户，之后会对 username 和 password 进行校验

### 4. 修改 `DemoApplication.java`

```java
@SpringBootApplication
public class DemoApplication implements ApplicationRunner {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
	}

	@Autowired
	private UserRepository userRepository;
	@Autowired
	private PasswordEncoder passwordEncoder;

	@Override
	public void run(ApplicationArguments args) {
		if (userRepository.count() > 0) return;

		User user = new User();
		user.setUsername("tester");
		user.setPassword(passwordEncoder.encode("password"));
		userRepository.save(user);
	}

	@Bean
	public PasswordEncoder passwordEncoder() {
		return PasswordEncoderFactories.createDelegatingPasswordEncoder();
	}
}
```
- `ApplicationRunner#run` 只是为了在程序启动时创建一个用户
- `PasswordEncoder` 配置密码加密方式

### 5. 资源

```java
@RestController
public class Home {
    @GetMapping("/")
    public ResponseEntity<String> index(Authentication authentication) {
        return ResponseEntity.ok("Hello, " + authentication.getName());
    }
}
```
- 获取当前用户的用户名
