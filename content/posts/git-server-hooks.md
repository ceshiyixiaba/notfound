---
title: "Git 服务端 Hooks"
date: 2020-06-20T08:30:56+08:00
tags: ["git"]
draft: false
---

调用过程：

1. `pre-receive` 可阻止所有 ref 更新
1. `update` 可阻止单个 ref 更新
1. `post-receive` 无法阻止 ref 更新

## pre-receive

### 特点

- 无参数调用
- 标准输入传递引用信息
- 以非零值退出，所有的推送内容都不会被接受

### 用途

- 钩子阻止对引用进行非快进（non-fast-forward）的更新
- 对该推送所修改的所有引用和文件进行访问控制

### 示例

```ruby
#!/usr/bin/env ruby

LINE = '-' * 80

puts LINE
ENV.each do |k, v|
  puts "#{k}=#{v}" if k.start_with?('GIT')
end

puts LINE
# sha1-old SP sha1-new SP refname LF
while line = STDIN.gets
  puts line
end

puts LINE
exit(1)
```

推送两个分支

```text
git push origin master:master master:dev
枚举对象: 3, 完成.
对象计数中: 100% (3/3), 完成.
使用 4 个线程进行压缩
压缩对象中: 100% (2/2), 完成.
写入对象中: 100% (2/2), 218 字节 | 218.00 KiB/s, 完成.
总共 2（差异 0），复用 0（差异 0），包复用 0
remote: --------------------------------------------------------------------------------
remote: GIT_ALTERNATE_OBJECT_DIRECTORIES=/tmp/git/example.git/./objects
remote: GIT_DIR=.
remote: GIT_EXEC_PATH=/usr/lib/git-core
remote: GIT_OBJECT_DIRECTORY=/tmp/git/example.git/./objects/incoming-UqdPAn
remote: GIT_PUSH_OPTION_COUNT=0
remote: GIT_QUARANTINE_PATH=/tmp/git/example.git/./objects/incoming-UqdPAn
remote: --------------------------------------------------------------------------------
remote: 2f2cccd39a3f1dab015f19497da59656d268c2dd 2c4c31b2be6a45b3664a7aebc384748ecf835056 refs/heads/dev
remote: 2f2cccd39a3f1dab015f19497da59656d268c2dd 2c4c31b2be6a45b3664a7aebc384748ecf835056 refs/heads/master
remote: --------------------------------------------------------------------------------
To /tmp/git/example.git
 ! [remote rejected] master -> dev (pre-receive hook declined)
 ! [remote rejected] master -> master (pre-receive hook declined)
error: 推送一些引用到 '/tmp/git/example.git' 失败
```

## update

### 特点

- 受三个参数：引用的名字（分支），推送前的引用指向的内容的 SHA-1 值，以及用户准备推送的内容的 SHA-1 值
- 会为每一个准备更新的分支各运行一次
- 如果 update 脚本以非零值退出，只有相应的那一个引用会被拒绝；其余的依然会被更新

### 用途

- 钩子阻止对引用进行非快进（non-fast-forward）的更新
- 对该推送所修改的所有引用和文件进行访问控制

### 示例

```ruby
#!/usr/bin/env ruby

LINE = '-' * 80

puts LINE
puts ARGV
puts LINE

exit(1)
```

推送两个分支：

```text
git push origin master:master master:dev
枚举对象: 3, 完成.
对象计数中: 100% (3/3), 完成.
使用 4 个线程进行压缩
压缩对象中: 100% (2/2), 完成.
写入对象中: 100% (2/2), 218 字节 | 218.00 KiB/s, 完成.
总共 2（差异 0），复用 0（差异 0），包复用 0
remote: --------------------------------------------------------------------------------
remote: refs/heads/dev
remote: 2f2cccd39a3f1dab015f19497da59656d268c2dd
remote: 2c4c31b2be6a45b3664a7aebc384748ecf835056
remote: --------------------------------------------------------------------------------
remote: error: hook declined to update refs/heads/dev
remote: --------------------------------------------------------------------------------
remote: refs/heads/master
remote: 2f2cccd39a3f1dab015f19497da59656d268c2dd
remote: 2c4c31b2be6a45b3664a7aebc384748ecf835056
remote: --------------------------------------------------------------------------------
remote: error: hook declined to update refs/heads/master
To /tmp/git/example.git
 ! [remote rejected] master -> dev (hook declined)
 ! [remote rejected] master -> master (hook declined)
error: 推送一些引用到 '/tmp/git/example.git' 失败
```

## post-receive

### 特点

- 无参数调用
- 标准输入传递引用信息
- 在整个过程完结以后运行
- 无法终止推送进程
- 客户端在它结束运行之前将保持连接状态

### 用途

- 更新其他系统服务或者通知用户

### 示例


```ruby
#!/usr/bin/env ruby

LINE = '-' * 80

puts LINE
ENV.each do |k, v|
  puts "#{k}=#{v}" if k.start_with?('GIT')
end

puts LINE
# sha1-old SP sha1-new SP refname LF
while line = STDIN.gets
  puts line
end

puts LINE
exit(1)
```

推送两个分支：

```text
git push origin master:master master:dev
枚举对象: 3, 完成.
对象计数中: 100% (3/3), 完成.
使用 4 个线程进行压缩
压缩对象中: 100% (2/2), 完成.
写入对象中: 100% (2/2), 214 字节 | 214.00 KiB/s, 完成.
总共 2（差异 1），复用 0（差异 0），包复用 0
remote: --------------------------------------------------------------------------------
remote: GIT_DIR=.
remote: GIT_EXEC_PATH=/usr/lib/git-core
remote: GIT_PUSH_OPTION_COUNT=0
remote: --------------------------------------------------------------------------------
remote: 07e90506b50083173ff08015f115403c466dfcf5 17f4a373571ac61e82a591dc51b353c6fa02af90 refs/heads/dev
remote: 07e90506b50083173ff08015f115403c466dfcf5 17f4a373571ac61e82a591dc51b353c6fa02af90 refs/heads/master
remote: --------------------------------------------------------------------------------
To /tmp/git/example.git
   07e9050..17f4a37  master -> dev
   07e9050..17f4a37  master -> maste
```

## 参考

- [自定义 Git - Git 钩子](https://git-scm.com/book/zh/v2/%E8%87%AA%E5%AE%9A%E4%B9%89-Git-Git-%E9%92%A9%E5%AD%90)
