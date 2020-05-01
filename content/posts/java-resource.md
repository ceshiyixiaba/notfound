---
title: "读取 Java Resource 中的文件"
date: 2020-05-01T13:10:22+08:00
tags: ["java"]
draft: false
---

读取 Java Resource 中的文件

## 源码

```java
package com.example;

import java.io.IOException;

public class App {
  public static void main( String[] args ) throws IOException {
    from();
    fromClassLoader();

    App app = new App();
    app.fromInstance();
    app.fromInstanceClassLoader();
  }

  public static void from() throws IOException {
    System.out.println(App.class.getResource("/data.txt").toString());
    // App.class.getResourceAsStream("/data.txt");
  }

  public static void fromClassLoader() throws IOException {
    System.out.println(App.class.getClassLoader().getResource("data.txt").toString());
    // App.class.getClassLoader().getResourceAsStream("data.txt");
  }

  public void fromInstance() {
    System.out.println(getClass().getResource("/data.txt"));
    // getClass().getResourceAsStream("/data.txt");
  }

  public void fromInstanceClassLoader() {
    System.out.println(getClass().getClassLoader().getResource("data.txt"));
    // getClass().getClassLoader().getResourceAsStream("data.txt");
  }
}

```

未打包时，路径为普通文件路径，可以直接读取：

```shell
cd target/classes
java com.example.App 
file:/home/notfound/test/demo/target/classes/data.txt
file:/home/notfound/test/demo/target/classes/data.txt
file:/home/notfound/test/demo/target/classes/data.txt
file:/home/notfound/test/demo/target/classes/data.txt
```

打包成 jar 后，路径为 jar URL，无法直接通过路径读取文件：

```shell
java -jar target/demo-1.0-SNAPSHOT.jar
jar:file:/home/notfound/test/demo/target/demo-1.0-SNAPSHOT.jar!/data.txt
jar:file:/home/notfound/test/demo/target/demo-1.0-SNAPSHOT.jar!/data.txt
jar:file:/home/notfound/test/demo/target/demo-1.0-SNAPSHOT.jar!/data.txt
jar:file:/home/notfound/test/demo/target/demo-1.0-SNAPSHOT.jar!/data.txt
```

－可以通过 `getResourceAsStream` 来获取 `InputStream` 对象，对文件内容进行读取。

## Q

### 在 jar 中，如何通过 `RandomAccessFile` 读取文件内容？

jar 中的内容已经被压缩处理，无法随机读取。可以将内容写入到临时文件中，然后通过 `RandomAccessFile` 读取临时文件。

## 参考

- [Executable JAR](http://maven.apache.org/plugins/maven-shade-plugin/examples/executable-jar.html)
- [RandomAccessFile to read files in a Jar file](https://stackoverflow.com/questions/23420976/randomaccessfile-to-read-files-in-a-jar-file)
