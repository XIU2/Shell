## 脚本介绍

该脚本基于 [Github - UnblockNeteaseMusic](UnblockNeteaseMusic) 项目。\
[UnblockNeteaseMusic](UnblockNeteaseMusic) 是一个专门针对网易云音乐解锁灰色无版权音乐的代理工具，通过替换经过代理的无版权音乐链接为其他音源（如：QQ音源、酷我、酷狗、百度音乐、咪咕、JOOX等）来实现解锁网易云音乐无版权音乐。\
**相当于在网易云音乐客户端中听全网版权音乐（相对）！**

### 脚本版本
**最新版本：** v1.0.0
### 系统要求
CentOS 6+ / Debian 6+ / Ubuntu 14.04 +

****

## 下载安装

> **注意：**因为涉及防火墙端口开关、服务脚本安装，所以脚本需要以 ROOT 用户执行。\
> 如果你不是 ROOT 用户，请执行下面这行代码切换为 ROOT 用户。\
> 如果你已经是 ROOT 用户了，那么请跳过下面这行代码！
```
sudo su
```
执行上面一行代码后会提示你输入当前用户的密码，回车后没有报错即可继续。

****

> 如果你要更新脚本，除了使用脚本中的 [0. 更新脚本] 功能以外，还可以再次输入下面这一行代码。
执行下面一行代码下载并运行脚本：
```
wget -N --no-check-certificate https://raw.githubusercontent.com/XIU2/SHELL/master/unblock163.sh && chmod +x unblock163.sh && bash unblock163.sh
```
下载运行后会提示你输入数字来选择要做什么。\
输入 **1** ，就会开始安装了，根据提示依次输入配置信息(或直接回车使用默认配置)即可。

```
 请输入数字 [0-10]:1
[信息] 开始设置 用户配置...
请输入要使用的代理端口。 [1-65535]
[注意] 如果你在本地通过 Hosts 方式使用该代理，那么只能选择 80 端口，其他方式不限制。
(默认: 80):

------------------------
	代理端口 :  80 
------------------------

请输入要使用的音源排序。 [qq kuwo kugou baidu xiami migu joox]
[注意] 音源排序指的是，无版权音乐会根据此处顺序优先匹配首位音源，如果匹配到就返回，反之就继续往后匹配。
[注意] 不同音源之间请用空格隔开。
(默认: qq migu kuwo kugou baidu):

------------------------
	音源排序 :  qq migu kuwo kugou baidu 
------------------------

是否启用严格模式？[Y/n]
[注意] 启用严格模式后，本代理仅允许网易云音乐域名访问，即本地设备只能通过 Host 或 PAC 使用，强烈建议开启，否则所有设备流量都会经过本代理。
(默认：Y [启用]):

------------------------
	严格模式 :  YES 
------------------------

[信息] 开始安装/配置 依赖...
[信息] 开始下载/安装...
...
```
如果安装过程没有出错，那么最后就会提示：
```
	UnblockNeteaseMusic 配置信息：
	------------------------
	本机地址	: X.X.X.X
	代理端口	: 80
	音源排序	: qq migu kuwo kugou baidu
	严格模式	: YES

	PAC 地址	: http://X.X.X.X:80/proxy.pac
```

****

## 使用方法
运行脚本
```
bash unblock163.sh
```
输入对应的数字来执行相应的命令。
```
  UnblockNeteaseMusic 一键脚本 [vX.X.X]
  
  0. 更新脚本
----------
  1. 安装 UnblockNeteaseMusic
  2. 更新 UnblockNeteaseMusic
  3. 卸载 UnblockNeteaseMusic
----------
  4. 启动 UnblockNeteaseMusic
  5. 停止 UnblockNeteaseMusic
  6. 重启 UnblockNeteaseMusic
----------
  7. 设置 配置信息
  8. 查看 账号信息
  9. 查看 日志信息
 10. 查看 链接信息

 当前状态: 已安装 并 已启动

 请输入数字 [0-10]:
 ```

****

### 文件位置
 - **安装目录：**/usr/local/UnblockNeteaseMusic
 - **日志文件：**/usr/local/UnblockNeteaseMusic/UnblockNeteaseMusic.log
 
 ****
 
### 其他命令
除了用脚本启动、停止、重启以外，还能通过其他命令操作。
 - **启动：**/etc/init.d/unblock163 start
 - **停止：**/etc/init.d/unblock163 stop
 - **重启：**/etc/init.d/unblock163 restart
 - **查看状态：**/etc/init.d/unblock163 status
 
 ****
 
## 注意事项

### 启动失败的可能原因

#### 1. 端口被占用
如果日志中显示以下内容，即说明端口被占用了。
```
HTTP Server running @ http://0.0.0.0:80
events.js:174
      throw er; // Unhandled 'error' event
      ^

Error: listen EADDRINUSE: address already in use 0.0.0.0:80
    at Server.setupListenHandle [as _listen2] (net.js:1279:14)
    at listenInCluster (net.js:1327:12)
    at doListen (net.js:1460:7)
    at process._tickCallback (internal/process/next_tick.js:63:19)
Emitted 'error' event at:
    at emitErrorNT (net.js:1306:8)
    at process._tickCallback (internal/process/next_tick.js:63:19)
```
请使用 `netstat -lntp | grep "端口"` 查看是被哪个程序占用了。\
例如提示如下内容，则可以使用 `kill -9 4725` 命令来结束该进程。当然，如果该程序不能关闭，你也可以选择换个代理端口。
```
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      4725/nginx
```

****

### 其他注意事项
暂无

****

## 更新日志
### 2019年08月31日，版本 v1.0.0
 - **1. 发布** 第一个版本。

