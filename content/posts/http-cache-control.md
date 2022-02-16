---
title: "Http Etag 与 Last-Modified"
date: 2022-02-16T10:58:45+08:00
tags: ["http"]
---

## `ETag` 与 `If-None-Match`

新建 `app.rb`:

```ruby
require 'sinatra'
require 'digest'

get '/req1' do
  etag Digest::MD5.hexdigest('Hello ETag!')

  'Hello ETag!'
end
```

执行 `ruby app.rb` 启动服务。

```text
$ curl -I http://localhost:4567/req1
HTTP/1.1 200 OK
ETag: "7a6ee48ea7568446c2658e55ac389b1a"
Content-Type: text/html;charset=utf-8
Content-Length: 11

$ curl -I -H 'If-None-Match: "7a6ee48ea7568446c2658e55ac389b1a"' http://localhost:4567/req1
HTTP/1.1 304 Not Modified
ETag: "7a6ee48ea7568446c2658e55ac389b1a"
```
1. 第一次客户端直接请求
    1. 服务务端返回 200，并包含 `ETag` 头部和完整 body
2. 第二次客户端发送请求时携带 `If-None-Match: {ETag}` 头部
    1. 服务端通过 `If-None-Match` 的值 `ETag` 判断数据是否过期，未过期时直接返回 304 和 ETag，body 为空

ETag 可以是内容的哈希或者其他值，在命中 ETag 的情况下，减少了数据的传输。

### 强/弱 ETag

- 强 ETag 要求数据每个字节完全一致，未经过任何处理，包括压缩。
- 弱 ETag 以 `W/` 开头，Nginx 在开启 gzip 的情况下，会变成弱 ETag。

## `Last-Modified` 与 `If-Modified-Since`

新建 `app.rb`:

```ruby
require 'sinatra'

get '/req2' do
  last_modified Time.new(2022, 1, 1, 8)

  'Hello, Last-Modified!'
end
```

执行 `ruby app.rb` 启动服务。

```text
$ curl -I http://localhost:4567/req2
HTTP/1.1 200 OK
Last-Modified: Sat, 01 Jan 2022 00:00:00 GMT
Content-Type: text/html;charset=utf-8
Content-Length: 21

$ curl -I -H "If-Modified-Since: Sat, 01 Jan 2022 00:00:00 GMT" http://localhost:4567/req2 
HTTP/1.1 304 Not Modified
Last-Modified: Sat, 01 Jan 2022 00:00:00 GMT
```

1. 第一次客户端直接请求
    1. 服务务端返回 200，并包含 `Last-Modified:` 头部和完整 body
2. 第二次客户端发送请求时携带 `If-Modified-Since: {Date}` 头部
    1. 服务端通过 `If-Modified-Since` 的值 `Date` 判断数据是否过期，未过期时直接返回 304 和 Last-Modified，body 为空


`Last-Modified` 为最后修改时间，内容为更改的情况下可以减少数据的传输。

## `Cache-Control`

`Cache-Control` 通过指定指令来实现缓存机制。包括可缓存性、到期时间等等。

```ruby
require 'sinatra'

get '/req3' do
  cache_control :public, :max_age => 60

  'Hello, Cache Control!'
end
```

重复请求会重复发送数据，需要与 `ETag` 和 `Last-Modified` 一起使用。

## 参考

- <https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Conditional_requests>
- <https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/ETag>
- <https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Last-Modified>
- <https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Cache-Control>
- <http://sinatrarb.com/intro-zh.html>
- <https://naluduo.vip/Web-Performance-Optimization>
