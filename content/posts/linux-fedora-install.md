---
title: "Linux Fedora Install"
date: 2021-11-29T13:50:20+08:00
tags: [""]
categories: [""]
draft: true
---

mv /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora.repo.backup
mv /etc/yum.repos.d/fedora-updates.repo /etc/yum.repos.d/fedora-updates.repo.backup
wget -O /etc/yum.repos.d/fedora.repo http://mirrors.aliyun.com/repo/fedora.repo
wget -O /etc/yum.repos.d/fedora-updates.repo http://mirrors.aliyun.com/repo/fedora-updates.repo
yum makecache

dnf install git vim emacs java-11-openjdk-devel ruby
dnf install google-chrome-stable
# 调整字体
dnf install gnome-tweaks

# chsh zsh on-my-zsh
dnf install util-linux-user zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

https://get.cloudv2.net/osubscribe.php?sid=184521&token=wqBJbO1IUaNa

# 关闭动画
gsettings set org.gnome.desktop.interface enable-animations false

# spacemacs
git clone -b develop https://github.com/syl20bnr/spacemacs ~/.emacs.d

# vim


# postgresql
sudo postgresql-setup --initdb
systemctl start postgresql.service
rpm -ql postgresql-server

# psql: 错误: 致命错误:  用户 "example" Ident 认证失败
sudo vim /var/lib/pgsql/data/pg_hba.conf

# ag
sudo dnf install the_silver_searcher
## 参考
