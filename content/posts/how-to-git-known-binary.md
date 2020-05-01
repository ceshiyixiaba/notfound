---
title: "Git 如何识别二进制文件"
date: 2020-05-16T16:17:29+08:00
tags: ["git"]
draft: false
---

Git 区分二进制和文本文件？

## 源码

Git 是通过函数 [buffer_is_binary](https://github.com/git/git/blob/d8437c57fa0752716dde2d3747e7c22bf7ce2e41/xdiff-interface.c#L188) 识别二进制：

```c
#define FIRST_FEW_BYTES 8000
int buffer_is_binary(const char *ptr, unsigned long size)
{
  if (FIRST_FEW_BYTES < size)
    size = FIRST_FEW_BYTES;
  return !!memchr(ptr, 0, size);
}
```

- 文件前 8000 个字节与 `\0` 进行比较，非文件末尾出现 `\0` 就认为是二进制

C 语言中，字符串一定是以 `\0` 结束，简单的想一想，感觉没毛病。

## 问题

- Q: 多字节文件编码中，难道其中的某个字节不会出现 `\0`？

  文件内容`1`，保存为 utf16：
  
  ```text
  $ file utf16.txt
  utf16.txt: Little-endian UTF-16 Unicode text, with no line terminators

  $ hexdump -C utf16.txt
  00000000  ff fe 31 00 0a 00                                 |..1...|
  00000006
  ```

  查看差异时，会被错误识别为二进制文件：

  ```diff
  diff --git a/utf16.txt b/utf16.txt
  new file mode 100644
  index 0000000..0811156
  Binary files /dev/null and b/utf16.txt differ

  ```

  然而 GitHub 不会将 UTF-16 识别为二进制，说明和 Git 命令识别方式有区别。

## charlock_holmes

GitHub 使用 charlock_holmes 来检测二进制文件， 该 gem 包方法将常见的[文件类型头部列出](https://github.com/brianmario/charlock_holmes/blob/e52cb2ec6d31615836935344de47998c4e399227/ext/charlock_holmes/encoding_detector.c#L61)（包括 UTF-16 和 UTF-32）单独进行比较，以减少误伤：

```c
static int detect_binary_content(VALUE self, VALUE rb_str) {
	size_t buf_len, scan_len;
	const char *buf;

  /*
   * 省略大部分代码
   */

	if (buf_len > 1) {
		// UTF-16BE
		if (!memcmp(buf, "\xfe\xff", 2))
			return 0;

		// UTF-16LE
		if (!memcmp(buf, "\xff\xfe", 2))
			return 0;
	}

	/*
	 * If we got this far, any NULL bytes within the `scan_len`
	 * range will likely mean the contents are binary.
	 */
	if (scan_len < buf_len)
		buf_len = scan_len;
	return !!memchr(buf, 0, buf_len);
}
```

## 参考

- [UTF-16](https://zh.wikipedia.org/wiki/UTF-16)
- [charlock_holmes](https://github.com/brianmario/charlock_holmes)
