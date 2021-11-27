---
title: "使用 spacemacs 和 hugo 写博客"
date: 2018-12-23T10:18:00+08:00
tags: ["emacs", "linux"]
---

[Spacemacs org layer](https://github.com/syl20bnr/spacemacs/tree/develop/layers/+emacs/org#hugo-support) 提供了对 [Hugo](https://gohugo.io) 的支持。

工作过程：[ox-hugo](https://ox-hugo.scripter.co/) 把 org 文档转换为 Hugo markdown，Hugo 再将 markdown 转换为 html。

## Hugo

### 安装

```shell
sudo snap install hugo
sudo apt install python-pygments
```

### 搭建

使用 [Hyde](https://github.com/spf13/hyde) 主题

```shell
hugo new site notfound.cn
cd notfound.cn
git init
git add .
git submodule add https://github.com/spf13/hyde.git themes/hyde
```

### 配置

- 语法高亮 [Configure Syntax Highlighter](https://gohugo.io/content-management/syntax-highlighting/#configure-syntax-highlighter)

```toml
PygmentsCodeFences = true # Enable syntax highlighting with GitHub flavoured code fences
PygmentsUseClasses = true # Use CSS classes to format highlighted code
```

### 编译

```shell
hugo -s notfound.cn -d /var/www/notfound.cn
```

- `-s` 指定源目录
- `-d` 指定目标目录

本地实时预览：

```shell
hugo server -D
```

远程编译：

```shell
ssh -T notfound.cn hugo -s work/notfound.cn -d /var/www/notfound.cn
```

- 需要配置 ssh key
- 直接在服务上执行命令，省掉了登录的步骤

## Emacs hugo 配置

修改 spacemacs 配置，开启 org hugo 支持 [Hugo support](https://github.com/syl20bnr/spacemacs/tree/develop/layers/+emacs/org#hugo-support)

```emacs-lisp
(setq-default dotspacemacs-configuration-layers '(
  (org :variables
       org-enable-hugo-support t)))
```

### Org 文件配置

ox-hugo 支持两种导出方式。

#### 子节点树作为博客内容（推荐） {#子节点树作为博客内容-推荐}

将一个子节点树作为一篇博客，可参考 [One post per Org subtree (preferred)](https://ox-hugo.scripter.co/#screenshot-one-post-per-subtree)

博客文件目录结构：

```text
.
├── content
├── content-org
│   └── posts.org
...
```

- 所有博客内容都保存在 `posts.org` 文件中

在 `posts.org` 头部添加：

```text
#+HUGO_BASE_DIR: ../
#+HUGO_BASESECTION: ./
```

-   `#+HUGO_BASE_DIR:` Hugo 博客根目录设置为上级目录
-   `#+HUGO_BASESECTION:` Hugo section

在 `posts.org` 子节点添加：

```text
:PROPERTIES:
:EXPORT_FILE_NAME: ubuntu-emacs-and-hugo
:END:

#+HUGO: more
```

- `EXPORT_FILE_NAME` 指定导出的文件名
- `HUGO: more` 文件预览截断点，可参考 [Hugo Summary Splitter](https://ox-hugo.scripter.co/doc/hugo-summary-splitter/)
- 生成的文件会保存到 `HUGO_BASE_DIR/content/posts/ubuntu-emacs-and-hugo.md`

ox-hugo 导出时会使用 org 文件的部分信息，可参考 [For subtree-based exports](https://ox-hugo.scripter.co/doc/org-meta-data-to-hugo-front-matter/#for-subtree-based-exports)

```org
** DONE 使用 spacemacs 和 hugo 写博客        :emacs:hugo:
   CLOSED: [2018-12-23 Sun 10:18]
```

- `TODO` 为草稿， `DONE` 才会正式发布，没有状态的子节点不会自动转换
- org tags 会转换为 Hugo markdown 的 tags
- `CLOSED` 的时间点会转换为 Hugo markdown 的 date

#### Org 文件作为博客内容

可参考 [One post per Org file](https://ox-hugo.scripter.co/#screenshot-one-post-per-file)

### 保存后自动导出 [Auto-export on Saving](https://ox-hugo.scripter.co/doc/auto-export-on-saving) {#保存后自动导出-auto-export-on-saving}

- 目录下所有文件导出。在目录下创建文件 `.dir-locals.el` 并添加如下内容， `content-org` 目录下的文件都会被自动导出为 hugo markdown：

  ```emacs-lisp
  (("content-org/"
    . ((org-mode . ((eval . (org-hugo-auto-export-mode)))))))
  ```
- 单个文件自动导出

  ```org
  ​* Footnotes
  ​* COMMENT Local Variables                          :ARCHIVE:
  # Local Variables:
  # eval: (org-hugo-auto-export-mode)
  # End:
  ```
- 可配置单个文件不导出

  ```org
  ​* Footnotes
  ​* COMMENT Local Variables                          :ARCHIVE:
  # Local Variables:
  # eval: (org-hugo-auto-export-mode -1)
  # End:
  ```
