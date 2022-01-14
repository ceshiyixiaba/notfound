---
title: "Linux Nginx https 配置"
date: 2022-01-13T11:25:17+08:00
tags: [""]
categories: [""]
draft: true
---

```ruby
require 'json'

HTTPS                   = 'HTTPS'
HTTP_X_FORWARDED_SSL    = 'HTTP_X_FORWARDED_SSL'
HTTP_X_FORWARDED_SCHEME = 'HTTP_X_FORWARDED_SCHEME'
HTTP_X_FORWARDED_PROTO  = 'HTTP_X_FORWARDED_PROTO'
RACK_URL_SCHEME         = 'rack.url_scheme'

class Test
  def call(env)
    req = Rack::Request.new(env)
    data = {
      ssl: req.ssl?,
      HTTPS: req.get_header(HTTPS),
      HTTP_X_FORWARDED_SSL: req.get_header(HTTP_X_FORWARDED_SSL),
      HTTP_X_FORWARDED_SCHEME: req.get_header(HTTP_X_FORWARDED_SCHEME),
      HTTP_X_FORWARDED_PROTO: req.get_header(HTTP_X_FORWARDED_PROTO),
      RACK_URL_SCHEME: req.get_header(RACK_URL_SCHEME),
    }
    puts data
    [200, { 'Content-Type' => 'application/json' }, [JSON.pretty_generate(data)]]
  end
end

run Test.new
```

## 参考

- https://www.nginx.com/resources/wiki/start/topics/examples/forwarded/
- https://serverfault.com/questions/515957/how-to-have-nginx-forward-the-http-x-forwarded-proto-header
- https://www.digitalocean.com/community/questions/configure-nginx-ssl-force-http-to-redirect-to-https-force-www-to-non-www-on-serverpilot-free-plan-using-nginx-configuration-file-only
