---
title: "Ruby Rack"
date: 2020-05-21T20:24:53+08:00
tags: ["ruby"]
draft: false
---

模块化的 Ruby Web 服务接口

## rackup

创建 `config.ru`，添加：

```ruby
# config.ru
run lambda {|env| [200, {'Content-Type' => 'text/plain'}, ['OK'] ]}
```

执行 `rackup`，启动 HTTP 服务器。

### 过程

`rackup` 文件内容如下：

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require "rack"
Rack::Server.start
```

1. `Rack::Server#options`
    1. `Rack::Server#default_options` 这里决定了查找的默认文件名 `options[:config]= 'config.ru'`
1. `Rack::Server#start`
    1. `Rack::Server#server` 尝试 require `puma thin falcon webrick` 中的一个服务，假设为 `webrick`，则返回 `Rack::Handler::WEBrick` 类
        1. `Rack::Server#wrapped_app` 解析 `config.ru` 获取 `wrapped_app`
            1. `Rack::Server#app`
                1. `Rack::Server#build_app_and_options_from_config`
                    1. `Rack::Builder.parse_file`
                    1. `Rack::Builder.load_file`
                    1. `Rack::Builder.new_from_string` 在 `Rack::Builder` 类上下文中执行 `config.ru`，`run` 方法来源于此
        1. `Rack::Handler::WEBrick.run` 启动服务 `webrick` 服务，在 `/` 路由下挂载 `Rack::Server#wrapped_app`
            1. `WEBrick::HTTPServer#mount` 以 `Rack::Handler::WEBrick` 和 `wrapped_app` 作为参数
            1. `WEBrick::HTTPServer#start` 启动 HTTP 服务
            1. 请求到来时，创建 `Rack::Handler::WEBrick` 实例，并包裹 `wrapped_app`
                1. `Rack::Handler::WEBrick#service` 调用 `service` 方法
                    1. `app.call` 调用 `call` 方法，处理请求

### 过程代码

上述的黑魔法类似于下列代码：

```ruby
# server.rb
require 'rack'
require 'webrick'

app = Rack::Builder.app do
  # config.ru
  run lambda {|env| [200, {'Content-Type' => 'text/plain'}, ['OK'] ]}
end

server = WEBrick::HTTPServer.new :Port => 8080
server.mount '/', Rack::Handler::WEBrick, app
server.start
```

webrick 作为服务器处理请求，可以使用 `ruby server.rb` 直接运行。

## 中间件

中间件可以一层层叠加，外层调用里层的中间件，直到最后的 `servlet`（run）：

```ruby
class Middleware
  def initialize(app)
    @app = app
  end

  def call(env)
    puts "dome something"
    env["rack.some_header"] = "setting an example"
    @app.call(env)
  end
end

use Middleware
run lambda { |env| [200, { "Content-Type" => "text/plain" }, ["OK"]] }
```

`use` 方法源码：

```ruby
    def use(middleware, *args, &block)
      if @map
        mapping, @map = @map, nil
        @use << proc { |app| generate_map(app, mapping) }
      end
      @use << proc { |app| middleware.new(app, *args, &block) }
    end
```

`to_app` 方法源码：

- `@use` 为 `proc` 数组，意味着要调用 `user[0].call(app).call` 才会执行 `middleware.call`
  - 第一次的 `call` 方法由 `to_app` 调用
  - 第二次的 `call` 用户请求到来时调用，意味着不同请求使用同一个中间件对象

```ruby
    def to_app
      app = @map ? generate_map(@run, @map) : @run
      fail "missing run or map statement" unless app
      app.freeze if @freeze_app
      app = @use.reverse.inject(app) { |a, e| e[a].tap { |x| x.freeze if @freeze_app } }
      @warmup.call(app) if @warmup
      app
    end
```

- `e[a]` 会调用 `call` 方法，最里层的 app 不会执行 `call` 方法，外层的中间件都会执行 `call` 方法创建中间件对象

```ruby
app = lambda { |a| "param: #{a}" }
app["hello"]
=> "param: hello"
```

### 代码过程

上述过程可简单的表达为如下代码：

```ruby
# server.rb
require 'rack'
require 'webrick'

@use = []

@use << proc { |app| Rack::CommonLogger.new(app) }

app = @run = lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }

app = @use.reverse.inject(app) { |a, e| e[a] }

server = WEBrick::HTTPServer.new :Port => 8080
server.mount '/', Rack::Handler::WEBrick, app
server.start
```

## 总结

- `call` 方法穿透所有，层层包裹

## 参考

- [rack](https://github.com/rack/rack)
