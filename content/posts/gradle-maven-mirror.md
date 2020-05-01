+++
title = "配置 gradle 和 maven 源"
author = ["notfound"]
date = 2019-05-03T13:05:00+08:00
tags = ["maven", "gradle"]
draft = false
+++

配置 gradle 和 maven 源，环境为 Ubuntu 18.04。

## 配置 gradle 源

编辑文件 `~/.gradle/init.gradle` :

```groovy
allprojects {
    def google_uri  = new URI('https://maven.aliyun.com/repository/google')
    def central_uri = new URI('https://maven.aliyun.com/repository/central')
    def jcenter_uri = new URI('https://maven.aliyun.com/repository/jcenter')

    repositories {
        all {
            ArtifactRepository repo ->
            if (repo instanceof MavenArtifactRepository) {
                def url = repo.url.toString()
                if (url.startsWith('https://repo.maven.apache.org/maven2/') || url.startsWith('https://repo1.maven.org/maven2')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by ${central_uri}."
                    repo.setUrl(central_uri)
                } else if (url.startsWith('https://jcenter.bintray.com/')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by ${jcenter_uri}."
                    repo.setUrl(jcenter_uri)
                } else if (url.startsWith('https://dl.google.com/dl/android/maven2')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by ${google_uri}."
                    repo.setUrl(google_uri)
                }
            }
        }
    }

    buildscript {
        repositories {
            maven { url 'https://maven.aliyun.com/repository/public/' }
            all { ArtifactRepository repo ->
                if (repo instanceof MavenArtifactRepository) {
                    def url = repo.url.toString()
                    if (url.startsWith('https://repo.maven.apache.org/maven2/') || url.startsWith('https://repo1.maven.org/maven2')) {
                        project.logger.lifecycle "Repository ${repo.url} replaced by ${central_uri}."
                        repo.setUrl(central_uri)
                    } else if (url.startsWith('https://jcenter.bintray.com/')) {
                        project.logger.lifecycle "Repository ${repo.url} replaced by ${jcenter_uri}."
                        repo.setUrl(jcenter_uri)
                    } else if (url.startsWith('https://dl.google.com/dl/android/maven2')) {
                        project.logger.lifecycle "Repository ${repo.url} replaced by ${google_uri}."
                        repo.setUrl(google_uri)
                    }
                }
            }
        }
    }
}
```

## 配置 maven 源

找到 Maven Home:

```shell
mvn -v
Apache Maven 3.6.0
Maven home: /usr/share/maven
```

复制配置:

```shell
cp /usr/share/maven/conf/settings.xml ~/.m2/
```

编辑 `~/.m2/settings.xml` 找到 `mirrors` 节点，在节点中间添加:

```xml
<mirror>
  <id>central-aliyun</id>
  <mirrorOf>central</mirrorOf>
  <name>Central aliyun</name>
  <url>http://maven.aliyun.com/repository/central</url>
</mirror>
<mirror>
  <id>jcenter-aliyun</id>
  <mirrorOf>jcenter</mirrorOf>
  <name>JCenter aliyun</name>
  <url>http://maven.aliyun.com/repository/jcenter</url>
</mirror>
<mirror>
  <id>google-aliyun</id>
  <mirrorOf>google</mirrorOf>
  <name>Google aliyun</name>
  <url>http://maven.aliyun.com/repository/google</url>
</mirror>
```
