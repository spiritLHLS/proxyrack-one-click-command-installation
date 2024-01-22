#!/bin/bash
# FROM https://github.com/spiritLHLS/proxyrack-one-click-command-installation
# 2024.01.22

utf8_locale=$(locale -a 2>/dev/null | grep -i -m 1 -E "UTF-8|utf8")
if [[ -z "$utf8_locale" ]]; then
  echo "No UTF-8 locale found"
else
  export LC_ALL="$utf8_locale"
  export LANG="$utf8_locale"
  export LANGUAGE="$utf8_locale"
  echo "Locale set to $utf8_locale"
fi

# 定义容器名
NAME='proxyrack'

# 自定义字体彩色，read 函数，安装依赖函数
red(){ echo -e "\033[31m\033[01m$1$2\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }

# 必须以root运行脚本
check_root(){
  [[ $(id -u) != 0 ]] && red " The script must be run as root, you can enter sudo -i and then download and run again." && exit 1
}

# 判断系统，并选择相应的指令集
check_operating_system(){
  CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)"
       "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)"
       "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)"
       "$(grep . /etc/redhat-release 2>/dev/null)"
       "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')"
      )

  for i in "${CMD[@]}"; do SYS="$i" && [[ -n $SYS ]] && break; done

  REGEX=("debian" "ubuntu" "raspbian" "centos|red hat|kernel|oracle linux|amazon linux|alma|rocky")
  RELEASE=("Debian" "Ubuntu" "Raspbian" "CentOS")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "apt -y update" "yum -y update")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "apt -y install" "yum -y install")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "apt -y autoremove" "yum -y autoremove")

  for ((int = 0; int < ${#REGEX[@]}; int++)); do
    [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
  done

  [[ -z $SYSTEM ]] && red " ERROR: The script supports Debian, Ubuntu, CentOS or Alpine systems only.\n" && exit 1
}

# 判断宿主机的 IPv4 或双栈情况
check_ipv4(){
  # 遍历本机可以使用的 IP API 服务商
  # 定义可能的 IP API 服务商
  API_NET=("ip.sb" "ipget.net" "ip.ping0.cc" "https://ip4.seeip.org" "https://api.my-ip.io/ip" "https://ipv4.icanhazip.com" "api.ipify.org" "ifconfig.co")

  # 遍历每个 API 服务商，并检查它是否可用
  for p in "${API_NET[@]}"; do
    # 使用 curl 请求每个 API 服务商
    response=$(curl -s4m8 "$p")
    sleep 1
    # 检查请求是否失败，或者回传内容中是否包含 error
    if [ $? -eq 0 ] && ! echo "$response" | grep -q "error"; then
      # 如果请求成功且不包含 error，则设置 IP_API 并退出循环
      IP_API="$p"
      break
    fi
  done

  # 判断宿主机的 IPv4 、IPv6 和双栈情况
  ! curl -s4m8 $IP_API | grep -q '\.' && red " ERROR：The host must have IPv4. " && exit 1
}

# 判断 CPU 架构
check_virt(){
  ARCHITECTURE=$(uname -m)
  case "$ARCHITECTURE" in
#     aarch64 ) ARCH=arm64v8;;
#     armv7l ) ARCH=arm32v7;;
    x64|x86_64|amd64 ) ARCH=latest;;
    * ) red " ERROR: Unsupported architecture: $ARCHITECTURE\n" && exit 1;;
  esac
}

# 输入 proxyrack 的个人 token
input_token(){
  [ -z $PRTOKEN ] && reading " Enter your API Key, if you do not find it, open https://peer.proxyrack.com/ref/p28h60vn6bq3pznzx4bjuocdwqb5lrlb2tf3fksy: " PRTOKEN
}

container_build(){
  # 宿主机安装 docker
  green "\n Install docker.\n "
  if ! systemctl is-active docker >/dev/null 2>&1; then
    echo -e " \n Install docker \n " 
    if [ $SYSTEM = "CentOS" ]; then
      ${PACKAGE_INSTALL[int]} yum-utils
      yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &&
      ${PACKAGE_INSTALL[int]} docker-ce docker-ce-cli containerd.io
      systemctl enable --now docker
    else
      ${PACKAGE_INSTALL[int]} docker.io
    fi
  fi

  # 删除旧容器（如有）
  docker ps -a | awk '{print $NF}' | grep -qw "$NAME" && yellow " Remove the old proxyrack container.\n " && docker rm -f "$NAME" >/dev/null 2>&1

  # 创建容器
  yellow " Create the proxyrack container.\n "
  uuid=$(cat /dev/urandom | LC_ALL=C tr -dc 'A-F0-9' | dd bs=1 count=64 2>/dev/null)
  docker pull proxyrack/pop
  docker run -d --name "$NAME" --restart always -e UUID="$uuid" proxyrack/pop
  sleep 10
  dvid=$(docker exec -it "$NAME" cat uuid.cfg)
  curl \
    -X POST https://peer.proxyrack.com/api/device/add \
    -H "Api-Key: $PRTOKEN" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "{\"device_id\":\"$dvid\",\"device_name\":\"$dname\"}"

  # 创建 Towerwatch
  [[ ! $(docker ps -a) =~ watchtower ]] && yellow " Create TowerWatch.\n " && docker run -d --name watchtower --restart always -p 2095:8080 -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup >/dev/null 2>&1
}

# 显示结果
result(){
  sleep 5
  docker ps -a | grep -q "$NAME" && green " Device id:" && sudo docker exec -it proxyrack cat uuid.cfg && green " Device name:" && echo "$dname" && green "Install success."|| red " Install fail.\n"
}

# 卸载
uninstall(){
  dvid=$(docker exec -it "$NAME" cat uuid.cfg)
  echo "$dvid"
  docker rm -f $(docker ps -a | grep -w "$NAME" | awk '{print $1}')
  docker rmi -f $(docker images | grep proxyrack/pop | awk '{print $3}')
  curl \
    -X POST https://peer.proxyrack.com/api/device/delete  \
    -H "Api-Key: $PRTOKEN" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "{\"device_id\":\"$dvid\"}" >/dev/null 2>&1
  green "\n Uninstall containers and images complete.\n"
  exit 0
}

# 传参
while getopts "UuT:t:" OPTNAME; do
  case "$OPTNAME" in
    'U'|'u' ) uninstall;;
    'T'|'t' ) PRTOKEN=$OPTARG;;
  esac
done

# 主程序
check_root
check_operating_system
check_ipv4
check_virt
input_token
container_build
result
