#!/bin/bash

SOCKS5_INSTALL_PATH="/usr/local"

CHECK_OS(){
	if [[ -f /etc/redhat-release ]];then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian";then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu";then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat";then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian";then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu";then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat";then
		release="centos"
	fi
}

CLOSE_THE_FIREWALL(){
	CLOSE_THE_IPTABLES(){
		iptables -F
		iptables -X
		iptables -I INPUT -p tcp -m tcp --dport 1:65535 -j ACCEPT
		iptables -I INPUT -p udp -m udp --dport 1:65535 -j ACCEPT
		iptables-save > /etc/sysconfig/iptables
		echo 'iptables-restore /etc/sysconfig/iptables' >> /etc/rc.local
	}
	CLOSE_THE_FIREWALLD(){
		if [ -e /usr/bin/systemctl ];then
			systemctl stop firewalld.service
			systemctl disable firewalld.service
		fi
	}
	
	CLOSE_THE_IPTABLES
	CLOSE_THE_FIREWALLD
}

SHOW_SOCKS5(){
	clear
	echo "
 ######   #######   ######  ##    ##  ######  ######## 
##    ## ##     ## ##    ## ##   ##  ##    ## ##       
##       ##     ## ##       ##  ##   ##       ##       
 ######  ##     ## ##       #####     ######  #######  
      ## ##     ## ##       ##  ##         ##       ## 
##    ## ##     ## ##    ## ##   ##  ##    ## ##    ## 
 ######   #######   ######  ##    ##  ######   ######  
"
}

INSTALL_SOCKS5(){
	if [ -e /etc/opt/ss5/ss5.conf ];then
		echo "你已经安装了SOCKS5."
		echo "You have installed SOCKS5."
		exit
	fi
	
	CHECK_OS
	case "${release}" in
		centos)
			yum -y install iptables firewalld iptables-services
			yum -y install gcc zip git curl wget unzip screen net-tools pam-devel openssl-devel openldap-devel;;
		debian|ubuntu)
			echo "非常抱歉,暂不支持除CentOS以外的系统."
			echo "I am very sorry that I do not support systems other than CentOS."
			exit;;
	esac
	
	#下载,编译
	wget -P ${SOCKS5_INSTALL_PATH} "http://downloads.sourceforge.net/project/ss5/ss5/3.8.9-8/ss5-3.8.9-8.tar.gz"
	cd ${SOCKS5_INSTALL_PATH}
	tar -xzvf ss5-3.8.9-8.tar.gz
	rm -rf ss5-3.8.9-8.tar.gz
	cd ss5-3.8.9
	./configure
	make
	make install
	cd /root
	#开启认证
	sed -i '87c auth    0.0.0.0/0               -              u' /etc/opt/ss5/ss5.conf
	sed -i '203c permit  u       0.0.0.0/0       -       0.0.0.0/0       -       -       -       -       -' /etc/opt/ss5/ss5.conf
	rm -rf /etc/opt/ss5/ss5.passwd
	#修正/etc/rc.d/init.d/ss5文件语法错误
	sed -i '18c  [[ ${NETWORKING} = "no" ]] && exit 0' /etc/rc.d/init.d/ss5
	#设置开机自启
	chmod u+x /etc/rc.d/init.d/ss5
	chkconfig --add ss5
	chkconfig ss5 on
	service ss5 start
	#关闭防火墙
	CLOSE_THE_FIREWALL
	
	SHOW_SOCKS5
	echo "SOCKS5安装完成,您需要添加一个用户才可使用.使用命令 socks5 user add 来添加."
	echo "SOCKS5 installation is complete, you need to add a user to use. Use the command socks5 user add to add."
}

UNINSTALL_SOCKS5(){
	cd ${SOCKS5_INSTALL_PATH}/ss5-3.8.9
	make uninstall
	cd /root
	rm -rf ${SOCKS5_INSTALL_PATH}/ss5-3.8.9
	rm -rf /etc/opt/ss5/ss5.conf
	
	SHOW_SOCKS5
	echo "SOCKS5已卸载完成."
	echo "SOCKS5 has been uninstalled."
}

ADD_USER(){
	username=${1}
	password=${2}
	
	if [[ ${username} = "" ]] || [[ ${password} = "" ]];then
		echo "你必须设置账户和密码,缺一不可."
		echo "You must set up your account and password."
		echo "如若要添加账户为 123 ,密码为 456 的用户,使用命令 socks5 user add 123 456 即可."
		echo "If you want to add an account with 123 and a user with a password of 456, use the socks5 user add 123 456 command."
		exit
	else
		echo "${username} ${password}" >> /etc/opt/ss5/ss5.passwd
		service ss5 restart > /dev/null
		
		SHOW_SOCKS5
		Address=$(curl -s ipv4.ip.sb)
		Shadowrocket_Address=$(echo ${username}:${password}@${Address}:1080 | base64)
		echo "完成,连接用户:${username} 连接密码:${password} 连接地址:${Address}"
		echo "Done,UserName:${username} PassWord:${password} Address:${Address}"
		echo
		echo "Telegram : tg://socks?server=${Address}&port=1080&user=${username}&pass=${password}"
		echo "Shadowrocket : socks://${Shadowrocket_Address}"
	fi
}

DEL_USER(){
	echo "User List:"
	echo;cat -n /etc/opt/ss5/ss5.passwd;echo
	
	read -p "User ID that needs to be deleted:" DELETE_USER_ID
		if [[ ${DELETE_USER_ID} = "" ]];then
			echo "需要被删除的用户ID不能为空."
			echo "User ID that needs to be deleted cannot be null."
			exit
		else
			sed -i "${DELETE_USER_ID}d" /etc/opt/ss5/ss5.passwd
			service ss5 restart > /dev/null
		fi
		
	SHOW_SOCKS5
	echo "完成，该连接用户已被删除."
	echo "Completed, the connection user has been deleted."
}

INSTALL_CHECK(){
	if [ ! -e /usr/bin/socks5 ];then
		mv /root/socks5.sh /usr/bin/socks5
		chmod 755 /usr/bin/socks5
		socks5
	fi
}

command_1=${1}
command_2=${2}
command_3=${3}
command_4=${4}
INSTALL_CHECK

if [ -e /etc/opt/ss5/ss5.conf ];then
	case "${command_1}" in
		install)
			INSTALL_SOCKS5;;
		uninstall)
			UNINSTALL_SOCKS5;;
		user)
			clear
			case "${command_2}" in
				add)
					ADD_USER ${command_3} ${command_4};;
				del)
					DEL_USER;;
				*)
					echo "socks5 user del"
					echo "socks5 user add \$username \$password";;
			esac;;
		start)
			service ss5 start;;
		stop)
			service ss5 stop;;
		restart)
			service ss5 restart;;
		status)
			service ss5 status;;
		update)
			rm -rf /usr/bin/socks5
			wget -O /usr/bin/socks5 "https://raw.githubusercontent.com/qinghuas/socks5-install/master/socks5.sh"
			chmod 755 /usr/bin/socks5
			echo "Update Done.";;
		*)
			SHOW_SOCKS5
			echo "socks5 user {add|del}"
			echo "socks5 {install|uninstall|update}"
			echo "socks5 {start|stop|restart|status}";;
	esac
else
	case "${command_1}" in
		install)
			INSTALL_SOCKS5;;
		*)
			SHOW_SOCKS5
			echo "你必须先安装socks5,才能执行更多操作.使用命令 socks5 install 来安装."
			echo "You must first install socks5 to perform more operations. Use the command socks5 install to install."
			exit;;
	esac
fi

# END