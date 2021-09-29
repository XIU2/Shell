# 📑 cfst_hosts.sh / cfst_hosts.bat

## 脚本介绍

- 该脚本需要搭配 [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) 项目使用。  
_🌩 测试 Cloudflare CDN 延迟和速度，获取最快 IP (IPv4+IPv6)！_

****

很多人在获得最快 Cloudflare CDN IP 后，需要替换 Hosts 文件中的 IP，使用该脚本会方便很多！

?> ***下载安装/使用说明：https://github.com/XIU2/CloudflareSpeedTest/issues/42***

****

## 更新日志

#### 2021年09月29日，版本 v1.0.2 :id=102
 - **1. 修复** 当测速结果 IP 数量为 0 时，脚本没有退出的问题。  

#### 2021年04月29日，版本 v1.0.1 :id=101
 - **1. 优化** 不再需要加上 -p 0 参数来避免回车键退出了（现在可以即显示结果，又不用担心回车键退出程序）。  

#### 2021年01月28日，版本 v1.0.0 :id=100
 - **1. 发布** 第一个版本。  