#!/bin/bash
# 安全: 菜单 1、4 若 vendor/remote 缺失可设 VPS_BENCHKIT_ALLOW_REMOTE=1 从网络拉取；菜单 3（goback.sh）仅使用仓库内脚本。

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

if [[ -f /etc/redhat-release ]]; then
    release="centos"
    systemPackage="yum"
    systempwd="/usr/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
    systemPackage="yum"
    systempwd="/usr/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
    systemPackage="yum"
    systempwd="/usr/lib/systemd/system/"
fi

$systemPackage -y install wget curl

vps_superspeed(){
	local f="${_script_dir}/vendor/remote/superspeed.sh"
	if [[ -f "$f" && -s "$f" ]]; then
		bash "$f"
		return
	fi
	if [[ "${VPS_BENCHKIT_ALLOW_REMOTE:-0}" != "1" ]]; then
		red " 缺少本地脚本: $f"
		yellow " 请将 superspeed 保存到上述路径，或设置 VPS_BENCHKIT_ALLOW_REMOTE=1 从网络拉取。"
		return 1
	fi
	yellow " 警告: 缺少本地 superspeed，正从 git.io 拉取（未固定版本）。"
	bash <(curl -Lso- https://git.io/superspeed)
}

vps_zbench(){
	bash "${_script_dir}/ZBench-CN.sh"
}
vps_testrace(){
	local f="${_script_dir}/vendor/remote/goback.sh"
	if [[ ! -f "$f" || ! -s "$f" ]]; then
		red " 缺少本地脚本: $f"
		yellow " 请将上游 goback.sh 放入上述路径（见 README「goback.sh」）。"
		return 1
	fi
	bash "$f"
}
vps_LemonBenchIntl(){
	local f="${_script_dir}/vendor/remote/LemonBenchIntl.sh"
	if [[ -f "$f" && -s "$f" ]]; then
		bash "$f" --fast
		return
	fi
	if [[ "${VPS_BENCHKIT_ALLOW_REMOTE:-0}" != "1" ]]; then
		red " 缺少本地脚本: $f"
		yellow " 请将 LemonBench 保存到上述路径，或设置 VPS_BENCHKIT_ALLOW_REMOTE=1 从网络拉取。"
		return 1
	fi
	yellow " 警告: 缺少本地 LemonBench，正从 ilemonra.in 拉取。"
	curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s -- fast
}

start_menu(){
    clear
	green "=========================================================="
     blue " 支持系统：CentOS 7+ / Debian 9+ / Ubuntu 16.04+"
	green "=========================================================="
   yellow " 说明：本菜单用于 VPS 综合测试（性能、带宽、回程路由等）。"
	green "=========================================================="
      red " 测速会消耗较多出站流量，请知悉。"
    green "=========================================================="
     blue " 1. VPS 三网纯测速    （各取部分节点 - 中文显示）"
   yellow "    风险: superspeed 内或再拉测速工具; 缺文件且 ALLOW_REMOTE 时执行远程 shell"
     blue " 2. VPS 综合性能测试  （包含测速 - 英文显示）"
   yellow "    风险: 缺依赖时 wget 拉取; 可选上传见 ZBENCH_UPLOAD; 部分脚本访问外网 API"
     blue " 3. VPS 回程路由     （四网测试 - 英文显示）"
   yellow "    风险: 仅本地 goback.sh; 脚本内或 wget besttrace 等(上游 URL)"
     blue " 4. VPS 快速全方位测速（包含性能、回程、速度 - 英文显示）"
   yellow "    风险: 运行中 curl 拉 jq/fio 等二进制; 缺文件且 ALLOW_REMOTE 时 curl|bash"
   yellow " 0. 退出脚本"
    echo
   yellow " 详细说明见 README「各选项与安全」。"
    echo
    read -p "请输入数字:" num
    case "$num" in
    	1)
		vps_superspeed
		;;
		2)
		vps_zbench
		;;
		3)
		vps_testrace
		;;
		4)
		vps_LemonBenchIntl
		;;
		0)
		exit 0
		;;
		*)
	clear
	echo "请输入正确数字"
	sleep 2s
	start_menu
	;;
    esac
}

start_menu
