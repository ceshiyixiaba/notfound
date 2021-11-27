---
title: "Servlet 中使用 Freemarker"
date: 2021-02-27T18:13:27+08:00
tags: ["java"]
---

## Servlet 使用 freemarker {#servlet-使用-freemarker}

-   OpenJDK 11
-   Gradle
-   Freemarker


### 依赖 {#依赖}

新建 `build.gradle` ：

```groovy
plugins {
    id 'war'
}

repositories {
    mavenCentral()
}

dependencies {
    compileOnly group: 'javax.servlet', name: 'javax.servlet-api', version: '4.0.1'
    implementation group: 'org.freemarker', name: 'freemarker', version: '2.3.31'
}
```


### 添加模板 {#添加模板}

添加 `src/main/webapp/template/hello.ftlh` ：

```ftlh
Hello, ${name}!
```

-   需要禁止直接访问 `.*ftlh` 文件，可在 `web.xml` 中配置。
-   新版本(2.3.24+)的 freemarker 文件后缀为 `.ftlh` ：

    > templates whose source name ends with ".ftlh" gets "HTML" output format, and those with ".ftlx" get "XML" output format.


### 方法一：servlet forward {#方法一-servlet-forward}

可通过 servlet forward 使用模板，设置 HttpServletRequest 对象属性后，视图的获取 forward 给 FreemarkerServlet。

1.  新建文件 `src/main/webapp/WEB-INF/web.xml` ：

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee" version="4.0">
        <servlet>
            <servlet-name>freemarker</servlet-name>
            <servlet-class>freemarker.ext.servlet.FreemarkerServlet</servlet-class>
            <init-param>
                <param-name>TemplatePath</param-name>
                <param-value>/template</param-value>
            </init-param>
        </servlet>

        <servlet-mapping>
            <servlet-name>freemarker</servlet-name>
            <url-pattern>*.ftlh</url-pattern>
        </servlet-mapping>

        <security-constraint>
            <web-resource-collection>
                <web-resource-name>FreeMarker MVC Views</web-resource-name>
                <url-pattern>*.ftlh</url-pattern>
            </web-resource-collection>
            <auth-constraint>
                <!-- 禁止 Web 直接访问 .ftlh -->
            </auth-constraint>
        </security-constraint>
    </web-app>
    ```
2.  新建文件 `src/main/java/example/HelloServlet.java` ：

    ```java
    package example;

    @WebServlet("/hello")
    public class HelloServlet extends HttpServlet {
        @Override
        protected void doGet(HttpServletRequest req, HttpServletResponse resp)
                throws ServletException, IOException {
            String name = req.getParameter("name");
            if (name == null) name = "Java";
            req.setAttribute("name", name);
            req.getRequestDispatcher("hello.ftlh").forward(req, resp);
        }
    }
    ```


### 方法二： 手动读取模板 {#方法二-手动读取模板}

可以手动读取模板并使用，和非 Servlet 环境类似。

新建 `src/main/java/example/HelloServlet2.java` ：

```java
package example;

@WebServlet("/hello2")
public class HelloServlet2 extends HttpServlet {
    private Configuration cfg;

    @Override
    public void init() throws ServletException {
        cfg = new Configuration(Configuration.VERSION_2_3_31);
        cfg.setServletContextForTemplateLoading(getServletContext(), "template");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = req.getParameter("name");
        if (name == null) name = "Java";
        HashMap<String, String> model = new HashMap<>();
        model.put("name", name);

        Template template = cfg.getTemplate("hello.ftlh");
        try {
            template.process(model, resp.getWriter());
        } catch (TemplateException e) {
            throw new ServletException(e);
        }
    }
}
```

-   模板根目录有多种设置方法，servlet 中可使用 `setServletContextForTemplateLoading` 。
-   需要注意线程安全问题， `getTemplate` 方法是线程安全的。


### 参考 {#参考}

-   [FreeMarker Servlet Tutorial with Example](https://www.viralpatel.net/freemarker-servlet-tutorial-example/)
-   [freemarker 结合Servlet使用](https://blog.csdn.net/acmman/article/details/79248718)
-   [Associating output formats with templates](https://freemarker.apache.org/docs/pgui%5Fconfig%5Foutputformatsautoesc.html)
-   [Using FreeMarker with servlets](https://freemarker.apache.org/docs/pgui%5Fmisc%5Fservlet.html)
-   [Multithreading](https://freemarker.apache.org/docs/pgui%5Fmisc%5Fmultithreading.html)
-   [FreeMarker 简介](http://www.freemarker.net/)
