#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# --------------------------------------------------------------
#	系统: ALL
#	项目: 蓝奏云上传文件
#	版本: 1.0.0
#	作者: XIU2
#   官网: https://shell.xiu2.xyz
#	项目: https://github.com/XIU2/Shell
# --------------------------------------------------------------

USERNAME="XXX" # 蓝奏云用户名
PASSWORD="XXX" # 蓝奏云密码
TOKEN="XXX" # 微信推送链接 Token，可选

UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36"
HEADER_UPLOAD="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36
Referer: https://up.woozooo.com/mydisk.php?item=files&action=index&u=${USERNAME}
Accept-Language: zh-CN,zh;q=0.9"
HEADER_LOGIN="User-Agent: Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/82.0.4051.0 Mobile Safari/537.36
Referer: https://up.woozooo.com/account.php?action=login&ref=/mydisk.php
Accept-Language: zh-CN,zh;q=0.9'"
HEADER_CHECK_LOGIN="${HEADER_UPLOAD}"
DATA_LOGIN="action=login&task=login&setSessionId=&setToken=&setSig=&setScene=nc_login&username=${USERNAME}&password=${PASSWORD}&formhash="

URL_ACCOUNT="https://pc.woozooo.com/account.php"
URL_LOGIN="https://pc.woozooo.com/account.php?action=login"
URL_UPLOAD="https://up.woozooo.com/fileup.php"

COOKIE_FILE="/root/lanzouyun_cookie.txt"

INFO="[信息]" && ERROR="[错误]" && TIP="[注意]"

# 获取 Cookie
_GET_COOKIE() {
	[[ ! -e "${COOKIE_FILE}" ]] && _NOTICE "ERROR" "没有找到 Cookie 文件！"
	COOKIE_TEXT=$(cat ${COOKIE_FILE})
	[[ -z "${COOKIE_TEXT}" ]] && _NOTICE "ERROR" "Cookie 文件内容为空！"
	COOKIE_PHPDISK_INFO=$(echo "${COOKIE_TEXT}"|grep "phpdisk_info"|awk '{print $NF}')
	[[ -z "${COOKIE_PHPDISK_INFO}" ]] && _NOTICE "ERROR" "Cookie 文件中没有找到 phpdisk_info！"
	COOKIE_YLOGIN=$(echo "${COOKIE_TEXT}"|grep "ylogin"|awk '{print $NF}')
	[[ -z "${COOKIE_YLOGIN}" ]] && _NOTICE "ERROR" "Cookie 文件中没有找到 ylogin！"
}

# 检查是否已登录
_CHECK_LOGIN() {
	[[ ! -e "${COOKIE_FILE}" ]] && return 1
	_GET_COOKIE
	HTML_CHECK_LOGIN=$(curl -s --http1.1 -b "ylogin=${COOKIE_YLOGIN};phpdisk_info=${COOKIE_PHPDISK_INFO}" -H "${HEADER_CHECK_LOGIN}" "${URL_ACCOUNT}"|grep "登录")
	[[ ! -z "${HTML_CHECK_LOGIN}" ]] && return 1
	return 0
}

# 登陆
_LOGIN() {
	if [[ "${USERNAME}" != "" && "${USERNAME}" != "XXX" && "${PASSWORD}" != "" && "${PASSWORD}" != "XXX" ]]; then
        FORMHASH=$(curl -s -A "${UA}" "${URL_LOGIN}"|grep 'formhash'|awk -F '"' '{print $6}')
	    [[ -z "${FORMHASH}" ]] && _NOTICE "ERROR" "FORMHASH获取失败！"
	    HTML_LOGIN=$(curl -s --http1.1 -c "${COOKIE_FILE}" -H "${HEADER_LOGIN}" -d "${DATA_LOGIN}${FORMHASH}" "${URL_ACCOUNT}"|grep "登录成功")
	    [[ -z "${HTML_LOGIN}" ]] && _NOTICE "ERROR" "登陆失败！"
	    echo -e "${INFO} 登陆成功！"
	    _GET_COOKIE
    else
        echo -e "${ERROR} 未指定用户名和密码！"
    fi
}

# 上传文件
_UPLOAD() {
	[[ $(du "${NAME_FILE}"|awk '{print $1}') -gt 100000000 ]] && _NOTICE "ERROR" "${NAME}文件大于 100MB！"
	HTML_UPLOAD=$(curl -s -b "ylogin=${COOKIE_YLOGIN};phpdisk_info=${COOKIE_PHPDISK_INFO}" -H "${URL_UPLOAD}" -F "task=1" -F "id=WU_FILE_0" -F "folder_id=${FOLDER_ID}" -F "name=${NAME}" -F "upload_file=@${NAME_FILE}" "${URL_UPLOAD}"|grep '\\u4e0a\\u4f20\\u6210\\u529f')
	[[ -z "${HTML_UPLOAD}" ]] && _NOTICE "ERROR" "${NAME}文件上传失败！"
	echo -e "${INFO} 文件上传成功！"
}

# 消息推送至微信
_NOTICE() {
	PARAMETER_1="$1"
	PARAMETER_2="$2"
    if [[ "${TOKEN}" != "" && "${TOKEN}" != "XXX" ]]; then
	    # 微信推送 Server酱 https://sc.ftqq.com/3.version
	    #wget --no-check-certificate -t2 -T5 -4 -U "${UA}" -qO- "https://sc.ftqq.com/${TOKEN}.send?text=${PARAMETER_1}${PARAMETER_2}"
	    # 微信推送 pushplus http://pushplus.hxtrip.com/
	    wget --no-check-certificate -t2 -T5 -4 -U "${UA}" -qO- "http://pushplus.hxtrip.com/customer/push/send?token=${TOKEN}&title=${PARAMETER_1}&content=${PARAMETER_2}"
    fi
    if [[ ${PARAMETER_1} == "INFO" ]]; then
		echo -e "${INFO} ${PARAMETER_2}"
	else 
		echo -e "${ERROR} ${PARAMETER_2}"
	fi
	exit 1
}

NAME="$1" # 文件名
NAME_FILE="$2" # 文件路径
FOLDER_ID="$3" # 上传文件夹ID
if [[ -z "${NAME}" ]]; then
	echo -e "${ERROR} 未指定文件名！" && exit 1
elif [[ -z "${NAME_FILE}" ]]; then
	echo -e "${ERROR} 未指定文件路径！" && exit 1
elif [[ -z "${FOLDER_ID}" ]]; then
	echo -e "${ERROR} 未指定上传文件夹ID！" && exit 1
fi
_CHECK_LOGIN
[[ $? != 0 ]] && echo -e "${ERROR} 当前未登陆，开始尝试登陆！" && _LOGIN
_UPLOAD