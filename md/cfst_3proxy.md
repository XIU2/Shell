# 📑 cfst_3proxy.bat

## 脚本介绍

- 该脚本需要搭配 [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) 项目使用。  
_🌩 测试 Cloudflare CDN 延迟和速度，获取最快 IP (IPv4+IPv6)！_

****

该脚本的作用为 CloudflareST 测速后获取最快 IP 并替换 3Proxy 配置文件中的 Cloudflare CDN IP。
可以把所有 Cloudflare CDN IP 都重定向至最快 IP，实现一劳永逸的加速所有使用 Cloudflare CDN 的网站（不需要一个个添加域名到 Hosts 了）。

?> ***下载安装/使用说明：https://github.com/XIU2/CloudflareSpeedTest/discussions/71***

****

## 更新日志

#### 2021年03月16日，版本 v1.0.1 :id=101
 - **1. 优化** 代码及注释内容。  

#### 2021年03月13日，版本 v1.0.0 :id=100
 - **1. 发布** 第一个版本。  