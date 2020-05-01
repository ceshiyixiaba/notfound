---
title: "Git Attributes filter 配置"
date: 2021-09-17T21:18:02+08:00
tags: ["git"]
---

## filter

filter 可以让工作区和版本库中的文件进行自定义转换，如加、解密。

### 工作区、暂存区和版本库：

- 工作区(working directory)：用户可以在工作区查看、编辑文件
- 暂存区(staged): 进入版本库前，临时保存
- 版本库: 数据进入版本库后，可以进行检出操作(checkout)

数据可以在三个位置流转：

- 工作区修改文件 -> git add -> 暂存区 -> git commit -> 版本库
- 版本库 -> git checkout -> 工作区

filter 作用于两个位置:

1. 工作区 -> filter -> 暂存区 -> 版本库
2. 版本库 -> filter -> 工作区

所以，一个 filter 应该存在两种操作，作用于两个不同的过程。

### 添加一个 filter

#### `.gitattributes`

编辑 `.gitattributes`:

```conf
*.xx filter=your_filter
```

所有`*.xx` 文件都需要经过 `your_filter` 处理，那 `your_filter` 去哪里找？答案是 `git config`:

#### git config

```bash
git config filter.your_filter.clean your_clean_program
git config filter.your_filter.smudge your_smudge_program
```
一个 filter 需要两种操作配合：
- `clean` 数据从工作区进入暂存区时，会先经过 `your_clean_program` 进行处理，暂存区的数据之后可提交到版本库
- `smudge` 数据从版本库进入工作区时，通过 `your_smudge_program` 进行处理

也就是 `clean` 在 git add 时调用，而 `smudge` 在 git checkout 时执行。
两个操作可构成一个对称，如：通过 `clean` 加密文件，此时版本库中的保存密文，再通过 `smudge` 解密，工作区中的数据就为明文。

#### clean 和 smudge

`your_clean_program` 和 `your_smudge_program` 为可执行文件，只要能做到从标准输入读取数据，将结果打印到标准输出即可。

一个简单的例子，工作区明文，而版本库存储 base64。Linux 下有一个工具 `openssl` 可以处理 base64:

```bash
# 编码
echo "Hello World" | openssl enc -base64
SGVsbG8gV29ybGQK

# 解码
echo "SGVsbG8gV29ybGQK" | openssl enc -base64 -d
Hello World
```

`openssl` 从标准输入读取数据，并将结果打印到标准输出，因此可作为 filter。

```bash
# 设置 filter
git config filter.your_filter.clean "openssl enc -base64"
git config filter.your_filter.smudge "openssl enc -base64 -d"

# 添加文件
echo "Hello World" > main.xx 
git add main.xx .gitattributes
```

通过 `git add` 数据保存到暂存区，可看到差异被 base64 编码：

```diff
diff --git a/.gitattributes b/.gitattributes
new file mode 100644
index 0000000..89a19f1
--- /dev/null
+++ b/.gitattributes
@@ -0,0 +1 @@
+*.xx filter=your_filter
diff --git a/main.xx b/main.xx
new file mode 100644
index 0000000..5066d5a
--- /dev/null
+++ b/main.xx
@@ -0,0 +1 @@
+SGVsbG8gV29ybGQK
```

执行 `git commit`，数据进入版本库，通过 `git show HEAD:main.xx` 可看到版本库里保存的是 base64 编码后的内容。

删除 `main.xx` ，然后重新检出文件:

```bash
rm main.xx
git checkout main.xx
cat main.xx 
```

工作区的文件保存了解码后的内容。

## 参考

- http://git-scm.com/book/zh/v2/%E8%87%AA%E5%AE%9A%E4%B9%89-Git-Git-%E5%B1%9E%E6%80%A7
