+++
title = "GraphQL Java 以及 Spring Boot: Batching"
author = ["likui"]
date = 2021-03-27T09:40:00+08:00
lastmod = 2021-03-27T09:41:57+08:00
tags = ["java", "graphql", "spring"]
categories = ["graphql"]
draft = false
+++

## GraphQL Java 以及 Spring Boot: Batching {#graphql-java-以及-spring-boot-batching}

-   OpenJDK 11
-   Gradle 6.8

通过 `java-dataloader` 处理 N+1 问题。


### 依赖 {#依赖}

```groovy
implementation 'com.graphql-java:graphql-java:16.2'  // 新
implementation 'com.graphql-java:graphql-java-spring-boot-starter-webmvc:2.0' // 新
implementation 'com.google.guava:guava:30.1.1-jre' // 新(可选)

implementation 'org.springframework.boot:spring-boot-starter-web'
testImplementation 'org.springframework.boot:spring-boot-starter-test'
```

-   `graphql-java` 中已将添加 `java-dataloader` 依赖，不需要额外添加。


### 源码 {#源码}

```java
@Component
public class StarWarsWiring {
    private final DataLoaderRegistry dataLoaderRegistry;

    public StarWarsWiring() {
        this.dataLoaderRegistry = new DataLoaderRegistry();
        dataLoaderRegistry.register("characters", newCharacterDataLoader());
    }

    //提供 DataLoaderRegistry 给 graphql-java-spring-webmvc 使用
    @Bean
    public DataLoaderRegistry dataLoaderRegistry() {
        // DataLoaderRegistry 是全局的，在它之上注册的 DataLoader 也是全局的
        // 所有请求都会共用相同的缓存
        return dataLoaderRegistry;
    }

    private DataLoader<String,Character> newCharacterDataLoader() {
        return new DataLoader<>(characterBatchLoader);
    }

    private BatchLoader<String, Character> characterBatchLoader = keys -> {
        // BatchLoader 中存在缓存，多次请求相同数据时也会使用缓存
        return CompletableFuture.supplyAsync(() -> getCharacterDataViaBatchHTTPApi(keys));
    };

    // 数据批量加载
    private List<Character> getCharacterDataViaBatchHTTPApi(List<String> keys) {
        return keys.stream().map(StarWarsData::getCharacterData).collect(Collectors.toList());
    }

    DataFetcher<CompletableFuture<Character>> humanDataFetcher = environment -> {
        // 获取 DataLoader
        DataLoader<String, Character> dataLoader =  environment.getDataLoader("characters");
        String id = environment.getArgument("id");
        // 从 DataLoader 获取单条数据，数据不会立刻加载
        return dataLoader.load(id);
    };

    DataFetcher<CompletableFuture<Character>> droidDataFetcher = environment -> {
        DataLoader<String, Character> dataLoader =  environment.getDataLoader("characters");
        String id = environment.getArgument("id");
        return dataLoader.load(id);
    };

    DataFetcher<CompletableFuture<Character>> heroDataFetcher = environment -> {
        DataLoader<String, Character> dataLoader =  environment.getDataLoader("characters");
        return dataLoader.load("1002");
    };

    DataFetcher<CompletableFuture<List<Character>>> friendsDataFetcher = environment -> {
        DataLoader<String, Character> dataLoader =  environment.getDataLoader("characters");
        Character character = environment.getSource();
        // 从 DataLoader 获取多条数据，不会立刻加载
        return dataLoader.loadMany(character.getFriends());
    };

    // 省略部分代码
}
```

-   需要提供 `DataLoaderRegistry` bean 给 graphql-java-spring-webmvc 使用
-   DataLoader 中的数据会延迟加载并且存在缓存，可以处理 N+1
-   当前 DataLoaderRegistry 和 DataLoader 是全局的，因此不同请求会使用相同缓存


### 参考 {#参考}

-   源码来自 <https://github.com/graphql-java/graphql-java-examples> 有改动
-   <https://www.graphql-java.com/documentation/v16/batching/>
