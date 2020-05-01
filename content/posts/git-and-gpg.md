+++
title = "Git 使用 GPG 进行签名"
author = ["notfound"]
date = 2019-02-16T22:43:00+08:00
tags = ["gpg", "git"]
draft = false
+++

本文仅介绍 Git 使用 GPG 进行签名，关于 GPG 参考 [GPG 使用](/posts/gpg-usage/)。

## 配置 Git {#配置-git}

配置 GPG 密钥。密钥 ID 可以为主密钥 ID 或者签名密钥 ID，签名时始终使用签名密钥 ID。

```shell
git config --global gpg.program gpg2 # Ubuntu 16.04 需要配置为 gpg2
git config --global user.signingkey E609071A680F01521759F2AD6845FD9F1A3352AF
git config --global tag.forceSignAnnotated true # 默认对标签进行签名
git config --global commit.gpgSign true # 默认对提交进行签名
```

## 签名 {#签名}

-   签名带注释的标签

    ```shell
    git tag -s [tagname]     # 添加签名
    git verify-tag [tagname] # 验证签名
    ```
-   签名提交

    ```shell
    git commit -S            # 添加签名
    git verify-commit [hash] # 验证提交
    git log --show-signature # 显示签名
    git merge --verify-signatures -S merged-branch # 合并时强制签名检查并对合并操作进行签名
    ```
-   Git 签名内容

    ```text
    $ git cat-file -p 8ea04ca8d1b471846446b4210a7fc785bdcb9bb2
    tree 5f565fa353070352457b964a28d40c4f18919e97
    parent 524c10cde6645753fe4580d8d73cd625c34bcd5c
    author notfound <notfound@notfound.cn> 1550324641 +0800
    committer notfound <notfound@notfound.cn> 1550324641 +0800
    gpgsig -----BEGIN PGP SIGNATURE-----

    iQEzBAABCgAdFiEEkc9pJPW9Ezra8LcruFeA+h3S9UsFAlxoE6EACgkQuFeA+h3S
    9UsDcAf9EBKDKmpHidpB39qhsoRIAYtiDvwESrh+n74sSt6HDEGtdbQU6ScABtdJ
    t0gUUcnu2/c6qjqaTXM/MtxJ08KLlQpExuJ9qIwUXEUrzLmVk3Dq7PiDl++Z2N5R
    GRGeOh9FSmeIJvQu2XFrFQHg0dyDrLrZCvpFe7GG3iJazqcAJbpzIvyBOYLKuSQn
    4UBNXlCM3jFsDurwsZpGVyDFPOPXtPoD5L85j7bF9rN1kUr4STlzm5TVeH94rNI5
    l6po3eUcGUguBKt4Ckx8PUlK2mWubv13WDTXOkqXd5u7VVnsgwzytLMhVcloZqs1
    g174BFXuWLFTkb4p0a7X15i86JjN8g==
    =Hie/
    -----END PGP SIGNATURE-----

    GPG test
    ```

    其中签名为(gpgsig.txt)：

    ```text
    -----BEGIN PGP SIGNATURE-----

    iQEzBAABCgAdFiEEkc9pJPW9Ezra8LcruFeA+h3S9UsFAlxoE6EACgkQuFeA+h3S
    9UsDcAf9EBKDKmpHidpB39qhsoRIAYtiDvwESrh+n74sSt6HDEGtdbQU6ScABtdJ
    t0gUUcnu2/c6qjqaTXM/MtxJ08KLlQpExuJ9qIwUXEUrzLmVk3Dq7PiDl++Z2N5R
    GRGeOh9FSmeIJvQu2XFrFQHg0dyDrLrZCvpFe7GG3iJazqcAJbpzIvyBOYLKuSQn
    4UBNXlCM3jFsDurwsZpGVyDFPOPXtPoD5L85j7bF9rN1kUr4STlzm5TVeH94rNI5
    l6po3eUcGUguBKt4Ckx8PUlK2mWubv13WDTXOkqXd5u7VVnsgwzytLMhVcloZqs1
    g174BFXuWLFTkb4p0a7X15i86JjN8g==
    =Hie/
    -----END PGP SIGNATURE-----
    ```

    被签名的文本为(commit.txt)：

    ```text
    tree 5f565fa353070352457b964a28d40c4f18919e97
    parent 524c10cde6645753fe4580d8d73cd625c34bcd5c
    author notfound <notfound@notfound.cn> 1550324641 +0800
    committer notfound <notfound@notfound.cn> 1550324641 +0800

    GPG test
    ```

    验证签名：

    ```text
    gpg --verify gpgsig.txt commit.txt
    ```


## GitHub GPG 公钥 {#github-gpg-公钥}

-   GPG 公钥包含的邮箱与用户已激活邮箱一致，GPG 公钥才能验证通过。
-   提交的 committer 邮箱包含在验证通过的 GPG 公钥中，提交才能验证通过。而本地使用 git 命令查看签名时只会验证签名是否有效，不会对邮箱进行验证。
