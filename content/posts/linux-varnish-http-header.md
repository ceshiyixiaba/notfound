---
title: "Linux Varnish 与 HTTP 头部"
date: 2022-02-18T18:56:59+08:00
tags: ["varnish"]
categories: ["varnish"]
---

## 规则

默认 TTL 为 120s

1. 未设置 HTTP 缓存相关头部：缓存 120s
2. 设置 `Cache-Control: private`:不缓存
3. 设置 `Cache-Control: public`: 缓存 120s
    1. 客户端请求携带 `Cookie: something=foobar`：不缓存
4. 设置 `Cache-Control: public, max-age=10`：缓存 10s
5. 设置 `Set-Cookie: something=foobar; path=/; HttpOnly`: 不缓存
6. 设置 `Set-Cookie: something=foobar; path=/; HttpOnly` 和 `Cache-Control: public`：不缓存
7. 设置 `ETag: "1872ade88f3013edeb33decd74a4f947"`: 缓存 120s
    1. 客户端请求未携带 `If-None-Match: "1872ade88f3013edeb33decd74a4f947"`：缓存 120s
    2. 客户端请求携带 `If-None-Match: "1872ade88f3013edeb33decd74a4f947"`：缓存 120s
8. 设置 `Last-Modified: Sat, 01 Jan 2022 00:00:00 GMT`：缓存 120s
    1. 客户端携带 `If-Modified-Since: Sat, 01 Jan 2022 00:00:00 GMT`: 缓存 120s

总结：
- 响应未设置 `Cache-Control` 头部时（同时也未包含 cookie 相关头部），缓存默认时长
- 响应 `Cache-Control` 可以控制是否缓存以及缓存时长
- 包含请求包括 `Cookie`、响应包含 `Set-Cookie` 时不会缓存

## 缓存包含 Cookie 的请求

### 移除请求中 Cookie 头部

```vcl
sub vcl_recv {
    unset req.http.Cookie;
}
```
- 移除掉 HTTP Cookie 头部，后端无法收到 Cookie

### 忽略请求中 Cookie 头部

场景：后端服务通过 Cookie 才能判断数据为公开或私有，对公开数据进行缓存，因此需要将 Cookie 传递给后端。

解决方案：
1. varnish 忽略请求中的 Cookie 头部。
2. [可选]后端服务通过 `Cache-Control` 控制数据能否缓存以及缓存时长。

[默认内置规则](https://github.com/varnishcache/varnish-cache/blob/6.0/bin/varnishd/builtin.vcl#L64) 遇到 HTTP 请求头 `Authorization` 和 `Cookie` 直接跳过，不缓存：

```vcl
    if (req.http.Authorization || req.http.Cookie) {
        /* Not cacheable by default */
        return (pass);
    }
```

可根据[默认内置规则](https://github.com/varnishcache/varnish-cache/blob/6.0/bin/varnishd/builtin.vcl#L64)修改 `/etc/varnish/default.vcl`，即使存在 Cookie 头部，依旧进行缓存：

```vcl
sub vcl_recv {
    if (!req.http.host &&
      req.esi_level == 0 &&
      req.proto ~ "^(?i)HTTP/1.1") {
        /* In HTTP/1.1, Host is required. */
        return (synth(400));
    }
    if (req.method == "GET" || req.method == "HEAD") {
        /* We only deal with GET and HEAD by default */
        if (req.http.Cookie) {
            /* Cacheable */
            return (hash);
        }
    }
}
```
- 即使存在 Cookie 头部，也进入 hash 阶段
- 其他情况根据内置默认规则进行处理


[可选] 为尽量避免缓存私有数据，缓存交给后端响应的 HTTP 头部 `Cache-Control`控制。[内置默认规则](https://github.com/varnishcache/varnish-cache/blob/6.0/bin/varnishd/builtin.vcl#L154)未携带 `Cache-Control` 时，会对缓存数据，修改该规则：
```vcl
sub vcl_backend_response {
    if (!beresp.http.Cache-Control || beresp.http.Cache-Control == "") {
        set beresp.uncacheable = true;
    }
}
```
- 后端响应未携带 `Cache-Control` 头部或者为空时，不进行缓存。

## Vary

响应头部，决定缓存时使用哪些请求头部，为这些头部不同的值缓存一个不同的版本。

```text
Vary: User-Agent
```
- 为请求中不同的 `User-Agent` 缓存不同的版本

## 测试代码

安装 ruby 依赖：
```bash
sudo gem install sinatra
sudo gem install sinatra-contrib
```

测试代码：

```ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/cookies'
require 'digest'
require 'json'

get '/' do
  { time: Time.now }.to_json
end

get '/private' do
  cache_control :private
  { time: Time.now, public: false }.to_json
end

get '/public' do
  cache_control :public
  { time: Time.now, public: true, cookies: request.cookies }.to_json
end

get '/public_10' do
  cache_control :public, max_age: 10
  { time: Time.now, public: true, max_age: 10 }.to_json
end

get '/cookies' do
  cookies[:something] = 'foobar'
  { time: Time.now, cookies: true }.to_json
end

get '/cookies/public' do
  cookies[:something] = 'foobar'
  cache_control :public
  { time: Time.now, cookies: true, public: true }.to_json
end

get '/etag' do
  etag Digest::MD5.hexdigest('etag')
  { time: Time.now, etag: true }.to_json
end

get '/last-modified' do
  last_modified Time.new(2022, 1, 1, 8)
  { time: Time.now, last_modified: true }.to_json
end

get '/vary' do
  headers 'Vary' => 'User-Agent'
  { time: Time.now, vary: request.user_agent }.to_json
end
```


## 参考

- <https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Cache-Control>
- <https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Last-Modified>
- <https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/ETag>
- <https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Vary>
- <https://varnish-cache.org/docs/6.0/users-guide/increasing-your-hitrate.html#http-vary>
