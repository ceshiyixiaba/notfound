---
title: "Linux Varnish Http Header"
date: 2022-02-18T18:56:59+08:00
tags: ["varnish"]
categories: ["varnish"]
draft: true
---

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
  { time: Time.now, public: true }.to_json
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

  { time: Time.now, cookies: true, public: true }.to_json
end

get '/cookies/public_10' do
  cache_control :public, max_age: 10
  cookies[:something] = 'foobar'
  { time: Time.now, cookies: true, public: true, max_age: 10 }.to_json
end
```

## 参考
