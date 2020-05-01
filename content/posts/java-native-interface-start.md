---
title: "JNI 基本使用"
date: 2020-05-16T11:48:23+08:00
tags: ["java"]
draft: false
---

- 系统环境 Ubuntu 18.04
- cmake 编译 c 源码
- maven 打包

## 基本用法

静态方法，不涉及参数和返回值传递。

项目目录结构如下：

```text
.
├── pom.xml
└── src
    └── main
        ├── java
        │   └── com
        │       └── example
        │           ├── App.java
        │           └── HelloNative.java     # 加载 .so 和调用 c 方法的 class
        ├── jni
        │   ├── CMakeLists.txt
        │   ├── com_example_HelloNative.c    # c 函数文件
        │   └── com_example_HelloNative.h    # javah 生成的头文件
        └── resources
            └── native
                └── linux
                    └── libHelloNative.so    # 编译生成的 so 文件目录
```

1. 添加 `HelloNative.java`，注意关键字 `native`

    ```java
    package com.example;
    
    public class HelloNative {
      public static native void greeting();
    }
    ```

2. 通过 `javah` 生成头文件 `com_example_HelloNative.h`，使用的时编译生成的 .class

    ```shell
    mvn compile
    cd target/classes/
    javah -d ../../src/main/jni com.example.HelloNative
    ```

3. 添加 `com_example_HelloNative.c`，函数名直接从 `.h` 复制过来

    ```c
    #include "com_example_HelloNative.h"
    
    JNIEXPORT void JNICALL Java_com_example_HelloNative_greeting (JNIEnv *env, jclass jc) {
      printf("Hello Native!");
    }
    ```

4. 添加 `CMakeLists.txt`，更多用法需要查看[官方文档](https://cmake.org/documentation/)

    ```cmake
    cmake_minimum_required (VERSION 2.6)
    project(HelloNative)
    MESSAGE(STATUS "PROJECT_NAME: " ${PROJECT_NAME})
    
    # 仅支持 Linux
    if (NOT CMAKE_HOST_UNIX)
      message(FATAL_ERROR "not linux")
    endif()
    
    # 需要设置 JAVA_HOME
    if(NOT DEFINED ENV{JAVA_HOME})
      message(FATAL_ERROR "not defined environment variable:JAVA_HOME")
    endif()
    
    MESSAGE( STATUS "JAVA_HOME: " $ENV{JAVA_HOME})
    
    SET(JAVA_INCLUDE "$ENV{JAVA_HOME}/include/")
    SET(JAVA_INCLUDE_OS "$ENV{JAVA_HOME}/include/linux/")
    
    # 添加 include 头文件搜索路径
    include_directories("${PROJECT_SOURCE_DIR}" "${JAVA_INCLUDE}" "${JAVA_INCLUDE_OS}")
    
    # 添加编译文件
    add_library(HelloNative SHARED com_example_HelloNative.c)
    
    set(CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/../")
    set(MAVEN_PATH "resources/native")
    
    # 编辑生成的 .so 安装到 resources 目录
    install (TARGETS HelloNative DESTINATION "${CMAKE_INSTALL_PREFIX}${MAVEN_PATH}/linux")
    ```

5. 手动生成 `libHelloNative.so`，这一步可以添加到 `pom.xml` 中

   ```shell
   mkdir src/main/jni/build
   cd src/main/jni/build 
   cmake ..
   make install
   ```

6. 加载 `.so` 文件

    ```java
    public class HelloNative {
      public static native void greeting();
    
      static {
        // System.loadLibrary("HelloNative");
        System.load("/tmp/libHelloNative.so");
      }
    }
    ```

    `System.load()` 方法需要使用绝对路径。

    `System.loadLibrary()` 参数的名称没有前、后缀，使用该方法时需要将 `.so` 目录添加到环境变量 `LD_LIBRARY_PATH`，否则无法找到 `.so`，会出现如下错误：

    ```shell
    java -jar target/jni-1.0-SNAPSHOT.jar
    Exception in thread "main" java.lang.UnsatisfiedLinkError: no HelloNative in java.library.path: \
    [/usr/java/packages/lib, /usr/lib/x86_64-linux-gnu/jni, /lib/x86_64-linux-gnu, /usr/lib/x86_64-linux-gnu, /usr/lib/jni, /lib, /usr/lib]
            at java.base/java.lang.ClassLoader.loadLibrary(ClassLoader.java:2670)
            at java.base/java.lang.Runtime.loadLibrary0(Runtime.java:830)
            at java.base/java.lang.System.loadLibrary(System.java:1870)
            at com.example.HelloNative.<clinit>(HelloNative.java:7)
            at com.example.App.main(App.java:5)
    ```
## 问题

- Q: 使用 maven 打包成 jar 时，`.so` 被压缩到了 `jar` 包中，无法直接读取。

    可以通过 java 中 resource 相关方法将 `.so` 文件写入到临时目录 `System.getProperty("java.io.tmpdir")`，然后通过 `System.load` 以绝对路径为参数进行加载。

- Q: 版本升级或者不同版本需要同时存在如何处理？

    可以考虑临时的文件名上加上版本号如 `libau.so.2.10`，避免版本冲突。

## 参考

- https://github.com/dynamsoft-dbr/java-jni-barcode
- 《Java核心技术·卷 II》
