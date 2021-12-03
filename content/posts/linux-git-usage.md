---
title: "Linux 安装配置 Git"
date: 2018-03-20T23:30:00+08:00
tags: ["git"]
---

## 安装

```bash
# Ubuntu
sudo apt install git

# Fedora
sudo dnf install git
```

## 配置 ssh key

```bash
ssh-keygen -t ed25519 -C "username@example.com"
```
- `-t` 密钥类型 ed25519
- `-C` 注释字段为邮箱地址，可随意填写或不填

## 配置用户名、邮箱

```bash
git config --global user.name $USERNAME
git config --global user.email $EMAIL
```

## 配置其他

```bash
# 编辑器 vim
git config --global core.editor vim

# git log 使用的时区
git config --global log.date local

# diff 工具为 vimdiff，执行 `git difftool` 时调用
git config --global diff.tool vimdiff
# 启动 diff 工具时不提示工具信息
git config --global difftool.prompt no

# 设置 https 密码保存
#   `cache` 码保存到内存中，15分钟后删除
#   `store` 将密码用 **明文** 的形式存放在磁盘中，Linux 环境位置为 `~/.git-credentials`
git config --global credential.helper cache

# 执行 `git grep` 命令时显示行号
git config --global grep.lineNumber true

# git status 中文编码
git config --global core.quotepath false

# 设置 HTTP 代理
git config --global http."https://github.com/".proxy http://127.0.0.1:8118

# git://github.com 代替 https://github.com
git config --global url."git://github.com".insteadOf https://github.com
```

## 允许普通仓库推送代码

```bash
git config --local receive.denyCurrentBranch updateInstead
```

## linguist 语言分析

```bash
gem install github-linguist
git linguist stats --commit=98164e9585e02e31dcf1377a553efe076c15f8c6
```
- `git linguist` 命令实际会执行 `git-linguist`

## 删除所有 remote 分支

```bash
git for-each-ref "refs/remotes/**" --format="%(refname:lstrip=2)" | xargs git branch -d -r
```

## 调试

```bash
GIT_TRACE=1 git log
```

- `man git` 可看其他环境变量

## 获取远程默认分支

```bash
git ls-remote --symref origin HEAD
```
## 其他

- 全局配置文件位置 `~/.gitconfig`
- 项目配置 `.git/config`

## 参考

- https://stackoverflow.com/questions/28666357/git-how-to-get-default-branch
