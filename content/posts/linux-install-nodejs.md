---
title: "Linux Install Nodejs"
date: 2022-01-12T11:38:56+08:00
tags: [""]
categories: [""]
draft: true
---

```bash
npm config set sass_binary_site https://npmmirror.com/mirrors/node-sass
SASS_BINARY_SITE=https://npmmirror.com/mirrors/node-sass/

npm set registry https://registry.npmmirror.com

tar -xvJf node-v12.22.9-linux-x64.tar.xz

sudo update-alternatives --install /usr/bin/node     node     /opt/node/bin/node     0
sudo update-alternatives --install /usr/bin/npm      npm      /opt/node/bin/npm      0
sudo update-alternatives --install /usr/bin/npx      npx      /opt/node/bin/npx      0
sudo update-alternatives --install /usr/bin/corepack corepack /opt/node/bin/corepack 0
```

## 参考
