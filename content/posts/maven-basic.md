---
title: "Maven 基本使用"
date: 2020-05-19T21:08:56+08:00
tags: ["maven", "java"]
draft: false
---

- Apache Maven 3.6.3

## 生成 maven 工程

```shell
mvn archetype:generate \
  -DarchetypeGroupId=org.apache.maven.archetypes \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DarchetypeVersion=1.4 \
  -DarchetypeCatalog=internal \
  -DgroupId=com.example \
  -DartifactId=demo \
  -Dversion=0.0.1-SNAPSHOT \
  -Dpackage=com.example.demo
```

`pom.xml` 修改编译目标版本：

```xml
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.source>1.8</maven.compiler.source>
    <maven.compiler.target>1.8</maven.compiler.target>
  </properties>
```

## 编译、测试、打包等

```shell
# 移除 target 目录
mvn clean
# 编译
mvn compile
# 测试
mvn test
# 打包
mvn package
# 安装
mvn install
```

## 可执行 jar

默认情况 jar 找不到 Main 方法：

```text
$ java -jar target/demo-0.0.1-SNAPSHOT.jar
target/demo-0.0.1-SNAPSHOT.jar中没有主清单属性
```

### 运行时指定入口

```text
java -cp target/demo-0.0.1-SNAPSHOT.jar com.example.demo.App
```

### maven-shade-plugin

在 `pom.xml` 中添加：

```xml
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-shade-plugin</artifactId>
        <version>3.2.3</version>
        <executions>
          <execution>
            <phase>package</phase>
            <goals>
              <goal>shade</goal>
            </goals>
            <configuration>
              <transformers>
                <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                  <mainClass>com.example.demo.App</mainClass>
                </transformer>
              </transformers>
            </configuration>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
```

## 发布

TODO

## 参考

- [Maven Quickstart Archetype](http://maven.apache.org/archetypes/maven-archetype-quickstart/)
- [Executable JAR](http://maven.apache.org/plugins/maven-shade-plugin/examples/executable-jar.html)
