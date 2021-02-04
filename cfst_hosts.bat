:: --------------------------------------------------------------
::	项目: CloudflareSpeedTest 自动更新 Hosts
::	版本: 1.0.0
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
if not exist "nowip.txt" (
    echo 该脚本的作用为 CloudflareST 测速后获取最快 IP 并替换 Hosts 中的 Cloudflare CDN IP。
    echo 使用前请先阅读：https://github.com/XIU2/CloudflareSpeedTest/issues/42#issuecomment-768273768
    echo.
    echo 第一次使用，请先将 Hosts 中所有 Cloudflare CDN IP 统一改为一个 IP。
    set /p nowip="输入该 Cloudflare CDN IP 并回车（后续不再需要该步骤）:"
    echo !nowip!>nowip.txt
    echo.
)  

::从 nowip.txt 文件获取当前 Hosts 中使用的 Cloudflare CDN IP
set /p nowip=<nowip.txt
echo 开始测速...
CloudflareST.exe -p 0
for /f "tokens=1 delims=," %%i in (result.csv) do (
    SET /a n+=1 
    If !n!==2 (
        SET bestip=%%i
        goto :END
    )
)
:END
echo %bestip%>nowip.txt
echo.
echo 旧 IP 为 %nowip%
echo 新 IP 为 %bestip%
C:
CD "C:\Windows\System32\drivers\etc"
echo.
echo 开始备份 Hosts 文件（hosts_backup）...
copy hosts hosts_backup
echo.
echo 开始替换...
(
    for /f "tokens=*" %%i in (hosts_backup) do (
        set s=%%i
        set s=!s:%nowip%=%bestip%!
        echo !s!
        )
)>hosts
echo 完成...
echo.
pause 