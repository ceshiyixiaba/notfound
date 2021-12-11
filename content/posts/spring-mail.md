---
title: "Spring Mail"
date: 2021-12-10T08:50:07+08:00
tags: ["spring", "java"]
---

## 依赖

```gradle
implementation 'org.springframework.boot:spring-boot-starter-freemarker'
implementation 'org.springframework.boot:spring-boot-starter-mail'
```

## 配置

```yml
spring:
  mail:
    host: 127.0.0.1
    port: 1025
    protocol: smtp
```

## 代码

### 纯文本

`SimpleMailMessage` 用来发送纯文本：

```java
@Autowired
private MailSender mailSender;

public void send() {
    SimpleMailMessage msg = new SimpleMailMessage();
    msg.setSubject("simple");
    msg.setFrom("noreply@notfound.cn");
    msg.setTo("test@notfound.cn");
    msg.setText("<h1>Hello Spring Mail!</h1>");
    
    try {
        mailSender.send(msg);
    } catch (MailException e) {
        System.err.println(e.getMessage());
    }
}
```
- `mailSender` 为 `JavaMailSenderImpl` 类型,该对象初始化时会从文件中读取邮件服务器相关信息
- 只能发送纯文本信息，html 标签并不会被解析

### HTML

通过 `JavaMailSender` 创建 MimeMessage 对象，之后可以添加 html 标签：

```java
@Autowired
private JavaMailSender mailSender;

public void send() throws MessagingException {
    MimeMessage message = mailSender.createMimeMessage();
    message.setSubject("java mail sender");
    message.setFrom("noreply@notfound.cn");
    message.setRecipient(Message.RecipientType.TO, new InternetAddress("test@notfound.cn"));
    message.setText("<h1>Hello Spring Mail</h1>", StandardCharsets.UTF_8.name(), "html");

    mailSender.send(message);
}
```

### 附件

通过 `MimeMessageHelper` 可以简化操作 mime message 操作流程：

```java
@Autowired
private JavaMailSender mailSender;

public void send() throws MessagingException {
    MimeMessage message = mailSender.createMimeMessage();

    MimeMessageHelper helper = new MimeMessageHelper(message, true);
    helper.setSubject("helper");
    helper.setFrom("noreply@notfound.cn");
    helper.setTo("test@notfound.cn");

    // 附件
    helper.addAttachment("test.png", new ClassPathResource("test.png"));

    // HTML + 图片
    helper.setText("<html><body><h1>Hello Spring Mail</h1><img src='cid:identifier1234'/></body><html>", true);
    helper.addInline("identifier1234", new ClassPathResource("test.png"));

    mailSender.send(message);
}
```

### 使用 freemarker

使用 Freemarker 处理邮件模板：

```java
@Autowired
private JavaMailSender mailSender;
@Autowired
private Configuration configuration;

public void send() throws MessagingException, IOException, TemplateException {
    String to = "test@example.com";

    Map<String, Object> model = new HashMap<>();
    model.put("email", to);

    StringWriter stringWriter = new StringWriter();
    configuration.getTemplate("email.ftlh").process(model, stringWriter);

    MimeMessage message = mailSender.createMimeMessage();

    MimeMessageHelper helper = new MimeMessageHelper(message, true);
    helper.setSubject("helper");
    helper.setFrom("noreply@notfound.cn");
    helper.setTo(to);
    helper.setText(stringWriter.getBuffer().toString(), true);
    helper.addInline("identifier1234", new ClassPathResource("test.png"));

    mailSender.send(message);
}
```

模板 `email.ftlh` 内容：

```html
<html>
<head>
    <title>Welcome!</title>
</head>
<body>
<h1>Welcome ${email}!</h1>
<img src="cid:identifier1234" />
</body>
</html>
```

## 参考

- https://docs.spring.io/spring-framework/docs/5.3.13/reference/html/integration.html#mail
- https://springhow.com/spring-boot-email-freemarker/
