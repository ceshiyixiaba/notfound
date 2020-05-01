---
title: "Ruby GC"
date: 2021-01-20T10:27:23+08:00
tags: ["ruby"]
draft: true
---


```ruby
# ruby 2.7.2

{
  :count=>24,          # GC 次数
  :minor_gc_count=>20, # 尝试回收生存时间小于等于 3 个 GC 周期的对象
  :major_gc_count=>4,  # 尝试回收所有对象
  :compact_count=>0,   # 压缩移动对象次数，可减少内存碎片

  :heap_sorted_length=>119,

  :heap_available_slots=>48505,  # 所有 slots 数量
  :heap_live_slots=>48330,       # 存活 slots 数量
  :heap_free_slots=>175,         # 空闲 slots 数量
  :heap_final_slots=>0,          #
  :heap_marked_slots=>36741,     # 旧对象 slots 数量

  :heap_allocated_pages=>119,    # 已分配堆 page 数量
  :heap_allocatable_pages=>0,    # 可分配堆 page 数量

  :heap_eden_pages=>119,
  :heap_tomb_pages=>0,
  :total_allocated_pages=>119,
  :total_freed_pages=>0,

  :total_allocated_objects=>200406,
  :total_freed_objects=>152076,

  :remembered_wb_unprotected_objects=>434,
  :remembered_wb_unprotected_objects_limit=>644,

  :old_objects=>35848,           # 老对象数量
  :old_objects_limit=>56878,

  :malloc_increase_bytes=>81712,             # 堆外对象分配的空间
  :malloc_increase_bytes_limit=>16777216,
  :oldmalloc_increase_bytes=>1243928,        # old 堆外对象分配空间
  :oldmalloc_increase_bytes_limit=>16777216
}
```

测试代码

```ruby
#!/usr/bin/env ruby

def memory_usage
  # KB
  File.read('/proc/self/status').match(/VmRSS:\s+(\d+)/)[1].to_f
end

def memory
  puts ">>>>>>>>>>>>>>>>>>>>>>>"
  puts gc_stat
  puts memory_usage
  yield
  puts gc_stat
  puts memory_usage
  puts "<<<<<<<<<<<<<<<<<<<<<<<<"
end

def gc_stat
  GC.stat.slice(
    :count,
    :heap_live_slots,
    :heap_free_slots,
    :heap_available_slots,
    :malloc_increase_bytes,
  )
end

def main
  memory do
    str = "a" * 10_000_000
    #arr = 10_000_000.times.map(&:to_s)
  end

  memory do
    GC.start
  end
end
```

#### 长字符串

`str = "a" * 10_000_000` 前后

```text
{:major_gc_count=>1, :minor_gc_count=>7, :heap_live_slots=>18305, :heap_free_slots=>35, :heap_available_slots=>18340, :malloc_increase_bytes=>144584}
22488.0
{:major_gc_count=>1, :minor_gc_count=>7, :heap_live_slots=>18300, :heap_free_slots=>40, :heap_available_slots=>18340, :malloc_increase_bytes=>10150208}
32244.0
```

- `heap_available_slots`: 没有发生变化
- `malloc_increase_bytes`: +9.54 MB
- 内存变化: +9.53 MB

说明 在堆中分配

`GC.start` 前后

```text
{:major_gc_count=>1, :minor_gc_count=>7, :heap_live_slots=>18207, :heap_free_slots=>133, :heap_available_slots=>18340, :malloc_increase_bytes=>10153000}
32244.0
{:major_gc_count=>2, :minor_gc_count=>7, :heap_live_slots=>14605, :heap_free_slots=>4143, :heap_available_slots=>18748, :malloc_increase_bytes=>3576}
22548.0
```

- 内存变化: -9.47 MB

堆中内存大部分都会释放

#### 长数组

```text
{:count=>8, :heap_live_slots=>18305, :heap_free_slots=>39, :heap_available_slots=>18344, :malloc_increase_bytes=>143440}
22408.0
{:count=>27, :heap_live_slots=>10014612, :heap_free_slots=>124, :heap_available_slots=>10014736, :malloc_increase_bytes=>904}
540508.0
```

- `heap_live_slots`:  10 M, 每个字符一个 slot
- 内存变化: + 505.97 MB

40 bytes * 10 M = 400MB

`GC.start` 前后

```text
{:count=>27, :heap_live_slots=>10014637, :heap_free_slots=>99, :heap_available_slots=>10014736, :malloc_increase_bytes=>3568}
540508.0
{:count=>28, :heap_live_slots=>14604, :heap_free_slots=>5169255, :heap_available_slots=>5183859, :malloc_increase_bytes=>904}
462480.0
```

- 内存变化: -76.20MB

很多内存并没有释放

## 参考

- [关于 Ruby 内存使用的一些优化和探索](https://ruby-china.org/topics/27057)
- [Understanding Ruby GC through GC.stat](https://ruby-china.org/topics/37982)
- [Ruby 内存分配](https://www.jianshu.com/p/e4f184e92375)
- [How Ruby Uses Memory](https://ruby-china.org/topics/25790)
- [Ruby 的好朋友 -- jemalloc](https://ruby-china.org/topics/37699)
- [Ruby GC自述](https://www.jianshu.com/p/af6549f3eda0)

- [Ruby 的好朋友 -- jemalloc](https://ruby-china.org/topics/37699)
- [Malloc 会加倍 Ruby 多线程应用的内存消耗](https://www.jianshu.com/p/cf98f86e82d7)
