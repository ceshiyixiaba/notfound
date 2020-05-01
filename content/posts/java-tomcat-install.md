+++
title = "Linux 安装配置 Tomcat 9"
author = ["likui"]
date = 2021-02-16T15:22:00+08:00
lastmod = 2021-03-07T14:10:32+08:00
tags = ["tomcat", "java"]
draft = false
+++

## Linux 安装配置 Tomcat 9 {#linux-安装配置-tomcat-9}


### Manjaro Linux {#manjaro-linux}


#### 安装 tomcat9 tomcat-native {#安装-tomcat9-tomcat-native}

执行 pacman 直接安装：

```shell
sudo pacman -S tomcat9 tomcat-native
```


#### 通过 systemd 控制 Tomcat {#通过-systemd-控制-tomcat}

systemctl 可启动、重启、停止、查看日志：

```shell
# 启动 tomcat9
sudo systemctl start tomcat9.service
# 停止 tomcat9
sudo systemctl stop tomcat9.service
# 重启 tomcat9
sudo systemctl restart tomcat9.service
# 开机启动 tomcat9
sudo systemctl enable tomcat9.service
# 查看 tomcat9 启动状态
systemctl status tomcat9.service
# 查看日志
journalctl -f --unit=tomcat9.service
```

访问 <http://localhost:8080/>


#### 查看环境变量 {#查看环境变量}

`export` 环境变量，方便操作：

```shell
# 查看环境变量
systemctl show tomcat9.service | grep Environment
export CATALINA_HOME=/usr/share/tomcat9
```


#### 页面查看 Tomcat 运行状态 {#页面查看-tomcat-运行状态}

修改 `$CATALINA_HOME/conf/tomcat-users.xml` ，在 `tomcat-users` 标签之间添加：

```xml
<user username="tomcat" password="YOUR_PASSWORD" roles="manager-gui"/>
```

访问 <http://localhost:8080/manager/status> ，输入用户名和密码后，可查看 Tomcat 状态。


#### War 部署 {#war-部署}

1.  将 war 放置到 `$CATALINA_HOME/webapps/` ，文件会自动解压，访问路径会有文件名前缀。如 `app.war` 访问 URL 为 <http://localhost:8080/app>
2.  `ROOT.war` ，URL 路径会从根开始，不带任何前缀


#### 绑定新端口 8081 {#绑定新端口-8081}

1.  编辑 `$CATALINA_HOME/conf/server.xml`

    ```xml
    <Service name="App">
      <Connector port="8081" protocol="HTTP/1.1"
                 connectionTimeout="20000"
                 redirectPort="8443" />
      <Engine name="App" defaultHost="localhost">
        <Host name="localhost"  appBase="app" unpackWARs="true" autoDeploy="true">

          <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
                 prefix="app_access_log" suffix=".txt"
                 pattern="%h %l %u %t &quot;%r&quot; %s %b" />
        </Host>
      </Engine>
    </Service>
    ```
2.  创建目录并修改权限

    ```shell
    # webapps 为软链， 可查看软链指向的目录，在 Manjaro 上为 /var/lib/tomcat9/webapps
    readlink $CATALINA_HOME/webapps
    # 创建目录
    sudo mkdir /var/lib/tomcat9/app
    # 修改权限
    sudo chown tomcat9:tomcat9 /var/lib/tomcat9/app
    # 创建软链
    sudo ln -s /var/lib/tomcat9/app $CATALINA_HOME/app
    # 设置根路径 war
    sudo cp app.war /var/lib/tomcat9/app/ROOT.war
    ```


### 手动下载安装 {#手动下载安装}

```shell
wget https://mirrors.bfsu.edu.cn/apache/tomcat/tomcat-9/v9.0.43/bin/apache-tomcat-9.0.43.tar.gz
tar -zxvf apache-tomcat-9.0.43.tar.gz
sudo mv apache-tomcat-9.0.43 /opt/tomcat
export CATALINA_HOME=/opt/tomcat
# 启动
$CATALINA_HOME/bin/startup.sh
# 停止
$CATALINA_HOME/bin/shutdown.sh
```
