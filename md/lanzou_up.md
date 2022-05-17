# 📑 lanzou_up.sh

## 脚本介绍

很早之前，为了实现自动制作便携版并上传 qBittorret、qBittorretEE 到蓝奏云网盘，我就特地写了这个脚本来解决上传文件到蓝奏云网盘的问题。  

该脚本作用很简单，**自动登陆并上传文件到蓝奏云指定文件夹**，方便 Linux 系统使用 或 其他脚本调用。  

?> _[ **「油猴脚本」蓝奏云网盘增强！** 刷新不回根目录、后退返回上一级、右键文件显示菜单、自动显示更多文件、自动打开/复制分享链接、拖入文件自动显示上传框...](https://github.com/XIU2/UserScript#脚本列表)_  

### 脚本版本

**最新版本：** v1.0.3

### 系统要求

所有 Linux 系统均支持。

****

## 下载安装

先下载脚本并赋予执行权限，还不能运行，需要简单配置一下。

``` bash
wget -N --no-check-certificate https://shell.xiu2.xyz/lanzou_up.sh && chmod +x lanzou_up.sh
```

****

## 使用方法

### 账号配置

使用 vim 或 nano 来编辑脚本，下面以 nano 为例。  
``` bash
nano lanzou_up.sh

# 打开脚本文件后，可以看到脚本头部有以下三行内容。
# 修改 XXX 为你的蓝奏云用户名，并指定 Cookie (获取方法见下)。
# 然后按下 Ctrl+X 并回车两下即可保存。

USERNAME="XXX" # 蓝奏云用户名
COOKIE_PHPDISK_INFO="XXX" # 替换 XXX 为 Cookie 中 phpdisk_info 的值
COOKIE_YLOGIN="XXX" # 替换 XXX 为 Cookie 中 ylogin 的值
TOKEN="XXX" # 微信推送链接 Token，可选
```

> 脚本支持推送错误消息至微信，但是需要配置 TOKEN，支持 [PushPlus(默认)](http://pushplus.hxtrip.com)、[Server酱](https://sc.ftqq.com/3.version)，自行了解，不需要可留空或保留 XXX。  


### 获取Cookie

网页端登陆蓝奏云后，按 **F12** 键，然后如下图所示依次点击：*Application - Cookies - https://pc.woozooo.com*  
这样就能看到 Cookie 中的 *phpdisk_info(值就是那一大串字符)* 和 *ylogin(值就是那几位数字)* 了。  
双击值即可按 **Ctrl+C** 复制，然后将脚本头部对应变量的 *XXX* 替换即可。  

![蓝奏云获取文件夹ID](https://cdn.staticaly.com/gh/XIU2/Shell/master/img/lanzou_up-03.png)

****

再尝试上传文件前，你还需要知道 **文件夹 ID** 才行。  

### 获取文件夹ID

网页端登陆蓝奏云，找到目标文件夹，*右键文件夹名称 - 检查*。如下图所示，红框中的就是文件夹 ID *(880498)*。  

![蓝奏云获取文件夹ID](https://cdn.staticaly.com/gh/XIU2/Shell/master/img/lanzou_up-01.png)

### 上传文件

知道 文件夹 ID 了，那就先随便找个文件（注意文件后缀要满足蓝奏云要求，且文件不大于 100MB），然后就可以上传了：  

``` bash
# 格式：
bash lanzou_up.sh "文件名" "文件路径" "文件夹 ID"

# 示例
bash lanzou_up.sh "233.zip" "/root/233.zip" "880498"
```

****

## 更新日志
 
#### 2020年11月10日，版本 v1.0.3 :id=103
 - **1. 新增** 上传超时时间。  

#### 2020年11月09日，版本 v1.0.2 :id=102
 - **1. 新增** 提示信息时显示当前时间。  

#### 2020年09月10日，版本 v1.0.1 :id=101
 - **1. 移除** 用户名登陆方式。  
`刚发布没几天就发现用户名登陆方式失效了，所以现在只能用 Cookie 方式登陆了。`

#### 2020年09月06日，版本 v1.0.0 :id=100
 - **1. 发布** 第一个版本。
