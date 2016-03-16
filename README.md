# Weibo login plugin for Discourse / Discourse 微博登录插件

<strong>将随 Discourse 1.5 正式版被[集合插件](https://github.com/fantasticfears/discourse-chinese-localization-pack) 取代。Discourse 1.6 正式版后该插件会被删除。</strong>

Authenticate with discourse with Weibo.

通过微博登录 Discourse。

## Register Client Key & Secert / 申请微博接入

1. 登录[微博开发者中心](http://open.weibo.com/connect?bottomnav=1&wvr=5)，注册填写相关信息。
2. 点击`开始接入`。
3. 填写相关信息。`网站域名`可填写根域名或者具体域名。如图所示。（验证所需要的标签可在 Discourse 设置中插入，验证后即可删除；访问 Discourse 管理面板 - 内容 - 页面顶部）
4. 在申请到的后台找到`网站信息`的`基本信息`一栏，获得`key`和`secret`，将其填入Discourse 设置中。

<img src="https://meta.discourse.org/uploads/default/34524/32ac2f59e766ca9f.png" width="527" height="500">

## Installation / 安装

在 `app.yml` 的

    hooks:
      after_code:
        - exec:
            cd: $home/plugins
            cmd:
              - mkdir -p plugins
              - git clone https://github.com/discourse/docker_manager.git

最后一行 `- git clone https://github.com/discourse/docker_manager.git` 后添加：

    - git clone https://github.com/fantasticfears/weibo-login.git

## Usage / 使用

Go to Site Settings's login category, fill in the client id and client secret.

进入站点设置的登录分类，填写 client id 和 client serect。

## Issue / 问题

Visit [topic on Discourse Meta](https://meta.discourse.org/t/weibo-login-plugin/19735) or [GitHub Issues](https://github.com/fantasticfears/weibo-login/issues).

访问[中文论坛的主题](https://meta.discoursecn.org/t/topic/43)或[GitHub Issues](https://github.com/fantasticfears/weibo-login/issues)。

## Changelog

Current version: 0.4.1

0.3.0: 修正没有正确保存 uid 的 bug。
0.4.0: 包含登录策略 gem，去掉下载外部 gem 的步骤。
0.4.1: 限制保存的内容，解决 CookieOverflow 的问题。
