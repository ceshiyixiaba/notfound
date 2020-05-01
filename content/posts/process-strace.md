---
title: "使用 strace 查看 Ruby 线程系统调用"
date: 2020-05-29T21:07:45+08:00
tags: ["linux"]
draft: false
---

- Ubuntu 18.04 
- 通过 strace 查看 Unicorn 中开启的监控线程是否运行正常

###

1. 查看进程 ID

    ```text
    $ ps -ef | grep unicorn
    notfound    20178  6419  2 11:22 ?        00:00:17 unicorn master -E production -c config/unicorn.rb -D
    notfound    20192 20178  0 11:22 ?        00:00:00 unicorn worker[0] -E production -c config/unicorn.rb -D
    notfound    20195 20178  0 11:22 ?        00:00:00 unicorn worker[1] -E production -c config/unicorn.rb -D
    notfound    20198 20178  0 11:22 ?        00:00:00 unicorn worker[2] -E production -c config/unicorn.rb -D
    ```

2. 查看进程和线程

    ```text
    $ pstree -pt 20178
    bundle(20178)─┬─bundle(20192)─┬─{ruby-timer-thr}(20194)
                  │               └─{ruby_sampler}(20201)
                  ├─bundle(20195)─┬─{ruby-timer-thr}(20197)
                  │               └─{ruby_sampler}(20202)
                  ├─bundle(20198)─┬─{ruby-timer-thr}(20200)
                  │               └─{ruby_sampler}(20203)
                  ├─{ruby-timer-thr}(20199)
                  ├─{server.rb:293}(20212)
                  ├─{unicorn_sampler}(20190)
                  ├─{utils.rb:156}(20213)
                  └─{web_exporter}(20191)
    ```

3. 查看线程执行内容

    ```text
    $ strace -p 20201
    ```

## 参考

- `man strace`
- `man pstree`
