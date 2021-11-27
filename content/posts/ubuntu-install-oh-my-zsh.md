---
title: "Ubuntu 安装配置 oh-my-zsh"
date: 2018-04-21T17:30:00+08:00
tags: ["linux", "tool"]
---

## 安装

**安装 zsh**

```shell
sudo apt install zsh
```

**将 zsh 设置为默认 shell**

```shell
chsh -s $(which zsh)
```

**安装 [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)**

```shell
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
```

## 配置

**配置 zsh plugins**

编辑 `~/.zshrc`

```shell
plugins=(rails git ruby)
```

**agnoster 主题乱码**

```shell
sudo apt-get install fonts-powerline
```

设置 `powerline` 字体即可

**配置 [emacs](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/emacs) plugins**

- `e` 或 `emacs` 启动 emacs 客户端窗口，ssh 或容器终端会闪退
- `te` 启动 emacs 客户端终端模式
