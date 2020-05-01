+++
title = "Java Mail 发送邮件"
author = ["likui"]
date = 2021-02-24
lastmod = 2021-02-24T22:15:26+08:00
tags = ["java"]
draft = false
+++

## Java Mail 发送邮件 {#java-mail-发送邮件}

-   OpenJDK 11
-   Tomcat9
-   Gradle

使用本地测试邮件服务器 [mailcatcher](https://mailcatcher.me/)


### 依赖 {#依赖}

新建文件 `build.gradle`

```groovy
plugins {
    id 'war'
}

repositories {
    mavenCentral()
}

dependencies {
    compileOnly group: 'javax.servlet', name: 'javax.servlet-api', version: '4.0.1'
    implementation group: 'javax.mail', name: 'javax.mail-api', version: '1.6.2'
    implementation group: 'com.sun.mail', name: 'javax.mail', version: '1.6.2'
    implementation group: 'javax.activation', name: 'javax.activation-api', version: '1.2.0'
    implementation group: 'com.sun.activation', name: 'javax.activation', version: '1.2.0'
}
```


### Servlet {#servlet}

新建文件 `src/main/java/MailServlet.java`

```java
@MultipartConfig
@WebServlet(
        urlPatterns = {"/mail.do"},
        initParams = {
                @WebInitParam(name = "mailHost", value = "127.0.0.1"),
                @WebInitParam(name = "mailPort", value = "1025")
        }
)
public class MailServlet2 extends HttpServlet {
    private Properties props;

    @Override
    public void init() throws ServletException {
        String mailHost = getServletConfig().getInitParameter("mailHost");
        String mailPort = getServletConfig().getInitParameter("mailPort");

        props = new Properties();
        props.put("mail.smtp.host", mailHost);
        props.setProperty("mail.smtp.port", mailPort);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding(StandardCharsets.UTF_8.name());
        resp.setContentType("text/html;charset=UTF-8");

        String from = req.getParameter("from");
        String to = req.getParameter("to");
        String subject = req.getParameter("subject");
        String text = req.getParameter("text");
        Part part = req.getPart("file");

        try {
            Message message = getMessage(from, to, subject, text, part);
            Transport.send(message);
            resp.getWriter().println("邮件发送成功");
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }

    private Message getMessage(String from, String to, String subject, String text, Part part)
            throws MessagingException, IOException {
        Session session = Session.getDefaultInstance(props);

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(from));
        message.setRecipient(Message.RecipientType.TO, new InternetAddress(to));
        message.setSubject(subject);
        message.setSentDate(new Date());

        Multipart multipart = new MimeMultipart();

        MimeBodyPart htmlPart = new MimeBodyPart();
        htmlPart.setContent(text, "text/html;charset=UTF-8");
        multipart.addBodyPart(htmlPart);

        String filename = getFilename(part);
        if (!"".equals(filename)) {
            ByteArrayDataSource ds = new ByteArrayDataSource(part.getInputStream(), part.getContentType());
            MimeBodyPart filePart = new MimeBodyPart();
            filePart.setDataHandler(new DataHandler(ds));
            filePart.setFileName(MimeUtility.encodeText(filename, "UTF-8", "B"));
            multipart.addBodyPart(filePart);
        }

        message.setContent(multipart);

        return message;
    }

    private String getFilename(Part part) {
        String header = part.getHeader("Content-Disposition");
        String filename = header.substring(header.indexOf("filename=\"") + 10,
                header.lastIndexOf("\""));
        return filename;
    }
}
```


### 表单 {#表单}

```html
<form action="mail.do" method="post" enctype="multipart/form-data">
  <input type="submit" value="发送" name="send"><br>
  发信人：<input type="text" name="from" value=""><br>
  收信人：<input type="text" name="to" value=""><br>
  主  题：<input type="text" name="subject" value=""><br>
  附  件：<input type="file" name="file" value=""><br>
  <textarea name="text"></textarea>
</form>
```


### 参考 {#参考}

-   [JavaMail API - Sending Emails](https://www.tutorialspoint.com/javamail%5Fapi/javamail%5Fapi%5Fsend%5Finlineimage%5Fin%5Femail.htm)
-   《JSP & Servlet 学习笔记(第2版)》
