---
title: "Git Attributes Diff Filter 配置"
date: 2021-09-19T18:25:26+08:00
tags: ["git"]
---

## Diff Filter

Git diff 只能比较文本，如果能将二进制转换为文本，那么就可以实现二进制的对比。

Diff filter 在对比前将原始数据转换为文本，然后将文本内容交给 Git diff 进行差异计算:

```text
旧原始数据 --> Diff filter --> 处理后的数据(文本) --\
                                                 > 对比
新原始数据 --> Diff filter --> 处理后的数据(文本) --/
```

## 添加一个 Diff filter

编辑 `.gitattributes`:

```conf
*.xx diff=your_filter
```

所有 `*.xx` 文件都需要经过 `your_filter` 处理，那 `your_filter` 去哪里找？答案是 `git config`:

```bash
git config diff.your_filter.textconv your_program
```

- `textconv` 将需要对比数据转换文本格式

可执行程序 `your_program` 需要满足以文件路径作为参数，并将结果打印到标准输出。

## 示例

### PNG 元数据对比

`exiftool` 可以获取文件的元数据，且以文件路径为参数，结果打印到标准输出，可直接作为一个 Diff Filter：

```text
$ exiftool 1.png
ExifTool Version Number         : 12.30
File Name                       : 1.png
Directory                       : .
File Size                       : 244 KiB
File Modification Date/Time     : 2021:09:19 21:12:58+08:00
File Access Date/Time           : 2021:09:19 21:13:19+08:00
File Inode Change Date/Time     : 2021:09:19 21:12:58+08:00
File Permissions                : -rw-r--r--
File Type                       : PNG
File Type Extension             : png
MIME Type                       : image/png
Image Width                     : 542
Image Height                    : 339
Bit Depth                       : 8
Color Type                      : RGB
Compression                     : Deflate/Inflate
Filter                          : Adaptive
Interlace                       : Noninterlaced
Pixels Per Unit X               : 6299
Pixels Per Unit Y               : 6299
Pixel Units                     : meters
Image Size                      : 542x339
Megapixels                      : 0.184
```

编辑 `.gitattributes`:

```conf
*.png diff=exif
```
- PNG 文件对比前交由 `exif` 过滤器处理

配置 `exif` 过滤器:

```bash
git config diff.exif.textconv exiftool
```

执行 `git diff` 或者 `git show`：

```diff
diff --git a/1.png b/1.png
index 8c17513..c093c41 100644
--- a/1.png
+++ b/1.png
@@ -1,16 +1,16 @@
 ExifTool Version Number         : 12.30
-File Name                       : 4nFqmN*1.png
-Directory                       : /tmp
-File Size                       : 265 KiB
-File Modification Date/Time     : 2021:09:19 21:15:24+08:00
-File Access Date/Time           : 2021:09:19 21:15:24+08:00
-File Inode Change Date/Time     : 2021:09:19 21:15:24+08:00
-File Permissions                : -rw-------
+File Name                       : 1.png
+Directory                       : .
+File Size                       : 244 KiB
+File Modification Date/Time     : 2021:09:19 21:12:58+08:00
+File Access Date/Time           : 2021:09:19 21:15:18+08:00
+File Inode Change Date/Time     : 2021:09:19 21:12:58+08:00
+File Permissions                : -rw-r--r--
 File Type                       : PNG
 File Type Extension             : png
 MIME Type                       : image/png
-Image Width                     : 566
-Image Height                    : 363
+Image Width                     : 542
+Image Height                    : 339
 Bit Depth                       : 8
 Color Type                      : RGB
 Compression                     : Deflate/Inflate
@@ -19,5 +19,5 @@ Interlace                       : Noninterlaced
 Pixels Per Unit X               : 6299
 Pixels Per Unit Y               : 6299
 Pixel Units                     : meters
-Image Size                      : 566x363
-Megapixels                      : 0.205
+Image Size                      : 542x339
+Megapixels                      : 0.184
```
- 旧文件路径为 `/tmp/4nFqmN*1.png`，说明对比前会创建临时文件，该文件路径会作为过滤器的参数
- 元数据对比结果，而非 PNG 文件本身

### 十六进制方式对比

修改 `.gitattributes`:
```conf
*.bin diff=hex
```
-  `*.bin` 交个过滤器 `hex` 处理

配置 `hex` 过滤器:

```bash
git config diff.hex.textconv "hexdump -C"
```

执行 `git diff` 或者 `git show`：

```diff
diff --git a/main.bin b/main.bin
index 276798a..6be8837 100755
--- a/main.bin
+++ b/main.bin
@@ -54,8 +54,8 @@
 00000350  01 00 00 00 00 00 00 00  01 00 01 c0 04 00 00 00  |................|
 00000360  01 00 00 00 00 00 00 00  02 00 01 c0 04 00 00 00  |................|
 00000370  00 00 00 00 00 00 00 00  04 00 00 00 14 00 00 00  |................|
-00000380  03 00 00 00 47 4e 55 00  bd 9f ae 1c da ef ff 93  |....GNU.........|
-00000390  d7 cf 1d 3e 72 60 fe 7e  ef ef 7f 6e 04 00 00 00  |...>r`.~...n....|
+00000380  03 00 00 00 47 4e 55 00  11 73 36 ac 4c 3f 7b b5  |....GNU..s6.L?{.|
+00000390  d4 0a f0 d1 66 78 65 d9  07 cb f1 14 04 00 00 00  |....fxe.........|
 000003a0  10 00 00 00 01 00 00 00  47 4e 55 00 00 00 00 00  |........GNU.....|
 000003b0  04 00 00 00 04 00 00 00  00 00 00 00 00 00 00 00  |................|
 000003c0  01 00 00 00 01 00 00 00  01 00 00 00 00 00 00 00  |................|
@@ -130,7 +130,7 @@
 000011e0  48 83 c4 08 c3 00 00 00  00 00 00 00 00 00 00 00  |H...............|
 000011f0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
 *
-00002000  01 00 02 00 48 65 6c 6c  6f 20 57 6f 72 6c 64 21  |....Hello World!|
+00002000  01 00 02 00 48 65 6c 6c  6f 20 57 6f 72 6c 64 3f  |....Hello World?|
 00002010  00 00 00 00 01 1b 03 3b  30 00 00 00 05 00 00 00  |.......;0.......|
 00002020  0c f0 ff ff 64 00 00 00  2c f0 ff ff 4c 00 00 00  |....d...,...L...|
 00002030  25 f1 ff ff 8c 00 00 00  4c f1 ff ff ac 00 00 00  |%.......L.......|
diff --git a/main.cc b/main.cc
index d2bb6c5..6873eca 100644
--- a/main.cc
+++ b/main.cc
@@ -1,5 +1,5 @@
 #include<stdio.h>
 
 int main() {
-  printf("Hello World!");
+  printf("Hello World?");
 }
```
## 参考

- http://git-scm.com/book/zh/v2/%E8%87%AA%E5%AE%9A%E4%B9%89-Git-Git-%E5%B1%9E%E6%80%A7
