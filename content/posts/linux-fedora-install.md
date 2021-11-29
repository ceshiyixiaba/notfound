---
title: "Linux Fedora Install"
date: 2021-11-29T13:50:20+08:00
tags: ["linux"]
categories: [""]
draft: true
---

## docker

```bash
sudo setsebool -P httpd_can_network_connect 1
```

- https://stackoverflow.com/questions/23948527/13-permission-denied-while-connecting-to-upstreamnginx
- https://docs.docker.com/engine/reference/commandline/run/#mount-volumes-from-container---volumes-from
- https://stackoverflow.com/questions/24288616/permission-denied-on-accessing-host-directory-in-docker

### Git

```bash
sudo dnf install git vim ruby
sudo dnf install docker
```

```bash
sudo mv /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora.repo.backup
sudo mv /etc/yum.repos.d/fedora-updates.repo /etc/yum.repos.d/fedora-updates.repo.backup
sudo wget -O /etc/yum.repos.d/fedora.repo http://mirrors.aliyun.com/repo/fedora.repo
sudo wget -O /etc/yum.repos.d/fedora-updates.repo http://mirrors.aliyun.com/repo/fedora-updates.repo

sudo dnf makecache
```

## on-my-zsh

```bash
dnf install util-linux-user zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## vim

```
sudo dnf install vim
git clone --depth=1 git://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh
```

## emacs

```bash
sudo dnf install emacs-nox the_silver_searcher 
git clone -b develop git://github.com/syl20bnr/spacemacs ~/.emacs.d
```

## PostgreSQL

```bash
sudo postgresql-setup --initdb
systemctl start postgresql.service
rpm -ql postgresql-server

# psql: 错误: 致命错误:  用户 "example" Ident 认证失败
sudo vim /var/lib/pgsql/data/pg_hba.conf
```

## mount

```
sudo lsblk -f
vim /etc/fstab
systemctl daemon-reload
```
- https://linuxhint.com/uuid_storage_devices_linux/

## 桌面

### 调整字体

```bash
sudo dnf install gnome-tweaks
```

### 关闭动画

```bash
gsettings set org.gnome.desktop.interface enable-animations false
```

## Nginx

```bash
setsebool -P httpd_can_network_connect 1
sudo chcon -v -R --type=httpd_sys_content_t /path/to/www/
```

- https://stackoverflow.com/questions/6795350/nginx-403-forbidden-for-all-files
- https://stackoverflow.com/questions/23948527/13-permission-denied-while-connecting-to-upstreamnginx

## vscode

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

dnf check-update
sudo dnf install code
```
- https://code.visualstudio.com/docs/setup/linux
## 参考
