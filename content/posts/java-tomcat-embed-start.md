+++
title = "Tomcat embed 使用"
author = ["likui"]
date = 2021-02-16T17:41:00+08:00
lastmod = 2021-02-16T17:48:30+08:00
draft = false
+++

## Tomcat embed 使用 {#tomcat-embed-使用}

-   gradle
-   tomcat9

仅为了方便 IDEA 调试，用于开发环境


### 修改 `build.gradle` {#修改-build-dot-gradle}

```groovy
plugins {
    id 'war'
}

repositories {
    mavenCentral()
}

dependencies {
    providedCompile group: 'org.apache.tomcat.embed', name: 'tomcat-embed-core', version: '9.0.43'
    providedCompile group: 'org.apache.tomcat.embed', name: 'tomcat-embed-jasper', version: '9.0.43'
    providedCompile group: 'javax.servlet', name: 'javax.servlet-api', version: '4.0.1'
}

war {
    rootSpec.exclude('example/Main.class')
}
```


### 添加 `src/main/java/example/HelloServlet.java` {#添加-src-main-java-example-helloservlet-dot-java}

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
        out.write("Hello World");
        out.close();
    }
}
```


### 添加 `src/main/java/example/Main.java` {#添加-src-main-java-example-main-dot-java}

```java
package example;

import org.apache.catalina.Context;
import org.apache.catalina.LifecycleException;
import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;

import java.io.File;

public class Main {
    public static void main(String[] args) {
        Tomcat tomcat = new Tomcat();
        tomcat.setPort(8081);
        tomcat.getConnector();

        String webappBase = new File("src/main/webapp/").getAbsolutePath();
        Context context = tomcat.addWebapp("/", webappBase);
        String classesBase = new File("build/classes/java/main/").getAbsolutePath();
        WebResourceRoot resources = new StandardRoot(context);
        resources.addPreResources(new DirResourceSet(resources,
                                                     "/WEB-INF/classes", classesBase, "/"));
        context.setResources(resources);

        try {
            tomcat.start();
        } catch (LifecycleException e) {
            e.printStackTrace();
        }

        tomcat.getServer().await();
    }
}
```

-   主要是构建一个 war 类似的目录结构。可先编译成 war 包，再根据 war 目录结构调整代码


### 参考 {#参考}

-   [Create a Java Web Application Using Embedded Tomcat](https://devcenter.heroku.com/articles/create-a-java-web-application-using-embedded-tomcat)
