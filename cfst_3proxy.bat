:: --------------------------------------------------------------
::	项目: CloudflareSpeedTest 自动更新 3Proxy
::	版本: 1.0.1
::	作者: XIU2
::	项目: https://github.com/XIU2/CloudflareSpeedTest
:: --------------------------------------------------------------
@echo off
Setlocal Enabledelayedexpansion

::判断是否已获得管理员权限

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" 

if '%errorlevel%' NEQ '0' (  
    goto UACPrompt  
) else ( goto gotAdmin )  

::写出 vbs 脚本以管理员身份运行本脚本（bat）

:UACPrompt  
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs" 
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs" 
    "%temp%\getadmin.vbs" 
    exit /B  

::如果临时 vbs 脚本存在，则删除
  
:gotAdmin  
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )  
    pushd "%CD%" 
    CD /D "%~dp0" 


::上面是判断是否以获得管理员权限，如果没有就去获取，下面才是本脚本主要代码


::如果 nowip.txt 文件不存在，说明是第一次运行该脚本
if not exist "nowip_3proxy.txt" (
    echo 该脚本的作用为 CloudflareST 测速后获取最快 IP 并替换 3Proxy 配置文件中的 Cloudflare CDN IP。
    echo 可以把所有 Cloudflare CDN IP 都重定向至最快 IP，实现一劳永逸的加速所有使用 Cloudflare CDN 的网站（不需要一个个添加域名到 Hosts 了）。
    echo 使用前请先阅读：https://github.com/XIU2/CloudflareSpeedTest/discussions/71
    echo.
    set /p nowip="输入当前 3Proxy 正在使用的 Cloudflare CDN IP 并回车（后续不再需要该步骤）:"
    echo !nowip!>nowip_3proxy.txt
    echo.
)  

::从 nowip_3proxy.txt 文件获取当前使用的 Cloudflare CDN IP
set /p nowip=<nowip_3proxy.txt
echo 开始测速...



:: 这里可以自己添加、修改 CloudflareST 的运行参数，默认的 -p 0 是为了避免测速完需要 回车键 才能继续的问题
CloudflareST.exe -p 0



for /f "tokens=1 delims=," %%i in (result.csv) do (
    set /a n+=1 
    If !n!==2 (
        set bestip=%%i
        goto :END
    )
)
:END
echo %bestip%>nowip_3proxy.txt
echo.
echo 旧 IP 为 %nowip%
echo 新 IP 为 %bestip%



:: 请将引号内的 D:\Program Files\3Proxy 改为你的 3Proxy 程序所在目录
CD /d "D:\Program Files\3Proxy"
:: 请确保运行该脚本前，已经测试过 3Proxy 可以正常运行并使用！



echo.
echo 开始备份 3proxy.cfg 文件（3proxy.cfg_backup）...
copy 3proxy.cfg 3proxy.cfg_backup
echo.
echo 开始替换...
(
    for /f "tokens=*" %%i in (3proxy.cfg_backup) do (
        set s=%%i
        set s=!s:%nowip%=%bestip%!
        echo !s!
        )
)>3proxy.cfg

net stop 3proxy
net start 3proxy

echo 完成...
echo.
pause 