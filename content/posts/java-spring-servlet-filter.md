+++
title = "Spring Boot 添加 servlet 以及 filter"
author = ["likui"]
date = 2021-04-14T19:50:00+08:00
lastmod = 2021-04-14T19:54:15+08:00
tags = ["spring", "servlet"]
draft = false
+++

## Spring Boot 添加 servlet 以及 filter {#spring-boot-添加-servlet-以及-filter}

-   OpenJDK 11
-   Gradle 6.8


### 依赖 {#依赖}

```groovy
implementation 'org.springframework.boot:spring-boot-starter-web'
```


### servlet {#servlet}


#### ServletWrappingController {#servletwrappingcontroller}

```java
@Bean
public ServletWrappingController wrappingController() {
    ServletWrappingController controller = new ServletWrappingController();
    controller.setServletClass(WrappingServlet.class);
    controller.setServletName("wrapping-servlet");
    return controller;
}

@Bean
public SimpleUrlHandlerMapping urlHandlerMapping() {
    SimpleUrlHandlerMapping mapping = new SimpleUrlHandlerMapping();
    mapping.setUrlMap(Map.of("/wrapping/*", "wrappingController"));
    mapping.setOrder(Ordered.LOWEST_PRECEDENCE  - 2);
    return mapping;
}
```

-   `req.getPathInfo()` 为 `null`


#### ServletRegistrationBean {#servletregistrationbean}

```java
@Bean
public ServletRegistrationBean<HelloServlet> helloServletServletRegistrationBean() {
    ServletRegistrationBean<HelloServlet> registration = new ServletRegistrationBean<>();
    registration.setServlet(new HelloServlet());
    registration.setUrlMappings(List.of("/hello/*"));
    return registration;
}
```

-   `req.getPathInfo()` 为 `*` 的内容


### filter {#filter}

```java
@Bean
public FilterRegistrationBean<HelloFilter> helloFilterFilterRegistrationBean() {
    FilterRegistrationBean<HelloFilter> registration = new FilterRegistrationBean<>();
    registration.setFilter(new HelloFilter());
    return registration;
}
```


### 参考 {#参考}

-   <https://stackoverflow.com/questions/55248304/how-to-declare-servlet-on-root-path-without-overriding-spring-mvc-controllers>
