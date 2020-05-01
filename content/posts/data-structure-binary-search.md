---
title: "二分查找"
date: 2020-05-18T19:03:17+08:00
tags: ["data structure"]
draft: true
---

阅读 gem [mini_mime](https://github.com/discourse/mini_mime) 源码，发现了作者通过二分查找在文件中[定位数据](https://github.com/discourse/mini_mime/blob/b588e0f876d0bc36c30e7581d397b813d26e69c8/lib/mini_mime.rb#L126)，所以简单回顾一下。

## 算法实现

二分查找，每次折半。

```ruby
#!/bin/env ruby

def log(data, from, to)
  result = data.each_with_index.map do |d, index|
    if from == to && from == index
      "[#{d}]"
    elsif from == index
      "[#{d} "
    elsif to == index
      " #{d}]"
    else
      " #{d} "
    end
  end

  puts result.join
end

def binary_search(data, value)
  puts "length #{data.length}, search #{value}..."

  from = 0
  to = data.length - 1

  while from <= to
    log(data, from, to)

    mid = from + (to - from ) / 2
    d = data[mid]

    if value < d
      to = mid - 1
    elsif value > d
      from = mid + 1
    else
      puts "find value #{d}"
      return
    end
  end
  puts "not found"
end

def main
  length = 20 + rand(10)
  data = length.times.map { rand(99) }.sort
  binary_search(data, rand(99))
end

main
```

- 只能处理已经排序的数据
- 数据需要支持随机读取

算法简单高效。
