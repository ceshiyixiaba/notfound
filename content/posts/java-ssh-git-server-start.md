+++
title = "使用 Java 实现 Git SSH 服务端"
author = ["likui"]
date = 2021-03-13T18:00:00+08:00
lastmod = 2021-03-13T18:31:32+08:00
tags = ["java", "git"]
draft = false
+++

## 使用 Java 实现 Git SSH 服务端 {#使用-java-实现-git-ssh-服务端}

-   OpenJDK 11
-   Gradle 6.8
-   [Apache MINA SSHD](https://github.com/apache/mina-sshd)


### 依赖 {#依赖}

修改 `build.gradle` 文件：

```groovy
implementation group: 'org.apache.sshd', name: 'sshd-core', version: '2.6.0'
implementation group: 'org.apache.sshd', name: 'sshd-git', version: '2.6.0'
// SSH KEY ed25519
// implementation group: 'net.i2p.crypto', name: 'eddsa', version: '0.3.0'
```

-   如果需要支持 ed25519，需要引入单独的包


### 代码 {#代码}

服务端主要使用包内自带的处理方式：

```java
public static void main(String[] args) throws IOException, InterruptedException {
    SshServer sshd = SshServer.setUpDefaultServer();
    sshd.setPort(8082);
    sshd.setHost("127.0.0.1");
    // 设置服务端私钥
    sshd.setKeyPairProvider(new FileKeyPairProvider(Path.of("/home/notfound/.ssh/id_rsa")));
    // 禁用密码验证
    sshd.setPasswordAuthenticator(null);
    // 禁用交互验证
    sshd.setKeyboardInteractiveAuthenticator(null);
    // 使用 ~/.ssh/authorized_keys 中的公钥验证客户端
    sshd.setPublickeyAuthenticator(DefaultAuthorizedKeysAuthenticator.INSTANCE);
    // 设置仓库根目录
    GitLocationResolver resolver = new GitLocationResolver() {
            @Override
            public Path resolveRootDirectory(String command, String[] args, ServerSession session, FileSystem fs) throws IOException {
                // 输出客户端公钥
                System.out.println(session.getAttribute(AuthorizedKeyEntriesPublickeyAuthenticator.AUTHORIZED_KEY));
                return fs.getPath("/srv/git-data");
            }
        };
    // 处理 git 操作
    sshd.setCommandFactory(new GitPackCommandFactory().withGitLocationResolver(resolver));
    sshd.start();
    // 其他操作
```

-   ServerSession 中的 `setAttribute` 可以携带自定义数据， `DefaultAuthorizedKeysAuthenticator.INSTANCE` 在 ServerSession 对象中保存了客户端公钥


### 参考 {#参考}

-   [GIT support](https://github.com/apache/mina-sshd/blob/sshd-2.6.0/docs/git.md)
