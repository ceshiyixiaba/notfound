+++
title = "GraphQL Java 以及 Spring Boot 入门"
author = ["likui"]
date = 2021-03-24
lastmod = 2021-03-24T23:16:33+08:00
tags = ["java", "graphql", "spring"]
categories = ["graphql"]
draft = false
+++

## GraphQL Java 以及 Spring Boot 入门 {#graphql-java-以及-spring-boot-入门}

-   OpenJDK 11
-   Gradle 6.8


### Spring Initializr {#spring-initializr}

[Spring Initializr](https://start.spring.io/) 生成 Spring Boot 项目，只需要选择 Spring Web 一项


### 依赖 {#依赖}

添加 `graphql-java` 以及 `graphql-java-spring-boot-starter-webmvc` ，所有依赖如下：

```groovy
implementation 'com.graphql-java:graphql-java:16.2'  // 新
implementation 'com.graphql-java:graphql-java-spring-boot-starter-webmvc:2.0' // 新
implementation 'com.google.guava:guava:30.1.1-jre' // 新(可选)

implementation 'org.springframework.boot:spring-boot-starter-web'
testImplementation 'org.springframework.boot:spring-boot-starter-test'
```


### Schema {#schema}

新建文件 `src/main/resources/schema.graphqls`

```graphql
type Query{
    hello: String
}
```


### GraphQLProvider {#graphqlprovider}

需要提供 `GraphQL` bean 给 `graphql-java-spring-boot-starter-webmvc` 使用。

新建文件 `src/main/java/cn/notfound/GraphQLProvider.java`

```java
@Component
public class GraphQLProvider {
    private GraphQL graphQL;
    private GraphQLDataFetchers dataFetchers;

    @Autowired
    public GraphQLProvider(GraphQLDataFetchers dataFetchers) {
        this.dataFetchers = dataFetchers;
    }

    @PostConstruct
    public void init() throws IOException {
        URL url = Resources.getResource("schema.graphqls");
        String sdl = Resources.toString(url, Charsets.UTF_8);
        GraphQLSchema graphQLSchema = buildSchema(sdl);
        this.graphQL = GraphQL.newGraphQL(graphQLSchema).build();
    }

    private GraphQLSchema buildSchema(String sdl) {
        TypeDefinitionRegistry typeRegistry = new SchemaParser().parse(sdl);
        RuntimeWiring runtimeWiring = buildWiring();
        SchemaGenerator schemaGenerator = new SchemaGenerator();
        // 使用静态的 typeRegistry 和动态的 runtimeWiring 构建 GraphQLSchema
        return schemaGenerator.makeExecutableSchema(typeRegistry, runtimeWiring);
    }

    // 定义了动态获取数据的方式
    private RuntimeWiring buildWiring() {
        return RuntimeWiring.newRuntimeWiring()
            .type(TypeRuntimeWiring.newTypeWiring("Query")
                  .dataFetcher("hello", dataFetchers.hello()))
            .build();
    }

    @Bean
    public GraphQL graphQL() {
        return graphQL;
    }
}
```

-   `TypeDefinitionRegistry` GraphQL 类型静态定义
-   `RuntimeWiring` GraphQL 数据动态获取


### GraphQLDataFetchers {#graphqldatafetchers}

新建 `src/main/java/cn/notfound/GraphQLDataFetchers.java`

```java
@Component
public class GraphQLDataFetchers {
    public DataFetcher hello() {
        return environment -> "world";
    }
}
```


### 客户端 {#客户端}

使用 [graphql-playground](https://github.com/graphql/graphql-playground) 作为客户端：

```bash
# manjaro linux
yay -y graphql-playground-electron
```

打开客户端输入链接 `http://localhost:8080/graphql` 查询

```graphql
{
  hello
}
```

响应

```json
{
  "data": {
    "hello": "world"
  }
}
```


### 参考 {#参考}

-   <https://www.graphql-java.com/documentation/v16/getting-started/>
-   <https://www.graphql-java.com/tutorials/getting-started-with-spring-boot/>
