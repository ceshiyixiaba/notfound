+++
title = "GraphQL Java 以及 Spring Boot: Context"
author = ["likui"]
date = 2021-03-27T17:00:00+08:00
lastmod = 2021-03-27T17:04:05+08:00
tags = ["java", "graphql", "spring"]
categories = ["graphql"]
draft = false
+++

## GraphQL Java 以及 Spring Boot: Context {#graphql-java-以及-spring-boot-context}

-   OpenJDK 11
-   Gradle 6.8

`DataFetchingEnvironment` 中存在一个 `Context` ，在整个查询生命周期中不变。

修改了示例 [<https://notfound.cn/posts/graphql-java-getting-started/>] 在 context 中传递 user 信息。


### 依赖 {#依赖}

```groovy
implementation 'com.graphql-java:graphql-java:16.2' // 新
implementation 'com.graphql-java:graphql-java-spring-boot-starter-webmvc:2.0' // 新
implementation 'com.google.guava:guava:30.1.1-jre' // 新(可选)

implementation 'org.springframework.boot:spring-boot-starter-security'
implementation 'org.springframework.boot:spring-boot-starter-web'
testImplementation 'org.springframework.boot:spring-boot-starter-test'
testImplementation 'org.springframework.security:spring-security-test'
```


### Spring Security 配置 {#spring-security-配置}

```java
@Configuration
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.csrf().disable()
                .authorizeRequests().anyRequest().permitAll()
                .and()
                .httpBasic();
    }

    @Bean
    @Override
    public UserDetailsService userDetailsService() {
        UserDetails user = User.withDefaultPasswordEncoder()
                .username("admin")
                .password("password")
                .roles("USER")
                .build();

        return new InMemoryUserDetailsManager(user);
    }
}
```


### 创建 bean ExecutionInputCustomizer {#创建-bean-executioninputcustomizer}

```java
@Component
public class GraphQLProvider {
    private GraphQL graphQL;
    private ExecutionInputCustomizer executionInputCustomizer;
    private GraphQLDataFetchers dataFetchers;

    @Autowired
    public GraphQLProvider(GraphQLDataFetchers dataFetchers) {
        this.dataFetchers = dataFetchers;
    }

    @PostConstruct
    public void init() throws IOException {
        // 省略部分代码
        this.executionInputCustomizer = new ExampleExecutionInputCustomizer();
    }

    // 省略部分代码

    // 提供 bean 给 graphql-java-spring-webmvc 使用
    @Bean
    public ExecutionInputCustomizer executionInputCustomizer() {
        return executionInputCustomizer;
    }
}
```

-   提供 bean `ExecutionInputCustomizer` 给 graphql-java-spring-webmvc 使用


### ExecutionInputCustomizer {#executioninputcustomizer}

```java
@Component
public class ExampleExecutionInputCustomizer implements ExecutionInputCustomizer {
    @Override
    public CompletableFuture<ExecutionInput> customizeExecutionInput(ExecutionInput executionInput, WebRequest webRequest) {
        Principal principal = webRequest.getUserPrincipal();
        if (principal != null) {
            GraphQLContext context = (GraphQLContext) executionInput.getContext();
            context.put("principal", principal);
        }
        return CompletableFuture.completedFuture(executionInput);
    }
}
```

-   将当前用户信息保存到 Context，整个查询都可通过 Context 方法到当前用户信息


### DataFetcher {#datafetcher}

```java
@Component
public class GraphQLDataFetchers {
    DataFetcher<String> hello = environment -> {
        GraphQLContext context = environment.getContext();
        Principal principal = context.get("principal");
        System.out.println(principal);
        if (principal != null) {
            return principal.getName();
        } else {
            return "world";
        }
    };
}
```

-   从 context 获取当前用户信息
-   之前 `hello` 方法改成了变量


### 访问 {#访问}

使用 [graphql-playground](https://github.com/graphql/graphql-playground) 作为客户端，设置 HTTP HEADS 即可认证：

```json
{
  "Authorization": "Basic YWRtaW46cGFzc3dvcmQ="
}
```


### 参考 {#参考}

-   <https://spring.io/guides/gs/securing-web/>
-   <https://www.graphql-java.com/documentation/v16/data-fetching/>
