+++
title = "SonarQube 环境搭建"
author = ["notfound"]
date = 2018-03-31T19:00:00+08:00
tags = ["sonar"]
draft = false
+++

系统环境: Ubuntu 16.04

## SonarQube 简介

[SonarQube](https://www.sonarqube.org/) 是一个开源平台，用于管理源代码的质量。SonarQube 不只是一个质量数据报告工具，更是代码质量管理平台。

## SonarQube 环境搭建


### 下载

SonarQube 官方下载页面 <https://www.sonarqube.org/downloads/> 下载当前最新版：

```shell
wget https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-7.0.zip
```

解压到当前文件夹，并重命名：

```shell
unzip sonarqube-7.0.zip
mv sonarqube-7.0 sonarqube
```

### 配置

SonarQube 的配置文件为 `conf/sonar.properties` ，可以直接使用默认配置启动，不需要进行任何更改。默认配置使用的内嵌的数据库保存数据。

SonarQube 支持内嵌数据库（默认）、MySQL、PostgreSQL 等数据库。

下面以 MySQL 为例：

```sql
CREATE DATABASE sonar DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE USER 'sonar' IDENTIFIED BY 'sonar';
GRANT ALL ON sonar.* TO 'sonar'@'%' IDENTIFIED BY 'sonar';
GRANT ALL ON sonar.* TO 'sonar'@'localhost' IDENTIFIED BY 'sonar';
FLUSH PRIVILEGES;
```

修改 sonar 配置文件 `conf/sonar.properties`，在配置文件中删除对应项的注释符号，并添加相应的值即可:

```conf
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance&useSSL=false
```

### 启动

```shell
./bin/linux-x86-64/sonar.sh start
./bin/linux-x86-64/sonar.sh status
./bin/linux-x86-64/sonar.sh stop
```

访问 <http://localhost:9000/> 可以看到 SonarQube 的页面。

### 参考

- <https://www.linuxidc.com/Linux/2017-05/143860.htm>
