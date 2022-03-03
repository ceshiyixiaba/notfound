---
title: "Varnish 处理查询参数"
date: 2022-03-03T10:23:06+08:00
tags: ["varnish"]
categories: ["varnish"]
---

## URL.search 排序


默认配置下 URL 查询参数会对缓存命中率产生影响，`GET /raw?a=1&b=2` 和 `GET /raw?b=2&a=1` 会使用不同的缓存。

通过对 URL 查询参数进行排序，可提升缓存命中率：

```vcl
import std;

sub vcl_recv {
    set req.url = std.querysort(req.url);
}
```
- 导入 VMOD `std`
- 使用 `std.querysort` 对请求查询参数进行排序

后端服务收到的请求查询参数会被重新排序。

## 移除 URL.search

如果后端不需要处理查询参数，可考虑直接移除掉。

```vcl
sub vcl_recv {
    if (req.url ~ "\?") {
        set req.url = regsub(req.url, "\?.*$", "");
    }
}
```
- 如果 URL 中存在 `?` 则直接移除掉 `?` 以及之后的所有内容

## URL.search 查询参数白名单

仅保留指定的查询参数。

```vcl
sub vcl_recv {
    if (req.url ~ "\?") {
        # Keep query parameters only
        set req.http.X-Query = regsub(req.url, "^[^\?]*\?", "&");
        # reserved parameters: "title" and "body"
        set req.http.X-Query = regsuball(req.http.X-Query, "&(?!title=|body=)([^&]*)?", "");
        # replace the first "&"
        set req.http.X-Query = regsub(req.http.X-Query, "^&", "?");
        set req.url = regsub(req.url, "\?.*$", req.http.X-Query);
        unset req.http.X-Query;
    }
}
```
1. 提取查询参数到 `X-Query`，并将 `?` 替换成 `&`
2. 移除 `X-Query` 中的非 `title` 和 `body` 参数
3. 将 `X-Query` 中第一个字符 `&` 符号替换成 `?`
4. 将 `url` 中的查询参数替换成 `X-Query`

## 参考

- [Varnish 6 by Example](https://info.varnish-software.com/resources/varnish-6-by-example-book)#4.6.2 Sanitizing the URL
- <https://stackoverflow.com/questions/31879405/how-to-keep-specific-query-parameters-in-varnish>
