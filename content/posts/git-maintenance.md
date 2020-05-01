+++
title = "Git Maintenance"
author = ["likui"]
date = 2021-04-23T20:00:00+08:00
lastmod = 2021-04-23T20:38:14+08:00
tags = ["git"]
draft = false
+++

## git maintenance {#git-maintenance}

通过 `git maintenance` 命令，可以对 Git 仓库定期维护。该命令包括一系列的子命令。

在 Linux 环境中，是通过 `cron` 执行定时任务。


### register {#register}

将当前 Git 仓库添加到仓库维护列表中。

```bash
git maintenance register
```

-   修改当前仓库配置文件，添加 `maintenance.auto` 和 `maintenance.strategy`
-   修改用户全局配置文件 `~/.gitconfig` ，将当前仓库绝对路径添加到 `maintenance.repo` 节点


### run {#run}

执行 Git 仓库维护任务。

```bash
git maintenance run
```

-   执行维护任务
-   可以通过参数 `--task` 指定任务

<!--listend-->

```bash
git maintenance run --task gc
```

task 参数如下：

-   `commit-graph` 增量更新 `commit-graph`
-   `prefetch` 从所有 remote 拉取分支，分支信息保存到 `refs/prefetch/<remote>/` ，不会拉取 tag
-   `gc` 执行 git gc
-   `loose-objects` 将松散对象 `loose objects` 打包，文件名以 `loose-` 开头，不建议和 gc 同时开启
-   `incremental-repack` 重新打包文件
-   `pack-refs` 将松散的 refs 打包到单个文件


### start {#start}

添加定时任务，并将当前 Git 仓库添加到仓库维护列表中。

```bash
git maintenance start
```

-   更新配置文件，与 `register` 命令相同
-   添加 cron 定时任务，通过 `crontab -l` 可以看到定时任务的具体信息

<!--listend-->

```crontabs
# BEGIN GIT MAINTENANCE SCHEDULE
# The following schedule was created by Git
# Any edits made in this region might be
# replaced in the future by a Git command.

0 1-23 * * * "/usr/lib/git-core/git" --exec-path="/usr/lib/git-core" for-each-repo --config=maintenance.repo maintenance run --schedule=hourly
0 0 * * 1-6 "/usr/lib/git-core/git" --exec-path="/usr/lib/git-core" for-each-repo --config=maintenance.repo maintenance run --schedule=daily
0 0 * * 0 "/usr/lib/git-core/git" --exec-path="/usr/lib/git-core" for-each-repo --config=maintenance.repo maintenance run --schedule=weekly

# END GIT MAINTENANCE SCHEDULE
```

也就是通过 `cron` 定时执行如下命令：

```bash
git for-each-repo --config=maintenance.repo maintenance run --schedule=hourly
git for-each-repo --config=maintenance.repo maintenance run --schedule=daily
git for-each-repo --config=maintenance.repo maintenance run --schedule=weekly
```

-   遍历 `--config=maintenance.repo` 中的仓库列表，执行 `git maintenance run` 命令

在  `incremental` 策略下，执行的任务如下：

-   gc: disabled
-   commit-graph: hourly
-   prefetch: hourly
-   loose-objects: daily
-   incremental-repack: daily


### stop {#stop}

移除定时任务。

```bash
git maintenance stop
```

-   移除定时任务，但不会将当前仓库从 `maintenance.repo` 移除


### unregister {#unregister}

将当前 Git 仓库从仓库维护列表中移除。

```bash
git maintenance unregister
```

-   将当前仓库从 `maintenance.repo` 移除


### 仓库列表管理 {#仓库列表管理}

可以通过 `git config` 批量添加或删除：

```bash
# 添加 Git 仓库维护列表，绝对路径
git config --global --add maintenance.repo /home/git/docs.git
git config --global --add maintenance.repo /home/git/study.git

# 查看 Git 仓库维护列表
git config --global --get-all maintenance.repo
# 清空 Git 仓库维护列表
git config --global --unset-all maintenance.repo
```

-   与 `git maintenance register` 不同的是，重复执行会重复添加


### 参考 {#参考}

-   `git help maintenance`
-   <https://stackoverflow.com/questions/5101485/is-there-any-way-to-list-up-git-repositories-in-terminal>
