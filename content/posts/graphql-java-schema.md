+++
title = "GraphQL Java 以及 Spring Boot: Schema"
author = ["likui"]
date = 2021-03-26T21:00:00+08:00
lastmod = 2021-03-27T09:43:26+08:00
tags = ["java", "graphql", "spring"]
categories = ["graphql"]
draft = false
+++

## GraphQL Java 以及 Spring Boot: Schema {#graphql-java-以及-spring-boot-schema}

-   OpenJDK 11
-   Gradle 6.8


### 依赖 {#依赖}

```groovy
implementation 'com.graphql-java:graphql-java:16.2' // 新
implementation 'com.graphql-java:graphql-java-spring-boot-starter-webmvc:2.0' // 新
implementation 'com.google.guava:guava:30.1.1-jre' // 新(可选)

implementation 'org.springframework.boot:spring-boot-starter-web'
testImplementation 'org.springframework.boot:spring-boot-starter-test'
```


### graphql dsl {#graphql-dsl}

创建 `src/main/resources/starWarsSchema.graphqls` :

```graphql
schema {
    query: Query
}

type Query {
    hero(episode: Episode) : Character
    human(id: String) : Human
    droid(id: ID!): Droid
}

enum Episode {
    NEWHOPE
    EMPIRE
    JEDI
}

interface Character {
    id: ID!
    name: String!
    friends: [Character]
    appearsIn: [Episode]!
}

type Human implements Character {
    id: ID!
    name: String!
    friends: [Character]
    appearsIn: [Episode]!
    homePlanet: String
}

type Droid implements Character {
    id: ID!
    name: String!
    friends: [Character]
    appearsIn: [Episode]!
    primaryFunction: String
}
```

-   其中包括了 `enum` 和 `interface`


### 与 graphQL dsl 对应的 Java 类型 {#与-graphql-dsl-对应的-java-类型}


#### enum Episode {#enum-episode}

```java
public enum Episode {
    NEWHOPE,
    EMPIRE,
    JEDI,
}
```


#### interface Character {#interface-character}

```java
public interface Character {
    String getId();
    String getName();
    List<String> getFriends();
    List<Episode> getAppearsIn();
}
```


#### type Human {#type-human}

```java
public class Human implements Character{
    private String id;
    private String name;
    private List<String> friends;
    private List<Episode> appearsIn;
    private String homePlanet;

    // 省略 construct 和 getter
}
```


#### type Droid {#type-droid}

```java
public class Droid implements Character {
    private String id;
    private String name;
    private List<String> friends;
    private List<Episode> appearsIn;
    private String primaryFunction;

    // 省略 construct 和 getter
}
```


### graphql dsl 与 java 类型建立联系 {#graphql-dsl-与-java-类型建立联系}


#### GraphQLProvider {#graphqlprovider}

```java
@Component
public class GraphQLProvider {
    private GraphQL graphQL;
    private StarWarsWiring starWarsWiring;

    @Autowired
    public GraphQLProvider(StarWarsWiring starWarsWiring) {
        this.starWarsWiring = starWarsWiring;
    }

    @PostConstruct
    public void init() throws IOException {
        URL url = Resources.getResource("starWarsSchemaAnnotated.graphqls");
        String sdl = Resources.toString(url, Charsets.UTF_8);
        GraphQLSchema graphQLSchema = buildSchema(sdl);

        this.graphQL = GraphQL.newGraphQL(graphQLSchema).build();
    }

    private GraphQLSchema buildSchema(String sdl) {
        TypeDefinitionRegistry typeRegistry = new SchemaParser().parse(sdl);
        RuntimeWiring runtimeWiring = buildWiring();
        SchemaGenerator schemaGenerator = new SchemaGenerator();
        // TypeRegistry 与 RuntimeWiring 共同构建 GraphQLSchema
        return schemaGenerator.makeExecutableSchema(typeRegistry, runtimeWiring);
    }

    private RuntimeWiring buildWiring() {
        return RuntimeWiring.newRuntimeWiring()
            .type(newTypeWiring("Query")
                  .dataFetcher("hero", starWarsWiring.heroDataFetcher)
                  .dataFetcher("human", starWarsWiring.humanDataFetcher)
                  .dataFetcher("droid", starWarsWiring.droidDataFetcher))
            .type(newTypeWiring("Human")
                  // 默认使用 PropertyDataFetcher，如 id, name。 JavaBean 会调用 getter 方法
                  // graphql-java 提供一些 Scalar，如 String, Int, Boolean 等，所以这些基本类型自动处理
                  .dataFetcher("friends", starWarsWiring.friendsDataFetcher))
            .type(newTypeWiring("Droid")
                  .dataFetcher("friends", starWarsWiring.friendsDataFetcher))
            // interface 类型，需要 TypeResolver 决定值的真实类型
            .type(newTypeWiring("Character")
                  .typeResolver(starWarsWiring.characterTypeResolver))
            // enum 类型
            .type(newTypeWiring("Episode")
                  .enumValues(starWarsWiring.episodeResolver))
            .build();
    }

    @Bean
    public GraphQL graphQL() {
        return graphQL;
    }
}
```

-   GraphQL `interface` 需要定义 `TypeResolver` ，用于运行时判断值的具体类型
-   GraphQL `enum` 需要 `EnumValuesProvider`


#### data fetcher {#data-fetcher}

```java
@Component
public class StarWarsWiring {
    DataFetcher<Human> humanDataFetcher = environment -> {
        // 获取用户参数
        String id = environment.getArgument("id");
        return StarWarsData.humanData.get(id);
    };

    DataFetcher<Droid> droidDataFetcher = environment -> {
        String id = environment.getArgument("id");
        return StarWarsData.droidData.get(id);
    };

    DataFetcher<Character> heroDataFetcher = environment -> {
        return StarWarsData.getCharacterData("1002");
    };

    DataFetcher<List<Character>> friendsDataFetcher = environment -> {
        // 获取父节点的值
        Character character = environment.getSource();
        List<String> friendIds = character.getFriends();
        return friendIds.stream()
        .map(StarWarsData::getCharacterData) // N+1
        .collect(Collectors.toList());
    };

    // enum
    EnumValuesProvider episodeResolver = Episode::valueOf;

    // interface
    TypeResolver characterTypeResolver = env -> {
        // 需要解析 GraphQL 类型的对象
        Character character = env.getObject();
        if (character instanceof Human) {
            return (GraphQLObjectType) env.getSchema().getType("Human");
        } else {
            return (GraphQLObjectType) env.getSchema().getType("Droid");
        }
    };
}
```

-   默认使用 `PropertyDataFetcher` ，基本类型的 data fetcher
-   `friendsDataFetcher` 存在 N+1 问题


#### data {#data}

```java
public class StarWarsData {
    static Human luke = new Human(
            "1000",
            "Luke Skywalker",
            asList("1001", "1002", "2000", "2001"),
            asList(Episode.NEWHOPE, Episode.EMPIRE, Episode.JEDI),
            "Tatooine"
    );

    static Human vader = new Human(
            "1001",
            "Darth Vader",
            asList("1000"),
            asList(Episode.NEWHOPE, Episode.EMPIRE, Episode.JEDI),
            "Tatooine"
    );

    static Human han = new Human(
            "1002",
            "Han Solo",
            asList("1000", "2001"),
            asList(Episode.NEWHOPE, Episode.EMPIRE, Episode.JEDI),
            null);


    public static Map<String, Human> humanData = new LinkedHashMap<>();

    static {
        humanData.put("1000", luke);
        humanData.put("1001", vader);
        humanData.put("1002", han);
    }

    static Droid threepio = new Droid(
            "2000",
            "C-3PO",
            asList("1000", "1002", "2001"),
            asList(Episode.NEWHOPE, Episode.EMPIRE, Episode.JEDI),
            "Protocol"
    );

    static Droid artoo = new Droid(
            "2001",
            "R2-D2",
            asList("1000", "1002"),
            asList(Episode.NEWHOPE, Episode.EMPIRE, Episode.JEDI),
            "Astromech"
    );

    public static Map<String, Droid> droidData = new LinkedHashMap<>();

    static {
        droidData.put("2000", threepio);
        droidData.put("2001", artoo);
    }

    public static Character getCharacterData(String id) {
        if (humanData.get(id) != null) {
            return humanData.get(id);
        } else if (droidData.get(id) != null) {
            return droidData.get(id);
        }
        return null;
    }
}
```


### 参考 {#参考}

-   源码来自 <https://github.com/graphql-java/graphql-java-examples> 有改动
-   <https://www.graphql-java.com/documentation/v16/schema/>
-   <https://www.graphql-java.com/documentation/v16/data-fetching/>
