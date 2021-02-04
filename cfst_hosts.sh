#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# --------------------------------------------------------------
#	项目: CloudflareSpeedTest 自动更新 Hosts
#	版本: 1.0.0
#	作者: XIU2
#	项目: https://github.com/XIU2/CloudflareSpeedTest
# --------------------------------------------------------------

_CHECK() {
	while true
		do
		if [[ ! -e "nowip.txt" ]]; then
			echo -e "该脚本的作用为 CloudflareST 测速后获取最快 IP 并替换 Hosts 中的 Cloudflare CDN IP。\n使用前请先阅读：https://github.com/XIU2/CloudflareSpeedTest/issues/42#issuecomment-768273848"
			echo -e "第一次使用，请先将 Hosts 中所有 Cloudflare CDN IP 统一改为一个 IP。"
			read -e -p "输入该 Cloudflare CDN IP 并回车（后续不再需要该步骤）：" NOWIP
			if [[ ! -z "${NOWIP}" ]]; then
				echo ${NOWIP} > nowip.txt
				break
			else
				echo "该 IP 不能是空！"
			fi
		else
			break
		fi
	done
}

_UPDATE() {
	echo -e "开始测速..."
	NOWIP=$(head -1 nowip.txt)
	./CloudflareST
	BESTIP=$(sed -n "2,1p" result.csv | awk -F, '{print $1}')
	echo ${BESTIP} > nowip.txt
	echo -e "\n旧 IP 为 ${NOWIP}\n新 IP 为 ${BESTIP}\n"

	echo "开始备份 Hosts 文件（hosts_backup）..."
	\cp -f /etc/hosts /etc/hosts_backup

	echo -e "开始替换..."
	sed -i 's/'${NOWIP}'/'${BESTIP}'/g' /etc/hosts
	echo -e "完成..."
}

_CHECK
_UPDATE