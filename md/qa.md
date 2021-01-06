### \# 脚本运行出现错误了怎么办？

不要慌，先去 **[Github Issues](https://github.com/XIU2/Shell/issues)** 中看看是否已经有其他人出现过**类似问题**了（记得看看 [Closed](https://github.com/XIU2/Shell/issues?q=is%3Aissue+is%3Aclosed) 的）。  

如果没有类似问题，请发个 **[Issues](https://github.com/XIU2/Shell/issues/new?assignees=&labels=&template=--bug.md&title=%5BBUG%2Fxxx.sh%5D+-+%E4%B8%80%E5%8F%A5%E8%AF%9D%E8%AF%B4%E6%98%8E%E6%83%85%E5%86%B5)** 告诉我，越详细越好（有截图更好）！

****

### \# 下载脚本时报错 wget: command not found

这个是因为你的 Linux 系统太过于精简，缺少基本的下载工具 wget，装个就好了。

#### CentOS 系统：

```bash
yum update
yum install wget -y
```

#### Debian/Ubuntu 系统：

```bash
apt-get update
apt-get install wget -y

# 如果你是较新版本的系统，可以把命令中的 apt-get 替换为 apt（新版包管理器）
```

如果没有报错，说明安装成功，继续下载安装脚本即可。

****

?> 稍后补充