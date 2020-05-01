+++
title = "Ubuntu 安装配置 Spacemacs"
author = ["notfound"]
date = 2018-12-08T13:31:00+08:00
tags = ["emacs"]
draft = false
+++

## 安装 Emacs 26

Ubuntu 16.04 和 18.04 Emacs 版本都低于 26，可通过 ppa 安装最新的 Emacs 26.x：

```shell
sudo add-apt-repository ppa:kelleyk/emacs
sudo apt-get update
sudo apt-get install emacs26
```

## 安装 Spacemacs

[spacemacs](https://github.com/syl20bnr/spacemacs) master 更新太慢，使用 develop 分支。

```shell
git clone -b develop https://github.com/syl20bnr/spacemacs ~/.emacs.d
```

启动 emacs，首次启动会有两个选项，直接回车选择默认值即可，之后会下载依赖，并自动生成配置文件 `~/.spacemacs` 。

创建目录 `.spacemacs.d` 用来存放自定义配置，可使用 git 等工具进行同步和版本控制。 [文件加载顺序说明](https://github.com/syl20bnr/spacemacs/blob/develop/doc/QUICK%5FSTART.org#dotdirectory-spacemacsd)

```shell
mkdir ~/.spacemacs.d
mv ~/.spacemacs ~/.spacemacs.d/init.el
```

## 配置

可通过 `SPC f e d` 快速打开配置文件。


### 图标

编辑 `/usr/share/applications/emacs26.desktop` [参考](https://askubuntu.com/questions/726351/use-desktop-icon-for-running-application) ：

```shell
StartupWMClass=Emacs26
Icon=/home/notfound/.emacs.d/core/banners/img/spacemacs.png
```

### 源

国外源下载速度慢，添加 [国内的源](https://mirrors.cloud.tencent.com/help/elpa.html) 。在 `dotspacemacs/user-init` 中添加：

```emacs-lisp
(setq configuration-layer-elpa-archives
      '(("melpa-cn" . "http://mirrors.cloud.tencent.com/elpa/melpa/")
        ("org-cn"   . "http://mirrors.cloud.tencent.com/elpa/org/")
        ("gnu-cn"   . "http://mirrors.cloud.tencent.com/elpa/gnu/")))
```

### 复制粘贴

emacs 会拦截鼠标事件，点击鼠标右键没菜单， `Ctrl+c` 也无法使用。

layer `xclipboard` 可以通过 `SPC x p` 粘贴， `SPC x y` 复制。 [参考](https://github.com/syl20bnr/spacemacs/tree/develop/layers/+tools/xclipboard)

在终端模式复制粘贴，在 `dotspacemacs/user-config` 中添加：

```emacs-lisp
(xterm-mouse-mode -1)
```

终端中，可通过 `Ctrl Shift c` 复制， `Ctrl Shift v` 粘贴，但在复制时行末尾的空白会变成多余的空格。 [参考](https://www.reddit.com/r/spacemacs/comments/7ax52t/how%5Fto%5Fcopypaste%5Ffrom%5Fthe%5Fhost%5Fclipboard%5Fin)


### 搜索

传说 `ag` 比 `grep` 快，所以安装 `ag` 。

```shell
sudo apt install silversearcher-ag
```

默认搜索工具使用顺序为 `rg` > `ag` > `pt` > `ack` > `grep` ，所以安装 `ag` 后就不会使用 `grep` 。

#### 文件过滤

搜索时可能需要过滤掉某些文件，默认情况下会使用 `.gitignore` 和 `.hgignore` 。

可在项目或者 home 目录下添加文件 `.agignore` （或 `.ignore` 2.0.0+ ）。 [参考](https://github.com/ggreer/the%5Fsilver%5Fsearcher/wiki/Advanced-Usage)


#### 按键

- `SPC *` 或 `SPC s P` 搜索当前光标位置的值
- `SPC /` 或 `SPC s p` 搜索
- `SPC s a p` 使用 `ag` 搜索当前项目下的文件
- `SPC r s` 唤醒上次搜索 buffer

### 跳转

添加 [gtags](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Btags/gtags) layer。

#### 安装

```shell
sudo apt install global
sudo apt install exuberant-ctags python-pygments
```

#### 配置

使用 ctags 生成标签，可添加环境变量：

```shell
export GTAGSLABEL=ctags
```

如果需要自定义忽略的文件和目录，可通过 `~/.globalrc` 进行配置（文件内搜索 `skip` ）:

- Ubuntu 16.04: `vim /usr/share/doc/global/examples/gtags.conf.gz` 然后 `:w ~/.globalrc`
- Ubuntu 18.04: `cp /usr/share/doc/global/examples/gtags.conf ~/.globalrc`
- `gtags.conf` 跨版本的配置可能不兼容，会出现错误

#### 按键

- `SPC p g` 或 `SPC m g C` 生成 tag
- `SPC p g` 查找 tag

tags 信息保存在 `GPATH` 、 `GRTAGS` 、 `GTAGS` 三个文件中，需要在版本控制中忽略这三个文件。

### 其他常用 layers

- [git](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Bsource-control/git) 使用了 [magit](https://magit.vc/)
- [version-control](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Bsource-control/version-control) 可用来显示文件变更
- [restclient](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Btools/restclient) 可用来发送 http 请求
- [auto-completion](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Bcompletion/auto-completion) 自动补全
- [org](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Bemacs/org) org-mode 功能强大
- [asciidoc](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Blang/asciidoc)
- [markdown](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Blang/markdown)
- [yaml](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Blang/yaml)
- [sql](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Blang/sql)
- [html](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Blang/html)
- [javascript](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Blang/javascript)
- [json](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Blang/json)
- [ruby](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Blang/ruby)
- [ruby-on-rails](https://github.com/syl20bnr/spacemacs/tree/develop/layers/%2Bframeworks/ruby-on-rails)

### 其他

- [projectile](https://github.com/bbatsov/projectile) 项目管理
