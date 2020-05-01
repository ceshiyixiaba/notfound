+++
title = "ActiveMQ Artemis 安装和使用"
author = ["likui"]
date = 2021-03-03
lastmod = 2021-03-03T20:35:23+08:00
tags = ["java"]
draft = false
+++

## ActiveMQ Artemis 安装和使用 {#activemq-artemis-安装和使用}


### 安装 {#安装}

```shell
wget https://mirrors.tuna.tsinghua.edu.cn/apache/activemq/activemq-artemis/2.17.0/apache-artemis-2.17.0-bin.tar.gz
tar -zxvf apache-artemis-2.17.0-bin.tar.gz
sudo mv apache-artemis-2.17.0 /opt/artemis
sudo chown -R root:root /opt/artemis
export ARTEMIS_HOME=/opt/artemis
```


### 命令 {#命令}

启动、停止等命令：

```shell
# 创建 broker 实例
$ARTEMIS_HOME/bin/artemis create /srv/example
# 启动服务
/srv/example/bin/artemis run
# 启动服务，后台运行
/srv/example/bin/artemis-service start
# 查看服务状态
/srv/example/bin/artemis-service status
# 停止服务
/srv/example/bin/artemis-service stop
```

服务启动后，可进入页面管理 <http://localhost:8161/console>


### 基本使用 {#基本使用}

添加依赖

```groovy
implementation group: 'org.apache.activemq', name: 'artemis-jms-client-all', version: '2.17.0'
```


#### 生产者 {#生产者}

```java
Connection connection = null;
try {
    ConnectionFactory cf = new ActiveMQConnectionFactory("tcp://localhost:61616");
    // 创建 JMS 连接
    connection = cf.createConnection();
    // 创建 JMS Session
    Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
    Queue queue = session.createQueue("exampleQueue");
    // 创建 producer
    MessageProducer producer = session.createProducer(queue);
    // 创建 message
    TextMessage message = session.createTextMessage("Hello ActiveMQ!");
    // 发送消息
    producer.send(message);
} finally {
    if (connection != null) {
        connection.close();
    }
}
```


#### 消费者 {#消费者}

```java
Connection connection = null;
ConnectionFactory cf = new ActiveMQConnectionFactory("tcp://localhost:61616");
try {
    // 创建 JMS 连接
    connection = cf.createConnection();
    connection.start();
    // 创建 JMS Session
    Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
    Queue queue = session.createQueue("exampleQueue");
    // 创建 consumer
    MessageConsumer consumer = session.createConsumer(queue);
    // 接受 message
    TextMessage message = (TextMessage) consumer.receive(5000);
    System.out.println(message.getText());
} finally {
    if (connection != null) {
        connection.close();
    }
}
```


### 参考 {#参考}

-   [Using the Server](https://activemq.apache.org/components/artemis/documentation/latest/using-server.html)
-   [AMQP Broker Connection with Receivers](https://github.com/apache/activemq-artemis/tree/2.17.0/examples/features/broker-connection/amqp-receiving-messages)
-   [JMS Queue Example](https://github.com/apache/activemq-artemis/tree/2.17.0/examples/features/standard/queue)
-   [深入了解 ActiveMQ Artemis 和 Qpid 以在企业中应用](https://developer.ibm.com/zh/depmodels/cloud/articles/cl-lo-activemq-artemis-and-qpid-to-apply-in-the-enterprise/)
