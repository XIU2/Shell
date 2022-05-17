# 📑 qb_p.sh

## 脚本介绍

本来是制作便携版给自己用的，后来一些人希望我分享出去，于是为了实现自动制作便携版并上传到蓝奏云网盘，我就特地写了这个脚本。  

该脚本作用很简单，**下载最新版本 qBittorrent 制作为便携版并上传到蓝奏云**，效果：[蓝奏云](https://pan.lanzouq.com/b073jjwta)。  

### 脚本版本

**最新版本：** v1.0.4

### 系统要求

所有 Linux 系统均支持。

****

## 下载安装

因为涉及到解压缩，而系统自带的 unzip 并不能解压 .exe ，所以需要额外安装 7z。  

``` bash
# CentOS 系统执行：
yum install p7zip-full -y

# Debian/Ubuntu 系统执行：
apt-get install p7zip-full -y
```

然后下载脚本并赋予执行权限，还不能运行，需要简单配置一下。  

``` bash
wget -N --no-check-certificate https://shell.xiu2.xyz/qb_p.sh && chmod +x qb_p.sh
```

****

## 使用方法

### 首次配置

使用 vim 或 nano 来编辑脚本，下面以 nano 为例。  
``` bash
nano qb_p.sh

# 打开脚本文件后，可以看到脚本头部有以下几行内容。
# 根据自己的情况修改后下面的变量内容。
# 然后按下 Ctrl+X 并回车两下即可保存。

FOLDER_ID="12345" # 蓝奏云网盘要上传文件的文件夹 ID
TOKEN="XXX" # 微信推送链接 Token，可选
FOLDER="/root/qBittorrent" # 脚本工作目录（下载、解压、压缩、上传等操作都在这个文件夹内），脚本会自动创建文件夹
LZY_PATH="/root/lanzou_up.sh" # 蓝奏云上传文件脚本位置
FILE_FORMAT="zip" # 最后打包的压缩包格式，推荐 zip 或 7z
```

?> 脚本支持推送错误消息至微信，但是需要配置 TOKEN，支持 [PushPlus(默认)](http://pushplus.hxtrip.com)、[Server酱](https://sc.ftqq.com/3.version)，自行了解，不需要可留空或保留 XXX。  
蓝奏云文件夹ID获取方法：[https://shell.xiu2.xyz/#/md/lanzou_up?id=获取文件夹ID](https://shell.xiu2.xyz/#/md/lanzou_up?id=%e8%8e%b7%e5%8f%96%e6%96%87%e4%bb%b6%e5%a4%b9id)  
蓝奏云上传文件脚本：[https://shell.xiu2.xyz/#/md/lanzou_up](https://shell.xiu2.xyz/#/md/lanzou_up)  

然后去 [蓝奏云](https://pan.lanzouq.com/b073jjwta) 下载一个最新版本，把压缩包内的 `profile` 文件夹放到服务器的 `qBittorrent/Other` 文件夹下（没有就新建，可以添加其他说明文件，就像我做的那样）。  

配置完毕后，就可以先试一试能不能正常使用了！  

### 使用示例

``` bash
# 格式：
bash qb_p.sh "指定版本号 (可选)"

# 示例，最新版本：
bash qb_p.sh
# 示例，指定版本：
bash qb_p.sh "4.2.3"
```

****

### 其他说明

如果不想上传到蓝奏云，可以注释掉脚本最后一行的 `_UPLOAD` 代码（行首加井号）。  

****

## 更新日志

#### 2022年01月07日，版本 v1.0.4 :id=104
 - **1. 修复** 下载失败一次后，后续下载都会失败的问题。  

#### 2020年10月24日，版本 v1.0.3 :id=103
 - **1. 修复** 压缩前没有添加便携配置文件的问题。  

#### 2020年09月10日，版本 v1.0.2 :id=102
 - **1. 修复** 最终压缩包文件名后缀前面少个点的问题（这就很尴尬了...）。  

#### 2020年09月06日，版本 v1.0.1 :id=101
 - **1. 新增** 自定义压缩包格式功能（详见[首次配置](#首次配置)）。  
 - **2. 更换** 默认压缩格式为 zip。  
 - **3. 优化** 最后打包为压缩包时的路径为相对路径。  

#### 2020年09月06日，版本 v1.0.0 :id=100
 - **1. 发布** 第一个版本。
