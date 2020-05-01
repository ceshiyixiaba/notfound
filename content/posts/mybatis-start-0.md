---
title: "Mybatis Start 0"
date: 2020-05-27T19:56:53+08:00
tags: ["java"]
categories: ["mybatis"]
draft: true
---

## 配置

```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <version>42.2.12</version>
</dependency>

<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>3.5.4</version>
</dependency>
```

- maven
- PostgreSQL

1. 添加依赖
1. 数据库连接与配置
1. 单表操作：增、删、改、查
1. 关联
    1. 一对一：增、删、改、查
    1. 一对多、多对一：增、删、改、查
    1. 多对对：增、删、改、查
    1. 懒加载
    1. 急加载
    1. join
1. 类型映射
1. 单表继承
1. 事务
1. 缓存
    1. 一级缓存 
    2. 二级缓存


- java 时间

https://github.com/mybatis/typehandlers-jsr310

`Instant` 与 `Timestamp`

- 邮件

https://javaee.github.io/javamail/docs/api/com/sun/mail/smtp/package-summary.html

## 参考
