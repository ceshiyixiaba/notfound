---
title: "Webrick 工作过程"
date: 2020-05-19T20:23:43+08:00
tags: ["ruby"]
draft: false
---

Webrick 是用 Ruby 语言实现的 HTTP 服务。

## 运行过程

### 创建监听 socket

```ruby
require 'webrick'

server = WEBrick::HTTPServer.new :Port => 8000
trap 'INT' do server.shutdown end # SIGINT
```

1. 创建监听套接字，创建 mount table。mount table 将路由和 servlet 关联在一起
2. 注册 `SIGINT` 信号处理函数，接收到该信号时停止服务。`CTRL + C` 可产生该信号

### 挂载 proc

```ruby
server.mount_proc '/' do |req, res|
  res.body = "object_id: #{object_id}\n"
end
```

1. mount 的路由为 `/`
2. 实际 mount 的 servlet 是一个 `HTTPServlet::ProcHandler` 实例，该实例包裹了 proc
3. 这里不同请求使用同一个实例， 由 `HTTPServlet::ProcHandler#get_instance` 决定
4. mount table 路由为 key，servlet 为 value
5. 这里的 `object_id` 是哪个实例的？
6. 可处理 `GET` 和 `POST` 请求

### 挂载 class

```ruby
class Simple < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    status, content_type, body = do_stuff_with(request)

    response.status = 200
    response['Content-Type'] = 'text/plain'
    response.body = "object_id: #{object_id}\n"
  end

  def do_stuff_with(request)
    return 200, 'text/plain', 'you got a page'
  end
end

server.mount '/simple', Simple
```

1. mount 的路由为 `/simple`
2. mount servlet 为 Simple 类
3. 每次请求都会创建 Simple 实例, 由 `WEBrick::HTTPServlet::AbstractServlet.get_instance` 决定的
4. mount table 路由为 key，servlet 为 value

### 启动服务

```ruby
server.start
```

1. `IO.select` 上阻塞，等待连接。处于循环之内
1. `WEBrick::GenericServer#start_thread` 启动线程处理 socket
    1. `WEBrick::HTTPServer#run` 处理请求。方法中存在一个循环，一直到 socket 非 `:Running` 才退出
        1. `WEBrick::HTTPServer#service`
            1. `WEBrick::HTTPServer#search_servlet` 通过 mount table 查询路由对应的 servlet
            1. `si = servlet.get_instance(self, *options)` 获取 servlet 实例，可能会创建新的 servlet 实例
            1. `si.service` 通过 servlet 实例处理请求
                1. 根据请求类型调用 `do_GET`、`do_POST` 等方法

### 总结

- 一个线程服务一个 socket
- 每一个请求可能创建一个 servlet 实例

## 参考

- [Webrick](https://github.com/ruby/webrick)
