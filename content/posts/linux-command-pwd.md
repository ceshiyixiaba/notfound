---
title: "Linux Command Pwd"
date: 2022-01-06T11:52:26+08:00
tags: [""]
categories: [""]
draft: true
---

```bash
pwdx <PID>
```

```bash
lsof -p <PID> | grep cwd
```

```bash
readlink -e /proc/<PID>/cwd
```

## 参考

- https://unix.stackexchange.com/questions/94357/find-out-current-working-directory-of-a-running-process
