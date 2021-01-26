#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# --------------------------------------------------------------
#	项目: CloudflareSpeedTest 自动更新域名解析记录
#	版本: 1.0.0
#	作者: XIU2
#	项目: https://github.com/XIU2/CloudflareSpeedTest
# --------------------------------------------------------------

FOLDER="/root/CloudflareST"
ZONE_ID="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
DNS_RECORDS_ID="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
EMAIL="xxx@yyy.com"
KEY="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
TYPE="A"
NAME="xxx.yyy.zzz"
TTL="1"
PROXIED="true"

_UPDATE() {
	./CloudflareST
	CONTENT=$(sed -n "2,1p" result.csv | awk -F, '{print $1}')
	curl -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${DNS_RECORDS_ID}" \
		-H "X-Auth-Email: ${EMAIL}" \
		-H "X-Auth-Key: ${KEY}" \
		-H "Content-Type: application/json" \
		--data "{\"type\":\"${TYPE}\",\"name\":\"${NAME}\",\"content\":\"${CONTENT}\",\"ttl\":${TTL},\"proxied\":${PROXIED}}"
}

cd "${FOLDER}"
_UPDATE