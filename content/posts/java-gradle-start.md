+++
title = "Gradle 入门"
author = ["likui"]
date = 2021-02-16T15:11:00+08:00
lastmod = 2021-03-13T17:04:47+08:00
tags = ["gradle", "java"]
draft = false
+++

## Gradle 入门 {#gradle-入门}

-   Gradle 6.8


### 初始化项目 {#初始化项目}

`gradle init` 可初始化项目：

```shell
gradle init --type=basic --dsl=groovy --project-name=example
```

生成的目录结构如下：

```shell
.
├── build.gradle
├── .gitattributes
├── .gitignore
├── .gradle
├── gradle/wrapper/
├── gradlew
├── gradlew.bat
└── settings.gradle
```


### 包含 Main 方法的 jar {#包含-main-方法的-jar}

1.  新建文件 `src/main/java/example/Main.java`

    ```java
    package example;

    public class Main {
        public static void main(String[] args) {
            System.out.println("Hello World!");
        }
    }
    ```
2.  修改 `build.gradle` ，把所有依赖一起打包：

    ```groovy
    plugins {
        id 'java'
    }

    jar {
        manifest {
            attributes "Main-Class": "example.Main"
        }
        from {
            configurations.compile.collect { it.isDirectory() ? it : zipTree(it) }
            configurations.runtimeClasspath.collect { it.isDirectory() ? it : zipTree(it) }
        }
    }
    ```
3.  编译、执行

    ```bash
    gradle build
    java -jar build/libs/example.jar
    ```


### War Plugin {#war-plugin}

1.  新建文件 `src/main/java/example/HelloServlet.java`

    ```java
    package example;

    import javax.servlet.ServletException;
    import javax.servlet.annotation.WebServlet;
    import javax.servlet.http.HttpServlet;
    import javax.servlet.http.HttpServletRequest;
    import javax.servlet.http.HttpServletResponse;
    import java.io.IOException;
    import java.io.PrintWriter;

    @WebServlet("/hello")
    public class HelloServlet extends HttpServlet {
        @Override
        protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
            PrintWriter out = resp.getWriter();
            out.write("Hello World!");
            out.close();
        }
    }
    ```
2.  修改 `build.gradle`

    ```groovy
    plugins {
        id 'war'
    }

    repositories {
        mavenCentral()
    }

    dependencies {
        compileOnly group: 'javax.servlet', name: 'javax.servlet-api', version: '4.0.1'
    }
    ```
3.  编译、部署

    ```shell
    gradle build
    cp build/libs/example.war $CATALINA_HOME/webapps
    ```

    访问 <http://localhost:8080/example/hello> 即可


### Application Plugin {#application-plugin}

Application Plugin 能创建一个可分发的 ZIP 文件，其中包含了依赖以及启动脚本。

1.  初始化

    ```bash
    gradle init \
           --dsl=groovy \
           --package=app \
           --project-name=app  \
           --test-framework=junit-jupiter \
           --type=java-application
    ```
2.  打包成 zip

    ```bash
    gradle distZip
    ```
3.  解压，运行

    ```bash
    unzip app/build/distributions/app.zip -d /tmp/app
    /tmp/app/bin/app
    ```


### 添加测试 {#添加测试}

1.  新建 `src/main/java/example/Hello.java`

    ```java
    package example;

    public class Hello {
        public String getGreeting() {
            return "Hello World!";
        }
    }
    ```
2.  新建 `src/test/java/example/HelloTest.java`

    ```java
    package example;

    import org.junit.jupiter.api.Test;

    import static org.junit.jupiter.api.Assertions.*;

    class HelloTest {

        @Test
        void getGreeting() {
            assertEquals(new Hello().getGreeting(), "Hello World?");
        }
    }
    ```
3.  修改 `build.gradle`

    ```groovy
    plugins {
        id 'java'
    }

    repositories {
        mavenCentral()
    }

    dependencies {
        testImplementation group: 'org.junit.jupiter', name: 'junit-jupiter-api', version: '5.7.1'
        testImplementation group: 'org.junit.jupiter', name: 'junit-jupiter-engine', version: '5.7.1'
    }

    test {
        useJUnitPlatform()
    }

    ```
4.  测试

    ```shell
    gradle test
    gradle test --info
    ```


### 参考 {#参考}

-   [Build Init Plugin](https://docs.gradle.org/current/userguide/build%5Finit%5Fplugin.html)
-   [The War Plugin](https://docs.gradle.org/current/userguide/war%5Fplugin.html)
-   [The Java Plugin](https://docs.gradle.org/current/userguide/java%5Fplugin.html)
-   [The Application Plugin](https://docs.gradle.org/current/userguide/application%5Fplugin.html)
-   [Creating a Fat Jar in Gradle](https://www.baeldung.com/gradle-fat-jar)
-   [Using JUnit 5](https://docs.gradle.org/current/userguide/java%5Ftesting.html#using%5Fjunit5)
-   [How do I create an executable fat jar with Gradle with implementation dependencies](https://stackoverflow.com/questions/49278063/how-do-i-create-an-executable-fat-jar-with-gradle-with-implementation-dependenci)
