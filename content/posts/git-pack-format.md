---
title: "Git Pack 格式"
date: 2021-12-27T13:49:20+08:00
tags: ["git"]
categories: ["git"]
---

git `.pack` 文件分为三大块：
- 头部 12-byte
- 1~n 个对象条目
  - 对象条目
    - n-byte 类型和长度
    - 数据
- 校验和 20-byte

[测试数据](/files/git-pack-format.git.tar.gz)

## 头部 12-byte

- 4-byte 签名 `PACK`
- 4-byte 版本号，网络字节序，一般为 `2` 或者 `3`
- 4-byte 对象数量

```text
00000000  50 41 43 4b 00 00 00 02  00 00 00 06 90 0d 78 9c
          ----------- ============ ----------- 
          P  A  C  K  version      obj count 6
```

## 对象条目

头部之后，是 N 个对象条目，每个条目有两部分：

- n-byte 类型和长度(3-bit 类型, (n-1)*7+4-bit length)
- 条目内容(undeltified 和 deltified 两类)

### n-byte 类型和长度

- n-byte 类型和长度(3-bit 类型, (n-1)*7+4-bit length)
  ```text
  |----------------------------------------+---------------------------|
  | 1-bit flag | 3-bit type | 4-bit length | 1-bit flag | 7-bit length |
  |----------------------------------------+---------------------------|
  ```
- 第 1 字节
  - 1-bit 标志位: 1 继续读取下一字节；0 结束
  - 3-bit 类型
  - 4-bit 长度，低位
- 第 2~n 字节
  - 1-bit 标志位: 1 继续读取下一字节；0 结束
  - 7-bit 长度，高位

类型有 6 种，可分为 undeltified 和 deltified 两类:

- undeltified
  - `OBJ_COMMIT` (1)
  - `OBJ_TREE` (2)
  - `OBJ_BLOB` (3)
  - `OBJ_TAG` (4)
- deltified
  - `OBJ_OFS_DELTA` (6)
  - `OBJ_REF_DELTA` (7)

长度计算：左字节为低位，右字节为高位

### undeltified

undeltified 仅包含被压缩的 git 对象数据， 使用 deflate 算法进行压缩。

需要通过被压缩数据计算下一条目位置。

#### 示例

```text
# git verify-pack 输出截取
# SHA-1 type size size-in-packfile offset-in-packfile
93869920eddd1d8c632cda85537d1547339472c6 commit 208 154 12

# .pack 数据截取
00000000  50 41 43 4b 00 00 00 02  00 00 00 06 90 0d 78 9c
                                               =====
                                               type and length
```

- `0x90` = `0b1_001_0000` 
  - `1` 表示需要继续读取下一个字节
  - `001` 类型 commit
  - `0000` 长度最低 4 位
- `0x0d` = `0b0_0001101`
  - `0` 表示当前字节为最后一个字节
  - `0001101` 长度高 7 位

所以数据长度为 `0b0001101_0000` = 0xd0 = 208 字节， 和 `verify-pack` 数据一致。

这里的数据长度是压缩前的大小，无法直接计算出下一个对象条目的位置，需要通过被压缩数据的来计算。

`verify-pack` 中的打包长度 154 byte = 2 byte(类型和长度) + 152 byte(压缩数据)。

第一个对象条目的偏移是 12(头部长度 12 byte)。

通过 ruby 读取压缩数据：

```ruby
require 'zlib'

file = File.open('objects/pack/pack-164f4734388b5ebb26bf4607048798bec6ea6494.pack', 'r')
file.seek(12 + 2)                # 偏移 + 类型长度段
zstream = Zlib::Inflate.new
puts zstream.inflate(file.read)  # 被压缩的数据，读取的数据超出了压缩数据长度
puts zstream.total_out           # 208 byte 压缩前数据大小
puts zstream.total_in            # 152 byte 压缩后数据大小
zstream.finish
zstream.close
```

被压缩的数据大小为 152 byte。该类型为 commit，但被压缩的数据中不包含 commit oid，需要重新计算。

### deltified

deltified 有两种类型：
- ref delta
- ofs delta
  - n-byte 偏移
  - 被压缩的数据

#### ofs delta

ofs delta 在包内 offset 位置的获取基础对象，解析获取原始数据，以该原始对象为基础取一个或者多个 (offset, size) 进行拼接形成完整的数据

##### 基础对象相对偏移

基础对象相对偏移(pack 内偏移)

- n-byte 相对偏移，相对于当前条目起始位置的偏移
  ```text
  |------------+--------------+------------+--------------|
  | 1-bit flag | 7-bit offset | 1-bit flag | 7-bit offset |
  |------------+--------------+------------+--------------|
  ```
- 1-bit 标志位: 1 继续读取下一字节；0 结束
- 7-bit 偏移，左高位，右低位

偏移计算：

```text
byte = read(1)
base_offset = byte & 0x7F

while (byte & 0x80)
  byte = read(1)
  base_offset + 1
  base_offset = (base_offset << 7) + (byte & 0x7F)
end

base_offset
```

数据的绝对偏移 = 当前条目的偏移 - 相对偏移(base_offset)

##### 被压缩的数据

被压缩的数据，使用 deflate 进行压缩。

数据解压后分为：

- n-byte 基础对象大小
- n-byte 当前对象大小
- n-byte delta 数据：其中包含多个 (offset, size) 对，该偏移是基础对象原始数据内的偏移

对象大小计算：

```text
|---------------------------+---------------------------|
| 1-bit flag | 7-bit offset | 1-bit flag | 7-bit offset |
|---------------------------+---------------------------|
```

- 第 1~n 字节
  - 1-bit 标志位: 1 继续读取下一字节；0 结束
  - 7-bit 长度

第 1 字节为低位，第 n 字节为高位

delta 数据包含偏移和大小，意思是相对于基础 git 对象(未压缩)数据偏移 offset 字节后读取 size 字节。

```text
+----------+---------+---------+---------+---------+-------+-------+-------+
| 1xxxxxxx | offset1 | offset2 | offset3 | offset4 | size1 | size2 | size3 |
+----------+---------+---------+---------+---------+-------+-------+-------+
```

- `1-byte` 标识
  - `1-bit` 1 继续读取下一段
  - `3-bit` 三个大小位(小端，低位在右侧)，位为 1 时表示对应的偏移字节位不为 0，需要继续读取 1 字节作为长度
  - `4-bit` 四个偏移位(小端，低位在右侧)，位为 1 标识对应的大小字节位不为 0，需要继续读取 1 字节作为偏移
- `0~7-byte` 偏移或者大小

如

```text
+------------+----------+----------+
| 1_001_0001 | 00110110 | 00011011 |
|            |  offset1 |    size1 |
+------------+----------+----------+
```

offset = 0b00110110 = 54, size = 0b00011011 = 27，从基础 git 对象原始数据读取字节范围 [54, 54+27)

#### 示例

```text
# git verify-pack 输出截取
# SHA-1 type size size-in-packfile offset-in-packfile
5e0b62e32ef12479435b781852d35d00e7734b6e blob   167 89 335
37d275cddcb6d23c12c9103c031c0371d49f4831 tree   38 48 424
# SHA-1 type size size-in-packfile offset-in-packfile depth base-SHA-1
bc8e5eb13b8e17363744051b29a3e53bad1562cc blob   9 20 472 1 5e0b62e32ef12479435b781852d35d00e7734b6e

# .pack 文件数据截取
000001d0  a2 49 67 00 d5 2d 0c 72  69 80 09 78 9c 5b ce b8
                                   == ----- ==============
000001e0  88 71 42 fb 44 33 69 00  11 8a 03 45 16 4f 47 34
          ====================================
```

类型长度、基础对象偏移：

- `0x69` = `0b0_100_0101`
  - `0` 不需要读取下一个字节
  - `110` 类型 `OBJ_OFS_DELTA`
  - `1001` 长度 9，被压缩部分长度
- `0x80` = `0b1_000_0000`
  - `1` 需要读取下一个字节
  - `000_0000` 偏移高 7 位
- `0x09` = `0b0_000_1001`
  - `0` 不需要读取下一个字节
  - `000_1001` 偏移低 7 位

相对于该节点起点的偏移量计算 ((0b000_0000 + 1) << 7) + (0b000_1001) = 137

绝对偏移量 472(当前对象偏移) - 137(相对偏移) = 335，335 为另一个 blob 对象的偏移

```ruby
require 'zlib'

file = File.open('objects/pack/pack-164f4734388b5ebb26bf4607048798bec6ea6494.pack', 'r')
file.seek(472 + 3) # 3 字节 = 1 byte 类型长度段 + 1 byte 基础对象偏移段
zstream = Zlib::Inflate.new
buf = zstream.inflate(file.read)
zstream.total_out  # 9  压缩前大小
zstream.total_in   # 17 压缩后大小
zstream.finish
zstream.close
buf.bytes.map{|b| b.to_s(16) }.join(' ')
# a7 1 a2 1 90 87 91 36 1b
```

数据解压后为 `a7 1 a2 1 90 87 91 36 1b`

```text
00000000  a7 01 
          1_0100111 0_0000001
                      0000001_0100111 = 167 (base size)
00000002  a2 01
          1_0100010 0_0000001
                      0000001_0100010 = 162 (size)
00000006  90 87
          1_001_0000 10000111
          offset = 0, size = 10000111 = 135 [0,135]
00000008  91 36 1b
          1_001_0001 00110110 00011011
          offset = 00110110 = 54 , size = 00011011 = 27 [54,27]
```

当前数据 [offset, size] 为 `base_object[0, 135]` 以及 `base_objects[54, 27]`


## 校验和 20-byte

以上所有内容的 SHA1 值。

```ruby
require 'digest'

file = File.open('objects/pack/pack-164f4734388b5ebb26bf4607048798bec6ea6494.pack', 'r')

Digest::SHA1.hexdigest(file.read(file.size-20))
file.read.unpack1('H*')
# 164f4734388b5ebb26bf4607048798bec6ea6494
```

## 仅包含 undeltified 示例

```text
$ git verify-pack --verbose objects/pack/pack-164f4734388b5ebb26bf4607048798bec6ea6494.idx
93869920eddd1d8c632cda85537d1547339472c6 commit 208 154 12
6f9ed2b9081959cb7153a50580d8b24a9ae2fd72 commit 157 121 166
24ed1c14fc5a324338248b2e1056590413c91b3a tree   38 48 287
5e0b62e32ef12479435b781852d35d00e7734b6e blob   167 89 335
37d275cddcb6d23c12c9103c031c0371d49f4831 tree   38 48 424
bc8e5eb13b8e17363744051b29a3e53bad1562cc blob   9 20 472 1 5e0b62e32ef12479435b781852d35d00e7734b6e
non delta: 5 objects
chain length = 1: 1 object
objects/pack/pack-164f4734388b5ebb26bf4607048798bec6ea6494.pack: ok

$ hexdump -C objects/pack/pack-164f4734388b5ebb26bf4607048798bec6ea6494.pack
00000000  50 41 43 4b 00 00 00 02  00 00 00 06 90 0d 78 9c  |PACK..........x.|
          ----------- ===========  ----------- =====
           P  A  C  K version 2    obj count 6 1_001_0000 0_0001101
00000010  8d cb 3d 0a c2 40 10 40  e1 7e 4f b1 bd 10 66 f6  |..=..@.@.~O...f.|
00000020  2f 3b 20 a2 60 4a 1b 6f  30 d9 9d 68 c0 98 10 26  |/; .`J.o0..h...&|
00000030  90 e3 9b 23 d8 bc e2 c1  a7 ab 88 75 41 2a 16 0c  |...#.......uA*..|
00000040  43 89 ec 5d f0 3e bb 90  7b 27 08 31 45 82 80 be  |C..].>..{'.1E...|
00000050  10 f6 9e cd c2 ab 7c d5  a6 81 a4 ba 9e 20 23 45  |......|...... #E|
00000060  2a 7d 8b d1 73 84 98 a1  1e 2c 30 b1 b8 a1 b6 ce  |*}..s....,0.....|
00000070  f0 a6 ef 79 b5 af 51 ed  f9 c8 55 76 9e 96 8f 34  |...y..Q...Uv...4|
00000080  65 9e 2e 16 53 80 d4 62  22 b2 27 c8 00 e6 b8 d3  |e...S..b".'.....|
00000090  a8 2a 7f 03 b3 2d 95 55  ec b3 bb dd 1f 5d a3 bb  |.*...-.U.....]..|
000000a0  9a 1f 48 eb 3c 21 9d 09  78 9c 8d 8b 41 0a c2 30  |..H.<!..x...A..0|
                            =====
                            1_001_1101 0_0001001
000000b0  10 00 ef 79 c5 de 85 b2  9b c4 24 05 11 05 7b f4  |...y......$...{.|
000000c0  e2 0f e2 ee aa 05 43 a5  ac d0 e7 9b 27 78 98 39  |......C.....'x.9|
000000d0  0c 8c ad aa 10 b2 f8 bc  67 11 be 27 f1 81 c9 f3  |........g..'....|
000000e0  48 18 18 03 75 32 49 1c  1f b1 04 72 f5 6b af 65  |H...u2I....r.k.e|
000000f0  85 e7 6c 70 e8 3a e9 56  db e7 ad 03 2f ed 08 94  |..lp.:.V..../...|
00000100  22 a6 4c a9 78 d8 61 41  74 bd b6 d9 4c ff 1e 5c  |".L.x.aAt...L..\|
00000110  15 81 db 74 be 5c a7 c1  36 73 3f 4c ca 2d 9a a6  |...t.\..6s?L.-..|
                                                        ==
                                                        1_010_0110
00000120  02 78 9c 33 34 30 30 33  31 51 08 72 75 74 f1 75  |.x.340031Q.rut.u|
          ==
          0_0000010
00000130  d5 2b a9 28 61 88 e3 4e  7a ac f7 51 a5 d2 39 ba  |.+.(a..Nz..Q..9.|
00000140  42 22 e8 72 2c c3 f3 62  ef 3c 00 d6 77 0c b9 b7  |B".r,..b.<..w...|
                                                        ==
                                                        1_011_0111
00000150  0a 78 9c 33 34 32 36 31  35 33 b7 b0 34 30 44 63  |.x.3426153..40Dc|
          ==
          0_0001010
00000160  71 39 3a 39 bb b8 ba b9  7b 78 7a 79 fb f8 fa f9  |q9:9....{xzy....|
00000170  07 04 06 05 87 84 86 85  47 44 46 71 25 26 25 a7  |........GDFq%&%.|
00000180  a4 a6 a5 67 64 66 65 e7  e4 e6 e5 17 14 16 15 97  |...gdfe.........|
00000190  94 96 95 57 54 56 71 a1  1b 43 9c 81 86 f8 8c 34  |...WTVq..C.....4|
000001a0  32 e6 02 00 38 27 31 81  a6 02 78 9c 33 34 30 30  |2...8'1...x.3400|
                                   =====
                                   1_010_0110 0_0000010
000001b0  33 31 51 08 72 75 74 f1  75 d5 2b a9 28 61 d8 d3  |31Q.rut.u.+.(a..|
000001c0  17 b7 d1 ba 4f dc cc dc  85 55 5a 73 f1 53 eb b5  |....O....UZs.S..|
000001d0  a2 49 67 00 d5 2d 0c 72  69 80 09 78 9c 5b ce b8  |.Ig..-.ri..x.[..|
                                   == -----
                                   0_110_1001
                                      1_0000000 0_0001001
000001e0  88 71 42 fb 44 33 69 00  11 8a 03 45 16 4f 47 34  |.qB.D3i....E.OG4|
000001f0  38 8b 5e bb 26 bf 46 07  04 87 98 be c6 ea 64 94  |8.^.&.F.......d.|
00000200
```

## 参考

- https://github.com/git/git/blob/v2.34.1/Documentation/technical/pack-format.txt
