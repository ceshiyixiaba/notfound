+++
title = "Java cli 以及配置文件路径处理"
author = ["likui"]
date = 2021-03-14T16:00:00+08:00
lastmod = 2021-03-14T16:52:05+08:00
tags = ["java"]
draft = false
+++

## Java cli 以及配置文件路径处理 {#java-cli-以及配置文件路径处理}

-   OpenJDK 11
-   Gradle 6.8
-   Apache Commons CLI


### 命令参数处理 {#命令参数处理}


#### 依赖 {#依赖}

修改 `build.gradle` ：

```groovy
implementation group: 'commons-cli', name: 'commons-cli', version: '1.4'
```


#### 源码 {#源码}

大致执行步骤：

```java
CommandLineParser parser = new DefaultParser();

Options options = new Options();
options.addOption("a", "all", false, "do not hide entries starting with .");
options.addOption("A", "almost-all", false, "do not list implied . and ..");
options.addOption(Option.builder()
                  .longOpt("block-size")
                  .desc("use SIZE-byte blocks")
                  .hasArg()
                  .argName("SIZE")
                  .build());

if (args.length == 0) {
    HelpFormatter formatter = new HelpFormatter();
    formatter.printHelp("ls", options);
    return;
}

try {
    CommandLine line = parser.parse(options, args);
    if(line.hasOption( "block-size" )) {
        System.out.println("block-size: " + line.getOptionValue("block-size"));
    }
    if (line.hasOption("a")) System.out.println("a");
    if (line.hasOption("A")) System.out.println("A");
} catch (ParseException e) {
    System.out.println( "Unexpected exception:" + e.getMessage() );
}
```

-   `HelpFormatter` 格式化输出参数帮助信息


### 自定义配置文件路径处理 {#自定义配置文件路径处理}

通过 `user.dir` 获取当前的执行目录，结合 cli 可以获取配置文件绝对路径：

```java
System.getProperty("user.dir")
```


### 参考 {#参考}

-   [Cli Usage Scenarios](http://commons.apache.org/proper/commons-cli/usage.html)
