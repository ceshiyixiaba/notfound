+++
title = "JGit HTTP Server 使用"
author = ["likui"]
date = 2021-02-21T18:11:00+08:00
lastmod = 2021-02-21T22:29:29+08:00
tags = ["jgit"]
draft = false
+++

-   Gradle
-   Tomcat
-   JGit


## JGit HTTP Server 使用 {#jgit-http-server-使用}

使用 JGit 实现 git HTTP server。


### 实现 {#实现}


#### 依赖 {#依赖}

新建文件 `build.gradle` ：

```groovy
plugins {
    id 'war'
}

repositories {
    mavenCentral()
}

dependencies {
    compileOnly group: 'javax.servlet', name: 'javax.servlet-api', version: '4.0.1'
    implementation group: 'org.eclipse.jgit', name: 'org.eclipse.jgit.http.server', version: '5.10.0.202012080955-r'
}
```


#### 配置 {#配置}

新建文件 `src/main/webapp/WEB-INF/web.xml` ：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
                             http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
         version="4.0"
         metadata-complete="true">
  <display-name>JGit HTTP Server</display-name>
  <description>Welcome to JGit HTTP Server</description>

  <servlet>
    <servlet-name>GitServlet</servlet-name>
    <servlet-class>org.eclipse.jgit.http.server.GitServlet</servlet-class>
    <init-param>
      <param-name>base-path</param-name>
      <param-value>/srv/git-data</param-value>
    </init-param>
    <init-param>
      <param-name>export-all</param-name>
      <param-value>0</param-value>
    </init-param>
  </servlet>
  <servlet-mapping>
    <servlet-name>GitServlet</servlet-name>
    <url-pattern>/git/*</url-pattern>
  </servlet-mapping>
</web-app>
```

-   `base-path` 仓库根目录。
-   `export-all` 是否可导出


#### 仓库 {#仓库}

1.  创建仓库目录：

    ```shell
    mkdir -p /srv/git-data
    cd /srv/git-data
    git init --bare exampl.git
    ```
2.  设置仓库为可导出，不需要鉴权：

    ```shell
    touch example.git/git-daemon-export-ok
    ```
3.  可以拉取，但无法推送：

    ```shell
    git clone http://localhost:8080/xxx/git/example.git
    ```


### 工作过程 {#工作过程}


#### upload-pack 过程 {#upload-pack-过程}

{{< figure src="/ox-hugo/jgit-http-server-filter.svg" >}}


#### receive-pack 过程 {#receive-pack-过程}

与 upload-pack 相似，将其中关键字 `UploadPack` 替换为 `ReceivePack` 。


### 自定义访问控制 {#自定义访问控制}


#### 实现 RepositoryResolver 接口 {#实现-repositoryresolver-接口}

1.  参照 `FileResolver` 实现 `RepositoryResolver` ，默认实现查看 web.xml `export-all` 配置或者 .git 仓库目录下是否存在 `git-daemon-export-ok` 文件；
2.  继承 `GitServlet` 并通过 `setRepositoryResolver` 替换掉 `resolver` ；
3.  需要自定义 `Filter` 修改 `HttpServletResponse` ，在需要认证时 JGit 返回 401，但未添加 `WWW-Authenticate` 头部，导致输入密码也无效。

可控制仓库的访问，但无法直接区读、写操作。


#### 实现 UploadPackFactory 接口 {#实现-uploadpackfactory-接口}

1.  参考 `DefaultUploadPackFactory` 实现 `UploadPackFactory` 接口，默认可拉取；
2.  继承 `GitServlet` 并通过 `setUploadPackFactory` 替换掉 `uploadPackFactory` ；

可对仓库进行读权限控制。


#### 实现 ReceivePackFactory 接口 {#实现-receivepackfactory-接口}

1.  参考 `DefaultReceivePackFactory` 实现 `ReceivePackFactory` 接口，默认不可推送；
2.  继承 `GitServlet` 并通过 `setReceivePackFactory` 替换掉 `receivePackFactory` 。

可对仓库进行写权限控制。


### 参考 {#参考}

-   [Class GitServlet](https://download.eclipse.org/jgit/site/5.10.0.202012080955-r/apidocs/index.html)
