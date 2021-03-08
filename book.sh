#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# --------------------------------------------------------------
#	系统: CentOS/Debian/Ubuntu
#	项目: book
#	版本: 1.0.0
#	作者: XIU2
#	官网: https://shell.xiu2.xyz
#	项目: https://github.com/XIU2/Shell
# --------------------------------------------------------------

NOW_VER_SHELL="1.0.0"
FILEPASH=$(cd "$(dirname "$0")"; pwd)
FILEPASH_NOW=$(echo -e "${FILEPASH}"|awk -F "$0" '{print $1}')
NAME="Book"
NAME_PID="book"
NAME_SERVICE="book"
FOLDER="/usr/local/book"
FILE="/usr/local/book/book"
FILE_CONF="/usr/local/book/book.conf"
FILE_LOG="/usr/local/book/book.log"

GREEN_FONT_PREFIX="\033[32m" && RED_FONT_PREFIX="\033[31m" && GREEN_BACKGROUND_PREFIX="\033[42;37m" && RED_BACKGROUND_PREFIX="\033[41;37m" && FONT_COLOR_SUFFIX="\033[0m"
INFO=" ${GREEN_FONT_PREFIX}[信息]${FONT_COLOR_SUFFIX}" && ERROR="${RED_FONT_PREFIX}[错误]${FONT_COLOR_SUFFIX}" && TIP=" ${GREEN_FONT_PREFIX}[注意]${FONT_COLOR_SUFFIX}"

# 获取各项信息
_CHECK_INFO(){
	# 获取账号是否为 ROOT
	if [[ "${1}" == "ROOT" ]]; then
		[[ $EUID != 0 ]] && echo -e "${ERROR} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${GREEN_BACKGROUND_PREFIX}sudo su${FONT_COLOR_SUFFIX} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1

	#  获取系统类型
	elif [[ "${1}" == "OS" ]]; then
		if [[ -f /etc/redhat-release ]]; then
			SYSTEM_RELEASE="Centos"
		elif cat /etc/issue | grep -q -E -i "debian"; then
			SYSTEM_RELEASE="Debian"
		elif cat /etc/issue | grep -q -E -i "ubuntu"; then
			SYSTEM_RELEASE="Ubuntu"
		elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
			SYSTEM_RELEASE="Centos"
		elif cat /proc/version | grep -q -E -i "debian"; then
			SYSTEM_RELEASE="Debian"
		elif cat /proc/version | grep -q -E -i "ubuntu"; then
			SYSTEM_RELEASE="Ubuntu"
		elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
			SYSTEM_RELEASE="Centos"
		fi
		SYSTEM_BIT=$(uname -m)

	# 获取程序是否安装
	elif [[ "${1}" == "INSTALL_STATUS" ]]; then
		[[ ! -e "${FILE}" ]] && echo -e "${ERROR} ${NAME} 没有安装，请检查 !" && exit 1

	# 获取进程PID
	elif [[ "${1}" == "PID" ]]; then
		PID=$(ps -ef| grep "${NAME_PID}"| grep -v "grep" | grep -v ".sh" | grep -v "init.d" |grep -v "service" |awk '{print $2}')

	# 获取IPv4
	elif [[ "${1}" == "IPV4" ]]; then
		IPV4=$(wget -qO- -4 -t1 -T2 ipinfo.io/ip)
		if [[ -z "${IPV4}" ]]; then
			IPV4=$(wget -qO- -4 -t1 -T2 api.ip.sb/ip)
			if [[ -z "${IPV4}" ]]; then
				IPV4=$(wget -qO- -4 -t1 -T2 members.3322.org/dyndns/getip)
				if [[ -z "${IPV4}" ]]; then
					IPV4="IPv4地址获取失败"
				fi
			fi
		fi

	# 获取IP对应地址
	elif [[ "${1}" == "IP_ADDRESS" ]]; then
		if [[ ! -z "${TARGET_IP}" ]]; then
			for((IP_ADDRESS_INTEGER = ${TARGET_IP_TOTAL}; IP_ADDRESS_INTEGER >= 1; IP_ADDRESS_INTEGER--))
			do
				IP_ADDRESS_IP=$(echo "${TARGET_IP}" |sed -n "$IP_ADDRESS_INTEGER"p)
				IP_ADDRESS_IP_ADDRESS=$(wget -qO- -t2 -T3 http://freeapi.ipip.net/${IP_ADDRESS_IP}|sed 's/\"//g;s/,//g;s/\[//g;s/\]//g')
				echo -e " ${GREEN_FONT_PREFIX}${IP_ADDRESS_IP}${FONT_COLOR_SUFFIX} (${IP_ADDRESS_IP_ADDRESS})"
				sleep 1s
			done
		fi

	# 获取最新版本
	elif [[ "${1}" == "NEW_VER" ]]; then
		NEW_VER=$(wget -qO- https://api.github.com/repos/txthinking/brook/releases/latest| grep "tag_name"| awk -F '"' '{print $4}')
		[[ -z ${NEW_VER} ]] && echo -e "${ERROR} ${NAME} 最新版本获取失败！" && exit 1
		echo -e "${INFO} 检测 ${NAME} 最新版本为 [ ${NEW_VER} ]"

	# 检查软件是否有更新
	elif [[ "${1}" == "VER_UPDATE" ]]; then
		NOW_VER=$(${FILE} -v|awk '{print $3}')
	fi
}

# 安装
_INSTALL(){
	_CHECK_INFO "ROOT"
	[[ -e ${FILE} ]] && echo -e "${ERROR} 检测到 ${NAME} 已安装 !" && exit 1
	_CHECK_INFO "OS"
	[[ "${SYSTEM_RELEASE}" != "Centos" ]] && [[ "${SYSTEM_RELEASE}" != "Debian" ]]  && [[ "${SYSTEM_RELEASE}" != "Ubuntu" ]] && echo -e "${ERROR} 本脚本不支持当前系统 ${SYSTEM_RELEASE} !" && exit 1
	echo -e "${INFO} 开始设置 用户配置..."
	_SET_PORT
	_SET_PASSWORD
	echo -e "${INFO} 开始安装/配置 依赖..."
	_INSTALLATION_DEPENDENCY
	echo -e "${INFO} 开始检测最新版本..."
	_CHECK_INFO "NEW_VER"
	echo -e "${INFO} 开始下载/安装..."
	_DOWNLOAD
	echo -e "${INFO} 开始下载/安装 服务脚本(init)..."
	_SERVICE
	echo -e "${INFO} 开始写入 配置文件..."
	_CONFIG_OPERATION "WRITE"
	echo -e "${INFO} 开始设置 iptables防火墙..."
	_IPTABLES_OPTION "SET"
	echo -e "${INFO} 开始添加 iptables防火墙规则..."
	_IPTABLES_OPTION "ADD"
	echo -e "${INFO} 开始保存 iptables防火墙规则..."
	_IPTABLES_OPTION "SAVE"
	echo -e "${INFO} 所有步骤 安装完毕，开始启动..."
	_START
}

# 安装前置依赖
_INSTALLATION_DEPENDENCY(){
	# 修改服务器时区为北京时间
	MD5_SHANGHAI=$(md5sum /usr/share/zoneinfo/Asia/Shanghai | awk '{print $1}')
	MD5_LOCALTIME=$(md5sum /etc/localtime | awk '{print $1}')
	[[ "${MD5_SHANGHAI}" != "${MD5_LOCALTIME}" ]] && \cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

# 下载主程序
_DOWNLOAD(){
	[[ ! -e ${FOLDER} ]] && mkdir ${FOLDER}
	cd ${FOLDER}
	if [[ ${SYSTEM_BIT} == "x86_64" ]]; then
		wget --no-check-certificate -N "https://github.com/txthinking/brook/releases/download/${NEW_VER}/brook_linux_amd64"
		mv brook_linux_amd64 ${FILE}
	else
		wget --no-check-certificate -N "https://github.com/txthinking/brook/releases/download/${NEW_VER}/brook_linux_386"
		mv brook_linux_386 ${FILE}
	fi
	[[ ! -e "${FILE}" ]] && echo -e "${ERROR} ${NAME} 下载失败 !" && _INSTALLATION_FAILURE_CLEANUP
	chmod +x ${FILE}
}

# 安装系统服务
_SERVICE(){
	if [[ "${SYSTEM_RELEASE}" = "Centos" ]]; then
		if ! wget --no-check-certificate "https://shell.xiu2.xyz/service/book_centos" -O /etc/init.d/${NAME_SERVICE}; then
			echo -e "${ERROR} ${NAME} 服务管理脚本下载失败 !" && _INSTALLATION_FAILURE_CLEANUP
		fi
		chmod +x "/etc/init.d/${NAME_SERVICE}"
		chkconfig --add ${NAME_SERVICE}
		chkconfig ${NAME_SERVICE} on
	else
		if ! wget --no-check-certificate "https://shell.xiu2.xyz/service/book_debian" -O /etc/init.d/${NAME_SERVICE}; then
			echo -e "${ERROR} ${NAME} 服务管理脚本下载失败 !" && _INSTALLATION_FAILURE_CLEANUP
		fi
		chmod +x "/etc/init.d/${NAME_SERVICE}"
		update-rc.d -f ${NAME_SERVICE} defaults
	fi
	echo -e "${INFO} ${NAME} 服务管理脚本下载完成 !"
}

# 安装失败善后处理
_INSTALLATION_FAILURE_CLEANUP() {
	[[  -e "${FOLDER}" ]] && rm -rf "${FOLDER}"
	[[ -e "/etc/init.d/${NAME_SERVICE}" ]] && rm -rf "${FOLDER}"
	exit 1
}

# 更新
_UPDATE(){
	_CHECK_INFO "INSTALL_STATUS"
	_CHECK_INFO "NEW_VER"
	_CHECK_INFO "VER_UPDATE"
	[[ -z ${NOW_VER} ]] && echo -e "${ERROR} ${NAME} 当前版本获取失败 !" && exit 1
	NOW_VER="v${NOW_VER}"
	if [[ "${NOW_VER}" != "${NEW_VER}" ]]; then
		echo -e "${INFO} 发现 ${NAME} 已有新版本 [ ${NEW_VER} ]，旧版本 [ ${NOW_VER} ]"
		read -e -p "是否更新 ? [Y/n] :" YN
		[[ -z "${YN}" ]] && YN="Y"
		if [[ ${YN} == [Yy] ]]; then
			_CHECK_INFO "PID"
			[[ ! -z ${PID} ]] && kill -9 ${PID}
			rm -rf ${FILE}
			_DOWNLOAD
			_START
		fi
	else
		echo -e "${INFO} 当前 ${NAME} 已是最新版本 [ ${NEW_VER} ]" && exit 1
	fi
}

# 卸载
_UNINSTALL(){
	_CHECK_INFO "INSTALL_STATUS"
	read -e -p "确定要卸载 ${NAME} ? [y/N](默认N)：" UNINSTALL_YN
	[[ -z ${UNINSTALL_YN} ]] && UNINSTALL_YN="N"
	if [[ ${UNINSTALL_YN} == [Yy] ]]; then
		# 先停止程序
		_CHECK_INFO "PID"
		[[ ! -z $PID ]] && kill -9 ${PID}
		if [[ -e ${FILE_CONF} ]]; then
			# 删除开放的防火墙规则
			_CONFIG_OPERATION "READ"
			_IPTABLES_OPTION "DEL"
			_IPTABLES_OPTION "SAVE"
		fi
		# 删除程序文件
		[[ -e "${FOLDER}" ]] && rm -rf "${FOLDER}"
		# 删除系统服务脚本
		if [[ -e "/etc/init.d/${NAME_SERVICE}"  ]];then
			if [[ "${SYSTEM_RELEASE}" = "Centos" ]]; then
				chkconfig --del ${NAME_SERVICE}
			else
				update-rc.d -f ${NAME_SERVICE} remove
			fi
			rm -rf "/etc/init.d/${NAME_SERVICE}"
		fi
		echo && echo "${NAME} 卸载完成 !" && echo
	else
		echo && echo "卸载已取消..." && echo
	fi
}

# 启动
_START(){
	_CHECK_INFO "INSTALL_STATUS"
	_CHECK_INFO "PID"
	[[ ! -z ${PID} ]] && echo -e "${ERROR} ${NAME} 正在运行，请检查 !" && exit 1
	"/etc/init.d/${NAME_SERVICE}" start
	sleep 1s
	_CHECK_INFO "PID"
	[[ ! -z ${PID} ]] && _VIEW
}

# 停止
_STOP(){
	_CHECK_INFO "INSTALL_STATUS"
	_CHECK_INFO "PID"
	[[ -z ${PID} ]] && echo -e "${ERROR} ${NAME} 没有运行，请检查 !" && exit 1
	"/etc/init.d/${NAME_SERVICE}" stop
}

# 重启
_RESTART(){
	_CHECK_INFO "INSTALL_STATUS"
	_CHECK_INFO "PID"
	[[ ! -z ${PID} ]] && "/etc/init.d/${NAME_SERVICE}" stop
	"/etc/init.d/${NAME_SERVICE}" start
	sleep 1s
	_CHECK_INFO "PID"
	[[ ! -z ${PID} ]] && _VIEW
}

# 读取/写出配置
_CONFIG_OPERATION(){
	# 读取配置
	if [[ "${1}" == "READ" ]]; then
		[[ ! -e "${FILE_CONF}" ]] && echo -e "${ERROR} ${NAME} 配置文件不存在 !" && exit 1
		PORT=$(cat ${FILE_CONF}|grep 'PORT = '|awk -F 'PORT = ' '{print $NF}')
		PASSWORD=$(cat ${FILE_CONF}|grep 'PASSWORD = '|awk -F 'PASSWORD = ' '{print $NF}')
	# 写出配置
	elif [[ "${1}" == "WRITE" ]]; then
		echo -e "PORT = ${PORT}\nPASSWORD = ${PASSWORD}" > ${FILE_CONF}
	fi
}

# 设置 配置信息
_SET(){
	_CHECK_INFO "INSTALL_STATUS"
	echo && echo -e "你要做什么？
  ${GREEN_FONT_PREFIX}1.${FONT_COLOR_SUFFIX}  修改 端口
  ${GREEN_FONT_PREFIX}2.${FONT_COLOR_SUFFIX}  修改 密码
  ${GREEN_FONT_PREFIX}3.${FONT_COLOR_SUFFIX}  修改 端口+密码\n"
	read -e -p "(默认: 取消):" SET_INDEX
	[[ -z "${SET_INDEX}" ]] && echo "已取消..." && exit 1
	if [[ ${SET_INDEX} == "1" ]]; then
		_CONFIG_OPERATION "READ"
		OLD_PORT="${PORT}"
		_SET_PORT
		_CONFIG_OPERATION "WRITE"
		_IPTABLES_OPTION "DEL" "${OLD_PORT}"
		_IPTABLES_OPTION "ADD"
		_RESTART
	elif [[ ${SET_INDEX} == "2" ]]; then
		_CONFIG_OPERATION "READ"
		_SET_PASSWORD
		_CONFIG_OPERATION "WRITE"
		_RESTART
	elif [[ ${SET_INDEX} == "3" ]]; then
		_CONFIG_OPERATION "READ"
		OLD_PORT="${PORT}"
		_SET_PORT
		_SET_PASSWORD
		_CONFIG_OPERATION "WRITE"
		_IPTABLES_OPTION "DEL" "${OLD_PORT}"
		_IPTABLES_OPTION "ADD"
		_RESTART
	else
		echo -e "${ERROR} 请输入正确的数字(1-3)" && exit 1
	fi
}

# 修改端口
_SET_PORT(){
	while true
		do
		read -e -p "请输入端口 [1-65535] (默认7000)：" PORT
		[[ -z "${PORT}" ]] && PORT="7000"
		echo $((${PORT}+0)) &>/dev/null
		if [[ ${?} == 0 ]]; then
			if (( ${PORT} >= 1 )) && (( ${PORT} <= 65536 )); then
				echo && echo "------------------------"
				echo -e "	端口 : ${GREEN_BACKGROUND_PREFIX} ${PORT} ${FONT_COLOR_SUFFIX}"
				echo "------------------------" && echo
				break
			else
				echo "输入错误, 请输入正确的端口。"
			fi
		else
			echo "输入错误, 请输入正确的端口。"
		fi
		done
}

# 修改密码
_SET_PASSWORD(){
	read -e -p "请输入密码 [0-9][a-z][A-Z] (默认随机生成)：" PASSWORD
	[[ -z "${PASSWORD}" ]] && PASSWORD=$(date +%s%N | md5sum | head -c 16)
	echo && echo "------------------------"
	echo -e "	密码 : ${GREEN_BACKGROUND_PREFIX} ${PASSWORD} ${FONT_COLOR_SUFFIX}"
	echo "------------------------" && echo
}

# 查看 配置信息
_VIEW(){
	_CHECK_INFO "INSTALL_STATUS"
	_CONFIG_OPERATION "READ"
	_CHECK_INFO "IPV4"
	clear
	echo -e "\n 地址\t:  ${GREEN_FONT_PREFIX}${IPV4}${FONT_COLOR_SUFFIX}"
	echo -e " 端口\t:  ${GREEN_FONT_PREFIX}${PORT}${FONT_COLOR_SUFFIX}"
	echo -e " 密码\t:  ${GREEN_FONT_PREFIX}${PASSWORD}${FONT_COLOR_SUFFIX}\n"
}

# 查看 日志信息
_VIEW_LOG(){
	_CHECK_INFO "INSTALL_STATUS"
	[[ ! -e "${FILE_LOG}" ]] && echo -e "${ERROR} ${NAME} 日志文件不存在 !" && exit 1
	echo -e "\n${TIP} 按 ${RED_FONT_PREFIX}Ctrl+C${FONT_COLOR_SUFFIX} 终止查看日志\n 如果需要查看完整日志内容，请使用 ${RED_FONT_PREFIX}cat ${FILE_LOG}${FONT_COLOR_SUFFIX} 命令。"
	tail -f "${FILE_LOG}"
}

# 查看 连接信息
_VIEW_CONNECTION_INFO(){
	#_CHECK_INFO "INSTALL_STATUS"
	echo && echo -e "请选择要显示的格式：
 ${GREEN_FONT_PREFIX}1.${FONT_COLOR_SUFFIX} 显示 IP
 ${GREEN_FONT_PREFIX}2.${FONT_COLOR_SUFFIX} 显示 IP+IP归属地" && echo
	read -e -p "(默认: 1):" VIEW_CONNECTION_INFO_INDEX
	[[ -z "${VIEW_CONNECTION_INFO_INDEX}" ]] && VIEW_CONNECTION_INFO_INDEX="1"
	if [[ "${VIEW_CONNECTION_INFO_INDEX}" == "1" ]]; then
		_VIEW_CONNECTION_INFO_WITH
	elif [[ "${VIEW_CONNECTION_INFO_INDEX}" == "2" ]]; then
		echo -e "${TIP} 检测IP归属地(数据源：ipip.net)，如果IP较多，可能时间会比较长..."
		_VIEW_CONNECTION_INFO_WITH "IP_ADDRESS"
	else
		echo -e "${ERROR} 请输入正确的数字 [1-2]" && exit 1
	fi
}

# 显示 链接信息
_VIEW_CONNECTION_INFO_WITH(){
	_CONFIG_OPERATION "READ"
	TARGET_IP=$(ss state connected sport = :${PORT} -tn|sed '1d'|awk '{print $NF}'|sed 's/\]//g'|awk -F ':' '{print $(NF-1)}'|sort -u)
	if [[ -z ${TARGET_IP} ]]; then
		TARGET_IP_TOTAL="0"
		echo -e "端口: ${GREEN_FONT_PREFIX}"${PORT}"${FONT_COLOR_SUFFIX}\t 链接IP总数: ${GREEN_FONT_PREFIX}"${TARGET_IP_TOTAL}"${FONT_COLOR_SUFFIX}\t 当前链接IP: "
	else
		TARGET_IP_TOTAL=$(echo -e "${TARGET_IP}"|wc -l)
		if [[ "${1}" == "IP_ADDRESS" ]]; then
			echo -e "端口: ${GREEN_FONT_PREFIX}"${PORT}"${FONT_COLOR_SUFFIX}\t 链接IP总数: ${GREEN_FONT_PREFIX}"${TARGET_IP_TOTAL}"${FONT_COLOR_SUFFIX}\t 当前链接IP: "
			_CHECK_INFO "IP_ADDRESS"
			echo
		else
			TARGET_IP=$(echo -e "\n${TARGET_IP}")
			echo -e "端口: ${GREEN_FONT_PREFIX}"${PORT}"${FONT_COLOR_SUFFIX}\t 链接IP总数: ${GREEN_FONT_PREFIX}"${TARGET_IP_TOTAL}"${FONT_COLOR_SUFFIX}\t 当前链接IP: ${GREEN_FONT_PREFIX}${TARGET_IP}${FONT_COLOR_SUFFIX}\n"
		fi
	fi
}

# 配置 防火墙
_IPTABLES_OPTION(){
	# 开放端口
	if [[ "${1}" == "ADD" ]]; then
		if [[ ! "${2}" ]]; then
			ADD_PORT="${PORT}"
		else
			ADD_PORT="${2}"
		fi
		iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${ADD_PORT} -j ACCEPT
		iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${ADD_PORT} -j ACCEPT
		ip6tables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${ADD_PORT} -j ACCEPT
		ip6tables -I INPUT -m state --state NEW -m udp -p udp --dport ${ADD_PORT} -j ACCEPT
	# 取消开放端口
	elif [[ "${1}" == "DEL" ]]; then
		if [[ ! "${2}" ]]; then
			DEL_PORT="${PORT}"
		else
			DEL_PORT="${2}"
		fi
		iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport ${DEL_PORT} -j ACCEPT
		iptables -D INPUT -m state --state NEW -m udp -p udp --dport ${DEL_PORT} -j ACCEPT
		ip6tables -D INPUT -m state --state NEW -m tcp -p tcp --dport ${DEL_PORT} -j ACCEPT
		ip6tables -D INPUT -m state --state NEW -m udp -p udp --dport ${DEL_PORT} -j ACCEPT
	# 保存防火墙配置
	elif [[ "${1}" == "SAVE" ]]; then
		if [[ "${SYSTEM_RELEASE}" == "Centos" ]]; then
			service iptables save
			service ip6tables save
		else
			iptables-save > /etc/iptables.up.rules
			ip6tables-save > /etc/ip6tables.up.rules
		fi
	# 配置防火墙规则开机自动导入
	elif [[ "${1}" == "SET" ]]; then
		if [[ "${SYSTEM_RELEASE}" == "Centos" ]]; then
			service iptables save
			service ip6tables save
			chkconfig --level 2345 iptables on
			chkconfig --level 2345 ip6tables on
		else
			iptables-save > /etc/iptables.up.rules
			ip6tables-save > /etc/ip6tables.up.rules
			echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules\n/sbin/ip6tables-restore < /etc/ip6tables.up.rules' > /etc/network/if-pre-up.d/iptables
			chmod +x /etc/network/if-pre-up.d/iptables
		fi
	fi
}

# 更新脚本
_UPDATE_SHELL(){
	NEW_VER_SHELL=$(wget --no-check-certificate -qO- -t1 -T3 "https://shell.xiu2.xyz/book.sh"|grep 'NOW_VER_SHELL="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
	[[ -z "${NEW_VER_SHELL}" ]] && echo -e "${ERROR} 获取脚本最新版本失败！无法链接到 Github !" && exit 1
	#if [[ "${NEW_VER_SHELL}" != "${NOW_VER_SHELL}" ]]; then
		if [[ -e "/etc/init.d/${NAME_SERVICE}" ]]; then
			rm -rf "/etc/init.d/${NAME_SERVICE}"
			_SERVICE
		fi
		wget -N --no-check-certificate "https://shell.xiu2.xyz/book.sh"
		chmod +x "${FILEPASH_NOW}/book.sh"
		echo -e "脚本已更新为最新版本[ ${NEW_VER_SHELL} ] !\n${TIP} 因为更新方式为直接覆盖当前运行的脚本，所以可能下面会提示一些报错，无视即可。" && exit 0
	#else
		#echo -e "脚本当前为最新版本[ ${NEW_VER_SHELL} ] !" && exit 0
	#fi
}

# 脚本起始位置
echo -e "  ${NAME} 一键脚本 ${RED_FONT_PREFIX}[v${NOW_VER_SHELL}]${FONT_COLOR_SUFFIX}

 ${GREEN_FONT_PREFIX} 0.${FONT_COLOR_SUFFIX} 更新脚本
----------
  ${GREEN_FONT_PREFIX} 1.${FONT_COLOR_SUFFIX} 安装
  ${GREEN_FONT_PREFIX} 2.${FONT_COLOR_SUFFIX} 更新
  ${GREEN_FONT_PREFIX} 3.${FONT_COLOR_SUFFIX} 卸载
 ----------
  ${GREEN_FONT_PREFIX} 4.${FONT_COLOR_SUFFIX} 启动
  ${GREEN_FONT_PREFIX} 5.${FONT_COLOR_SUFFIX} 停止
  ${GREEN_FONT_PREFIX} 6.${FONT_COLOR_SUFFIX} 重启
 ----------
  ${GREEN_FONT_PREFIX} 7.${FONT_COLOR_SUFFIX} 设置 配置
  ${GREEN_FONT_PREFIX} 8.${FONT_COLOR_SUFFIX} 查看 账号
  ${GREEN_FONT_PREFIX} 9.${FONT_COLOR_SUFFIX} 查看 日志
  ${GREEN_FONT_PREFIX}10.${FONT_COLOR_SUFFIX} 查看 链接\n"
if [[ -e ${FILE} ]]; then
	_CHECK_INFO "PID"
	if [[ ! -z "${PID}" ]]; then
		echo -e " 当前状态:  ${GREEN_FONT_PREFIX}已安装${FONT_COLOR_SUFFIX} 并  ${GREEN_FONT_PREFIX}已启动${FONT_COLOR_SUFFIX}"
	else
		echo -e " 当前状态:  ${GREEN_FONT_PREFIX}已安装${FONT_COLOR_SUFFIX} 但 ${RED_FONT_PREFIX}未启动${FONT_COLOR_SUFFIX}"
	fi
else
	echo -e " 当前状态: ${RED_FONT_PREFIX}未安装${FONT_COLOR_SUFFIX}"
fi
echo
read -e -p " 请输入数字 [0-10]:" NUM
case "${NUM}" in
	0)
	_UPDATE_SHELL
	;;
	1)
	_INSTALL
	;;
	2)
	_UPDATE
	;;
	3)
	_UNINSTALL
	;;
	4)
	_START
	;;
	5)
	_STOP
	;;
	6)
	_RESTART
	;;
	7)
	_SET
	;;
	8)
	_VIEW
	;;
	9)
	_VIEW_LOG
	;;
	10)
	_VIEW_CONNECTION_INFO
	;;
	*)
	echo "请输入正确数字 [0-10]"
	;;
esac