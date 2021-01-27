:: --------------------------------------------------------------
::	项目: CloudflareSpeedTest 自动更新域名解析记录
::	版本: 1.0.0
::	作者: XIU2
::	项目: https://github.com/XIU2/CloudflareSpeedTest
:: --------------------------------------------------------------
@echo off
Setlocal Enabledelayedexpansion
CloudflareST.exe -p 0
for /f "tokens=1 delims=," %%i in (result.csv) do (
    Set /a n+=1 
    If !n!==2 (
        Echo %%i
        curl -X PUT "https://api.cloudflare.com/client/v4/zones/域名ID/dns_records/域名解析记录ID" ^
                -H "X-Auth-Email: 账号邮箱" ^
                -H "X-Auth-Key: 前面获取的 API 令牌" ^
                -H "Content-Type: application/json" ^
                --data "{\"type\":\"A\",\"name\":\"完整域名\",\"content\":\"%%i\",\"ttl\":1,\"proxied\":true}"
        goto :END
    )
)
:END
pause