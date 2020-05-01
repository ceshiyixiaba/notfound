+++
title = "Manjaro 安装记录"
author = ["likui"]
date = 2021-03-20T13:00:00+08:00
lastmod = 2021-04-10T09:00:53+08:00
tags = ["linux", "tool"]
draft = false
+++

## 安装 manjaro {#安装-manjaro}


### 添加源 {#添加源}

编辑文件 `/etc/pacman.d/mirrorlist` ：

```conf
Server = https://mirrors.tuna.tsinghua.edu.cn/manjaro/stable/$repo/$arch
```

Arch Linux 中文社区仓库是由 Arch Linux 中文社区驱动的非官方用户仓库，包含中文用户常用软件、工具、字体/美化包等。编辑文件 `/etc/pacman.conf` ：

```conf
[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
```


### 手动安装 AUR 包 {#手动安装-aur-包}

如 安装 dingtalk

```bash
git clone https://aur.archlinux.org/dingtalk-linux.git
cd dingtalk-linux
makepkg -si
```


### 使用 yay 安装 aur 包 {#使用-yay-安装-aur-包}

安装 yay

```bash
sudo pacman -Sy yay
```

之后可以通过 yay 安装 aur 中的软件，如:

```bash
# 安装软件
yay -S packagename
# 移除包
yay -R packagename
# 移除包以及不需要的依赖
yay -Rns packagename
# 移除不需要的软件包
yay -Yc
```


### 版本回退 {#版本回退}

安装包保存在 `/var/cache/pacman/pkg` 目录中，通过如下命令安装老版本：

```bash
sudo pacman -U /var/cache/pacman/pkg/redis-6.0.10-1-x86_64.pkg.tar.zst
```

编辑文件 `/etc/pacman.conf` 忽略 `redis` 更新：

```conf
# [options] 节点
IgnorePkg=redis
```


### 密码错误锁定 {#密码错误锁定}

编辑文件 `/etc/security/faillock.conf`

-   `deny` 尝试次数
-   `unlock_time` 锁定时间


### Windows 字体 {#windows-字体}

复制 Windows 字体，之后可以将 UI 字体改成微软雅黑：

```bash
sudo mkdir /usr/share/fonts/WindowsFonts
sudo cp /run/media/likui/Windows/Windows/Fonts/* /usr/share/fonts/WindowsFonts
sudo chmod 755 /usr/share/fonts/WindowsFonts/*
sudo fc-cache -f
```

终端字体 `Cascadia Code`

```bash
sudo pacman -Sy ttf-cascadia-code
```


### pacman 常用命令 {#pacman-常用命令}

```bash
# 远程数据库中查询软件包
pacman -Ss gimp
# 本地数据库与远程数据库同步、升级所有软件包
sudo pacman -Syu
# 在本地数据库中查看软件包中的内容
pacman -Ql protobuf
# 删除未使用的依赖
sudo pacman -Rs $(pacman -Qdtq)
```


### xclip {#xclip}

剪切板工具。

```bash
# 复制文件
xclip -selection clipboard test.txt
# 复制管道
uptime | xclip -selection clipboard
# 输出
xclip -o
xclip -o > out.txt
```


### KDE wallet (KDE 钱包) {#kde-wallet--kde-钱包}

凭据管理器。

```bash
# 保存密码
kwallet-query -f test -w notfound kdewallet
# 读取密码
kwallet-query -f test -r notfound kdewallet
# 读取并复制，末尾会有换行符
kwallet-query -f test -r notfound kdewallet | xclip -selection clipboard
```

-   `-f test` 指定 kwallet 文件夹 `test`
-   `-r notfound` 读取 `notfound` entry
-   `-w notfound` 写入 `notfound` entry
-   `wallet` wallet 名称


### 参考 {#参考}

-   <https://www.makeuseof.com/how-to-install-and-remove-packages-arch-linux>
-   <https://mirrors.tuna.tsinghua.edu.cn/help/archlinuxcn/>
-   <https://zhuanlan.zhihu.com/p/114904008>
-   <https://wiki.archlinux.org/index.php/Pacman%5F(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>
-   <https://blog.csdn.net/qq%5F37284020/article/details/112206977>
-   <https://wiki.archlinux.org/index.php/Microsoft%5Ffonts%5F(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>
-   <https://sleeplessbeastie.eu/2012/08/12/git-how-to-avoid-typing-your-password-repeatedly/>
-   <https://wiki.archlinux.org/index.php/KDE%5FWallet>
-   <https://wiki.archlinux.org/index.php/Clipboard>
