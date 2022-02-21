---
title: "Linux Varnish 与 HTTP 头部"
date: 2022-02-18T18:56:59+08:00
tags: ["varnish"]
categories: ["varnish"]
---

- 未设置 Cookies 和 Cache-Control 相关 HTTP 头部时，缓存默认时长
- `Cache-Control` 可以控制是否缓存以及缓存时长
- 包含 Cookie 相关头部时不会缓存

## 测试

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

### 测试代码

```ruby
# frozen_string_literal: true

require 'sinatra'
require "sinatra/cookies"
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
```

## 取消 Cookie

## 参考
