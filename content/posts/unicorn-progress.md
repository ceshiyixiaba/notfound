---
title: "Unicorn 启动、重启和终止"
date: 2020-05-15T20:43:44+08:00
tags: ["ruby"]
draft: false
---

起因，需要在 unicorn master 上开启一个线程定时收集 Ruby 进程运行数据。

Unicorn 生命周期中设置了多个回调： `after_fork`、`before_fork`、`before_exec`、`after_worker_exit` 和 `after_worker_ready`，需要在合适的时间点创建线程。

## 启动、重启和终止

在 unicorn 配置文件代码中打上日志，就可以知道大致的工作过程：

```ruby
# local variable to guard against running a hook multiple times
run_once = true

before_fork do |server, worker|
  server.logger.info "before_fork"

  if run_once
    server.logger.info "before_fork run_once"
    # do_something_once_here ...
    run_once = false # prevent from firing again
  end

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      server.logger.info "kill #{File.read(old_pid).strip} #{sig}"
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

before_exec do |server|
  server.logger.info "before_exec"
end

after_fork do |server, worker|
  server.logger.info "after_fork"
end
```

### 启动

1. 启动 master
2. 执行 before_fork，每个 worker 都会执行一次
3. 启动 worker
4. 执行 after_fork，每一个 woker 进程都会执行一次

```log
[#25404 master-n] : Refreshing Gem list
[#25404 master-n] : listening on addr=0.0.0.0:8080 fd=20
[#25404 master-n] : before_fork
[#25404 master-n] : before_fork run_once   # 执行一次
[#25404 master-n] : before_fork
[#25407 worker-0] : after_fork
[#25404 master-n] : before_fork
[#25407 worker-0] : worker=0 ready
[#25410 worker-1] : after_fork
[#25410 worker-1] : worker=1 ready
[#25404 master-n] : master process ready
[#25413 worker-2] : after_fork
[#25413 worker-2] : worker=2 ready
```

### 重启

1. 启动 new master 进程
2. new master 执行 before_exec
3. new master 执行 before_fork，并向 old master 发送 TTOU 信号。创建最后一个 worker 进程前(before_fork)，向 old master 发送 QUIT 信号
4. new worker 执行 after_exec
5. old master 接收到 QUIT 信号后，结束掉 old woker 进程，然后退出

```log
[#25513 master-n] : executing ["unicorn", "-c", "config/unicorn.conf.rb", "-D"] # 创建新的 master
[#25513 master-n] : before_exec
[#25513 master-n] : inherited addr=0.0.0.0:8080 fd=20
[#25513 master-n] : Refreshing Gem list
[#25513 master-n] : before_fork
[#25513 master-n] : before_fork run_once     # 执行一次
[#25513 master-n] : kill 25404 TTOU          # 创建 woker 前(before_fork) 向旧的 master 发送 TTOU
[#25513 master-n] : before_fork
[#25513 master-n] : kill 25404 TTOU
[#25524 worker-0] : after_fork
[#25524 worker-0] : worker=0 ready
[#25513 master-n] : before_fork
[#25513 master-n] : kill 25404 QUIT          # 创建最后一个 woker (before_fork)前后向旧的 master 发送 QUIT
[#25527 worker-1] : after_fork
[#25527 worker-1] : worker=1 ready
[#25513 master-n] : master process ready
[#25530 worker-2] : after_fork
[#25530 worker-2] : worker=2 ready
[#25404 master-o] : reaped #<Process::Status: pid 25407 exit 0> worker=0  # 旧的 master 开始清理旧的 woker
[#25404 master-o] : reaped #<Process::Status: pid 25410 exit 0> worker=1
[#25404 master-o] : reaped #<Process::Status: pid 25413 exit 0> worker=2
[#25404 master-o] : master complete                                       # 旧的 master 退出
```

关键点
- 新的 master 和所有的 woker 就绪之后，才会终止旧的进程
- 新的 master 和旧的 master 通过信号通信
- 旧的 master 负责清理旧的 woker，然后退出

### 终止

1. master 结束掉所有的 worker 进程，然后退出。

```log
[#25513] : reaped #<Process::Status: pid 25524 exit 0> worker=0
[#25513] : reaped #<Process::Status: pid 25527 exit 0> worker=1
[#25513] : reaped #<Process::Status: pid 25530 exit 0> worker=2
[#25513] : master complete
```

## master 主要工作

master 负责管理子进程，在无限循环中等待信号、以及检查 woker 数量和是否超时，当 woker 数量减少时会创建新的 woker，当 woker 运行超时时会被 kill：

```ruby
@sig_queue = []
@queue_sigs = [:WINCH, :QUIT, :INT, :TERM, :USR1, :USR2, :HUP, :TTIN, :TTOU]
@queue_sigs.each { |sig| trap(sig) { @sig_queue << sig } }

def log(message)
  puts "##{Process.pid} #{message}"
end

def master(pid)
  Process.detach(pid)

  loop do
    case @sig_queue.shift
    when nil
      # 检查 worker 超时
      # 检查 worker 数量
      sleep 0.5
    when :USR1
      log "receive :USR1"
    when :USR2
      log "receive :USR2"
    when :TERM
      log "receive :TERM"
      break
    end
  end

  sleep 1
end

def worker(ppid)
  # TODO
end

ppid = Process.pid

if pid = fork
  master(pid)
else
  worker(ppid)
end
```

- [trap](https://ruby-doc.org/core-2.5.0/Signal.html) 方法可以注册信号处理函数。当信号发生时，会执行 `trap` 后面的代码块。


## 问题：线程与进程

线程创建后执行 `fork` 操作，正在执行的线程会是怎样的存在？在 Linux 中并不推荐多线程中使用 fork，充满了不确定性，可参考 [谨慎使用多线程中的fork](https://www.cnblogs.com/liyuan989/p/4279210.html)。

来段代码，测试几个比较关心的问题：

> 1. 也就是说除了调用 fork 的线程外，其他线程在子进程中“蒸发”了。
> 2. 假设在 fork 之前，一个线程对某个锁进行的 lock 操作，即持有了该锁，然后另外一个线程调用了 fork 创建子进程。可是在子进程中持有那个锁的线程却"消失"了，从子进程的角度来看，这个锁被“永久”的上锁了，因为它的持有者“蒸发”了。

```ruby
def log(message )
  STDERR.puts "##{Process.pid} #{message}"
end

log("parent pid")
mutex = Mutex.new

t = Thread.new do
  mutex.synchronize do
    log("thread mutex start")
    sleep 2
  end
  log("thread mutex end")
end

sleep 1 # 让线程先执行

if pid = fork
  log("parent before, alive?: #{t.alive?}, locked: #{mutex.locked?}" )
  sleep 2
  log("parent after, alive?: #{t.alive?}, locked: #{mutex.locked?}" )
else
  # 线程占用 mutex 时，子进程被创建
  log("child before, alive?: #{t.alive?}, locked: #{mutex.locked?}" )
  sleep 2
  log("child after, alive?: #{t.alive?}, locked: #{mutex.locked?}" )
end

log("done")

sleep 1
```

输出结果如下(ruby 2.5.1p57 x86_64-linux-gnu)：

```log
#9544 parent pid                                 # 父进程 id
#9544 thread mutex start                         # 父进程中，线程启动，持有 mutex
#9544 parent before, alive?: true, locked: true  # 父进程中，mutex 被占用
#9547 child before, alive?: false, locked: false # 子进程中，mutex 未被占用，线程没有执行
#9544 thread mutex end                           # 父进程中，线程结束，释放 mutex
#9544 parent after, alive?: false, locked: false
#9547 child after, alive?: false, locked: false  # 子进程中，线程依旧没有执行
#9547 done
#9544 done
```

- fork 前创建线程，fork 后线程并不会在子进程中继续执行
- fork 前线程占用了 Mutex，在 fork 后子进程并不会继续占用

又产生了新的问题：

- Ruby 中的 Mutex 是否和 Linux 系统中的锁对应呢？ Ruby 中的多线程是否和 Linux 中的多线程对应呢？还是 Ruby 语言本身进行了特殊的处理？
- 如果进程中存在文件的读、写操作，是否会造成死锁？或者调用某些方法是否会造成死锁？

如果在 fork 时线程持有了锁， fork 之后，子进程中的线程不会执行，锁也就无法释放，此时如果子进程尝试获取锁就会一直等待。(上面的示例并没有出现这种情况，原因未知)

当前需求是在 master 进程中执行监控线程。woker 进程不需要执行线程以及占用相同的锁，发生上述问题也不会产生不良影响。

## 结论

- 大部分时间 master 都是比较清闲的
- 可以考虑在 `befork_fork` 回调里 `run_once` 启动一个单独的线程进行监控数据收集

## 参考

- [unicorn](https://yhbt.net/unicorn/)
- [Signal](https://ruby-doc.org/core-2.5.0/Signal.html)
- `man 7 signal`
- [谨慎使用多线程中的fork](https://www.cnblogs.com/liyuan989/p/4279210.html)
- [极不和谐的 fork 多线程程序](https://blog.codingnow.com/2011/01/fork_multi_thread.html)
