#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# --------------------------------------------------------------
#	系统: ALL
#	项目: qBittorrent Enhanced Edition 便携版制作 脚本
#	版本: 1.0.5
#	作者: XIU2
#	官网: https://shell.xiu2.xyz
#	项目: https://github.com/XIU2/Shell
# --------------------------------------------------------------

# 首次使用脚本前，请先配置好 FOLDER_ID、TOKEN、FOLDER、LZY_PATH 四个变量。
FOLDER_ID="12345" # 蓝奏云网盘要上传文件的文件夹 ID， https://shell.xiu2.xyz/#/md/lanzou_up?id=%e8%8e%b7%e5%8f%96%e6%96%87%e4%bb%b6%e5%a4%b9id
TOKEN="XXX" # 微信推送链接 Token，可选
FOLDER="/root/qBittorrentEE" # 脚本工作目录（下载、解压、压缩、上传等操作都在这个文件夹内），脚本会自动创建文件夹
LZY_PATH="/root/lanzou_up.sh" # 蓝奏云上传文件脚本位置， https://shell.xiu2.xyz/#/md/lanzou_up
FILE_FORMAT="zip" # 最后打包的压缩包格式，推荐 zip 或 7z

UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"
FOLDER_DOWNLOAD="${FOLDER}/Download" # 存放下载文件的文件夹
FOLDER_DOWNLOAD_UNZIP="${FOLDER_DOWNLOAD}/qBittorrentEE" # 解压下载文件的文件夹
FOLDER_OTHER="${FOLDER}/Other" # 存放配置等文件文件夹
FOLDER_UPLOAD="${FOLDER}/Upload" # 存放压缩后文件 并 上传的文件夹
FILE_OLD_VER="${FOLDER}/old_ver.txt" # 存放旧版本号的文件（每次执行脚本都会检查最新版本）

INFO="[信息]" && ERROR="[错误]" && TIP="[注意]"

# 检查最新版本，可以通过 _CHECK_VER "x.x.x" 来指定版本
_CHECK_VER(){
	NEW_VER=$1 # 此处是手动指定版本号时的代码
	[[ -z ${NEW_VER} ]] && NEW_VER=$(wget -qO- https://api.github.com/repos/c0re100/qBittorrent-Enhanced-Edition/releases| grep "tag_name"| head -n 1| awk -F ":" '{print $2}'| sed 's/\"//g;s/,//g;s/ //g;s/release-//')
	[[ -z ${NEW_VER} ]] && _NOTICE "ERROR"  "qBittorrentEE最新版本获取失败！"
	[[ ! -e ${FOLDER} ]] && mkdir "${FOLDER}" # 如果主文件夹不存在，就新建
	[[ ! -e ${FILE_OLD_VER} ]] && echo -n ${NEW_VER} > ${FILE_OLD_VER} # 如果旧版本文件不存在，说明是首次运行，则把当前版本号写入该文件
	[[ $(cat ${FILE_OLD_VER}) == ${NEW_VER} ]] && echo -e "${INFO} 已经是最新版本！${NEW_VER} [$(date '+%Y/%m/%d %H:%M')]" && exit 1
	echo -n ${NEW_VER} > ${FILE_OLD_VER}
}

# 下载
_DOWNLOAD(){
	[[ ! -e ${FOLDER_DOWNLOAD} ]] && mkdir "${FOLDER_DOWNLOAD}" # 如果下载文件夹不存在，就新建
	cd ${FOLDER_DOWNLOAD}
	if ! wget --no-check-certificate -q -t2 -T5 -4 -U "${UA}" -O "qbittorrentEE_x32.exe" "https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-${NEW_VER}/qbittorrent_${NEW_VER}_setup.exe"; then
	rm -f qbittorrentEE_x32.exe
	_NOTICE "ERROR" "qBittorrentEE_x32_v${NEW_VER}下载失败！"
	fi
	if ! wget --no-check-certificate -q -t2 -T5 -4 -U "${UA}" -O "qbittorrentEE_x64.exe" "https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-${NEW_VER}/qbittorrent_${NEW_VER}_x64_setup.exe"; then
	rm -f qbittorrentEE_x64.exe
	_NOTICE "ERROR" "qBittorrentEE_x64_v${NEW_VER}下载失败！"
	fi
}

# 解压
_UNZIP(){
	[[ -e ${FOLDER_DOWNLOAD_UNZIP} ]] && rm -rf "${FOLDER_DOWNLOAD_UNZIP}" # 如果解压文件夹存在，就删除并重建
	mkdir "${FOLDER_DOWNLOAD_UNZIP}"
	7z x -bb0 -x'!qbittorrent.pdb' -x'!$PLUGINSDIR' -o"${FOLDER_DOWNLOAD_UNZIP}" qbittorrentEE_x64.exe > /dev/null # 解压64位文件
	[[ ! -e "${FOLDER_DOWNLOAD_UNZIP}/qbittorrent.exe" ]] && _NOTICE "ERROR" "qBittorrentEE_x64_v${NEW_VER}解压失败！"
	mv "${FOLDER_DOWNLOAD_UNZIP}/qbittorrent.exe" "${FOLDER_DOWNLOAD_UNZIP}/qbittorrent_x64.exe" # 将 qbittorrent.exe 重命名位 qbittorrent_x64.exe
	7z e -bb0 -o"${FOLDER_DOWNLOAD_UNZIP}" qbittorrentEE_x32.exe qbittorrent.exe > /dev/null # 解压32位文件，仅 qbittorrent.exe
	[[ ! -e "${FOLDER_DOWNLOAD_UNZIP}/qbittorrent.exe" ]] && _NOTICE "ERROR" "qBittorrentEE_x32_v${NEW_VER}解压失败！"
	rm -rf qbittorrentEE_x64.exe
	rm -rf qbittorrentEE_x32.exe
	cd "${FOLDER_DOWNLOAD_UNZIP}/translations"
	rm -f $(ls|egrep -v 'zh_') # 删除非中文语言文件，如果需要全语言，则注释这一行及上一行（行首加井号）
}

# 压缩
_ZIP(){
	cd ${FOLDER_DOWNLOAD}
	[[ ! -e ${FOLDER_OTHER} ]] && mkdir "${FOLDER_OTHER}" # 如果便携配置等文件所在文件夹不存在，就新建
	cp -r "${FOLDER_OTHER}"/* "${FOLDER_DOWNLOAD_UNZIP}" # 复制便携配置等文件到文件夹内（即压缩包内）
	7z a -bb0 "qBittorrentEE_v${NEW_VER}_便携版.${FILE_FORMAT}" "qBittorrentEE" > /dev/null # 压缩
	rm -rf "${FOLDER_DOWNLOAD_UNZIP}" # 删除前面解压，已经无用文件夹
	[[ ! -e "qBittorrentEE_v${NEW_VER}_便携版.${FILE_FORMAT}" ]] && _NOTICE "ERROR" "qBittorrentEE_v${NEW_VER}压缩失败！"
	[[ ! -e ${FOLDER_UPLOAD} ]] && mkdir "${FOLDER_UPLOAD}" # 如果上传文件夹不存在，就新建
	mv "qBittorrentEE_v${NEW_VER}_便携版.${FILE_FORMAT}" "${FOLDER_UPLOAD}" # 移动到上传文件夹

}

#上传
_UPLOAD(){
	bash ${LZY_PATH} "qBittorrentEE_v${NEW_VER}_便携版.${FILE_FORMAT}" "${FOLDER_UPLOAD}/qBittorrentEE_v${NEW_VER}_便携版.${FILE_FORMAT}" "${FOLDER_ID}"
	#_NOTICE "INFO" "qBittorrentEE_v${NEW_VER}" # 你可以取消井号注释，这样每次更新也会推送消息至微信
}

# 通知
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
_CHECK_VER "$1" # 运行脚本的时候传递参数可以指定版本号，例：bash qbee_p.sh "4.2.5.11"
_DOWNLOAD
_UNZIP
_ZIP
_UPLOAD # 如果不想上传到蓝奏云，可以把这行注释掉（行首加井号）