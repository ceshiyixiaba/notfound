---
title: "Ubuntu 20.04 系统安装记录"
date: 2021-10-14T10:01:00+08:00
tags: ["linux"]
draft: false
---

安装时选择语言为英文，以创建英文目录。

## 卸载 avahi-daemon 服务

`avahi-daemon` 造成过网络异常，用处也不大，卸载：

```bash
sudo apt purge avahi-daemon
```

## 安装 GNOME 扩展

```bash
sudo apt install gnome-shell-extensions
```

参考 <https://www.fosslinux.com/44375/install-gnome-tweak-tool-ubuntu.htm>

### 自动隐藏顶部栏

安装 GNOME 插件 <https://extensions.gnome.org/extension/545/hide-top-bar>

参考: <https://zhuanlan.zhihu.com/p/139305626>

## Chrome 开启 wayland

编辑 `/usr/share/applications/google-chrome.desktop`:

```conf
Exec=/usr/bin/google-chrome-stable --enable-features=UseOzonePlatform --ozone-platform=wayland %U
```
- 添加 `--enable-features=UseOzonePlatform` 和 `--ozone-platform=wayland` 可解决浏览器字体模糊

参考 <https://pychao.com/2021/01/04/using-google-chrome-chromium-with-native-wayland-backend-in-arch-linux/>

## 登陆窗口分辨率

将当前用户配置复制到 gdm 用户目录:

```bash
sudo cp ~/.config/monitors.xml ~gdm/.config/monitors.xml
sudo chown gdm:gdm ~gdm/.config/monitors.xml
```

编辑 `/etc/gdm3/custom.conf`:

```toml
WaylandEnable=false
```
- 关闭了 wayland 和上一条冲突

参考 <https://albertomatus.com/changing-login-display-in-ubuntu-20-04/>

## Git & Vim

安装：

```bash
sudo apt install git vim
```

配置 Git：

```bash
git config --global user.name $NAME
git config --global user.email $EMAIL

git config --global credential.helper cache
git config --global core.editor vim
git config --global core.quotepath false
git config --global diff.tool vimdiff
git config --global difftool.prompt no
git config --global grep.lineNumber true
```

## oh-my-zsh

```bash
sudo apt install zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

编辑 `~/.zshrc` ，添加 `git` `emacs` `docker` `kubectl` 等。

## Emacs & Spacemacs

### 安装 Emacs

通过 ppa 下载 Emacs 最新版，下载速度太慢，所以启用代理：

```bash
sudo add-apt-repository ppa:kelleyk/emacs
sudo apt install emacs27
```

### 安装配置 Spacemacs

使用 Spacemacs develop 分支：

```bash
git clone -b develop https://github.com/syl20bnr/spacemacs ~/.emacs.d
```

使用 spacemacs 自定义配置，然后拉取 org 文档：


设置图标和环境变量(解决输入法切换)：

```bash
sudo vim /usr/share/applications/emacs27.desktop

Icon=/home/notfound/.emacs.d/core/banners/img/spacemacs.png
Exec=env LC_ALL=zh_CN.UTF-8 emacs %F
```

gtags 跳转：

```bash
sudo apt install global
sudo apt install exuberant-ctags python-pygments
gunzip /usr/share/doc/global/examples/gtags.conf.gz -c > ~/.globalrc
echo "export GTAGSLABEL=ctags" >> ~/.zshrc
```

ag 搜索：

```bash
sudo apt install silversearcher-ag
```

Hugo 安装 <https://github.com/gohugoio/hugo/releases>

```bash
wget https://github.com/gohugoio/hugo/releases/download/v0.89.2/hugo_extended_0.89.2_Linux-64bit.deb
sudo dpkg -i hugo_extended_0.89.2_Linux-64bit.deb
```

## 语言

通过图形界面设置语言为中文。

中文字体：

```bash
sudo apt install fonts-wqy-microhei fonts-wqy-zenhei
```

emoji：

```bash
sudo apt install fonts-noto-color-emoji
```

## 修改 DNS

```bash
sudo vim /etc/systemd/resolved.conf
sudo service systemd-resolved restart
systemd-resolve --status
```

[参考](https://askubuntu.com/questions/973017/wrong-nameserver-set-by-resolvconf-and-networkmanager)

## 其他

- `google-chrome` [下载](https://dl.google.com/linux/direct/google-chrome-stable%5Fcurrent%5Famd64.deb)
- `htop` 升级版 top
- `nginx`
- `openssh-server`
- `tree` 遍历目录下所有文件
- `nodejs` 参考[安装 NodeJS](https://github.com/nodesource/distributions/blob/master/README.md)
- `docker` 参考[安装 Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
