---
title: "监控 Ruby 进程"
date: 2020-05-14T20:12:27+08:00
tags: ["monitoring", "ruby"]
categories: ["monitoring"]
draft: false
---

- 系统环境 Ubuntu 18.04

## 指标

- 当前进程占用的内存：

  ```shell
  cat /proc/self/status | grep VmRSS
  VmRSS:       740 kB
  ```
  
  ```ruby
  match = File.read('/proc/self/status').match(/VmRSS:\s+(\d+)/)
  match && match[1].to_f * 1024
  ```

- 当前进程打开的文件描述符总数：

  ````shell
  ls /proc/self/fd | wc -l
  ````
  
  ```ruby
  Dir.glob('/proc/self/fd/*').length
  ```

- 当前进程可打开的最大文件描述符数量：

  ```shell
  cat /proc/self/limits | grep "Max open files"
  ```
  
  ```ruby
  match = File.read('/proc/self/limits').match(/Max open files\s*(\d+)/)
  match && match[1]
  ```

- 进程 CPU 时钟：

  ```ruby
  Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID, :float_second)
  ```

- 墙上时钟，受系统时间影响，调整系统时间时会发生变化：

  ```ruby
  Process.clock_gettime(Process::CLOCK_REALTIME, :float_second)
  ```

- 系统启动时一直计数，不会受到系统时间的影响：

  ```ruby
  Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second)
  ```

- 线程 CPU 时钟：

  ```ruby
  Process.clock_gettime(Process::CLOCK_THREAD_CPUTIME_ID, :float_second)
  ```

- 测量 Ruby 代码执行时间：

  ```ruby
  Benchmark.measure { "a"*1_000_000_000 }
  ```
  
  返回 用户 CPU 时间、系统 CPU 时间、用户 CPU 时间以及 系统 CPU 时间之和。

## 参考

- man 2 clock_gettime
- [Process](https://ruby-doc.org/core-2.6.1/Process.html)
- [Benchmark](https://ruby-doc.org/stdlib-2.6.1/libdoc/benchmark/rdoc/Benchmark.html)
