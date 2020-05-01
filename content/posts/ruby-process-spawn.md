+++
title = "Ruby Process.spawn 缓冲区满导致阻塞"
author = ["likui"]
date = 2021-05-13T21:00:00+08:00
lastmod = 2021-05-26T11:00:36+08:00
tags = ["ruby"]
draft = false
+++

## Ruby Process.spawn 缓冲区满导致阻塞 {#ruby-process-dot-spawn-缓冲区满导致阻塞}


### Ruby Process.spawn 阻塞 {#ruby-process-dot-spawn-阻塞}

Ruby 中使用 `Process.spawn` 和 `pipe` 时，pipe 缓冲区为 64 KB，如果不及时读取数据，将会发生阻塞。

```ruby
# 未超出缓冲区容量
# cmd = "bash -c 'for i in {1..6500}; do echo '123456789'; done'"
# 超出缓冲区容量
cmd = "bash -c 'for i in {1..6600}; do echo '123456789'; done'"

out_r, out_w = IO.pipe
cmd_pid = Process.spawn(cmd, :out => out_w, :err => out_w)
out_w.close

Process.wait(cmd_pid)
exitstatus = $?.exitstatus

out = out_r.read
puts "child: cmd out length = #{out.length}; Exit status: #{exitstatus}"
```

-   标准输出缓冲区满，进程无法结束， `Process.wait` 一直等待


#### 新线程读缓冲区: {#新线程读缓冲区}

```ruby
cmd = "bash -c 'for i in {1..6600}; do echo '123456789'; done'"

out_r, out_w = IO.pipe
cmd_pid = Process.spawn(cmd, :out => out_w, :err => out_w)
out_reader = Thread.new { out_r.read }
out_w.close

Process.wait(cmd_pid)
exitstatus = $?.exitstatus

puts "child: cmd out length = #{out_reader.value.length}; Exit status: #{exitstatus}"
```


#### 新线程等待子进程结束： {#新线程等待子进程结束}

```ruby
Thread.new do
  Process.wait(cmd_pid)
  exitstatus = $?.exitstatus
end
```


### Ruby Open3.popen3 阻塞 {#ruby-open3-dot-popen3-阻塞}

> You should be careful to avoid deadlocks. Since pipes are fixed length buffers,
> ::popen3(“prog”) {|i, o, e, t| o.read } deadlocks if the program generates too much
> output on stderr. You should read stdout and stderr simultaneously (using threads or
> IO.select). However, if you don’t need stderr output, you can use ::popen2. If merged
> stdout and stderr output is not a problem, you can use ::popen2e. If you really need
> stdout and stderr output as separate strings, you can consider ::capture3.

```ruby
require 'open3'

# 未超出缓冲区容量
# cmd = "bash -c 'for i in {1..6500}; do echo '123456789'; done'"
# cmd = "bash -c 'for i in {1..6500}; do echo '123456789' 1>&2; done'"

# 超出缓冲区容量
# cmd = "bash -c 'for i in {1..6600}; do echo '123456789'; done'"
cmd = "bash -c 'for i in {1..6600}; do echo '123456789' 1>&2; done'"

Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
  stdin.close
  stdout.read
  stderr.read
  exit_status = wait_thr.value
end

```

-   标准出错缓冲区满，导致子进程阻塞。父进程在 `stdout.read` 处一直等待
-   如果调换 `stdout.read` 和 `stderr.read` 位置，可以将标准出错缓冲区内容读取出来，但如果出现标准输出缓冲区满，问题依旧
-   可以使用两个独立的线程分别读取 `stdout` 和 `stderr`

换成 `Open3.capture3`

```ruby
stdout_str, stderr_str, status = Open3.capture3(cmd)

# capture3 使用了独立的线程读取标准输出和标准出错
# out_reader = Thread.new { o.read }
# err_reader = Thread.new { e.read }
```

-   `capture3` 使用了独立的线程读取标准输出和标准出错


### 参考 {#参考}

-   <https://stackoverflow.com/questions/13829830/ruby-process-spawn-stdout-pipe-buffer-size-limit>
-   <https://bugs.ruby-lang.org/issues/9082>
-   <https://ruby-doc.org/stdlib-2.7.3/libdoc/open3/rdoc/Open3.html#method-c-capture3>
-   <https://ruby-doc.org/stdlib-2.7.3/libdoc/open3/rdoc/Open3.html#method-c-popen3>
