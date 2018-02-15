#!/bin/bash

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

INSTALL_CHECK(){
	if [ ! -e /etc/opt/ss5/ss5.conf ];then
		echo "Socks5尚未安装.";exit
	fi
}

ADD_USER(){
	INSTALL_CHECK
	read -p "请设置连接用户:" USER_NAME
		if [[ ${USER_NAME} = '' ]];then
			echo "该项不允许为空.";exit
		fi
	read -p "请设置连接密码:" USER_PASSWD
		if [[ ${USER_PASSWD} = '' ]];then
			echo "该项不允许为空.";exit
		fi
	echo "${USER_NAME} ${USER_PASSWD}" >> /etc/opt/ss5/ss5.passwd
	service ss5 start > /dev/null
	
	IP_ADDRESS=$(curl -s ipv4.ip.sb)
	echo "连接地址:${IP_ADDRESS} 连接端口:1080 连接用户:${USER_NAME},连接密码:${USER_PASSWD}"
}

DELETE_USER(){
	INSTALL_CHECK
	echo "当前用户如下:"
	cat -n /etc/opt/ss5/ss5.passwd;echo
	
	read -p "需要删除的用户ID:" DELETE_USER_ID
		if [[ ${DELETE_USER_ID} = '' ]];then
			echo "该项不允许为空.";exit
		fi
		
	sed -i "${DELETE_USER_ID}d" /etc/opt/ss5/ss5.passwd
	service ss5 start > /dev/null
	echo "删除完成."
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
		systemctl stop firewalld.service
		systemctl disable firewalld.service
	}

	case "${release}" in
	centos)
		CLOSE_THE_IPTABLES
		CLOSE_THE_FIREWALLD;;
	*)
		CLOSE_THE_IPTABLES;;
	esac
}

INSTALL_SOCKS5(){
	CHECK_OS
	case "${release}" in
	centos)
		yum -y install iptables firewalld iptables-services
		yum -y install gcc zip git curl wget unzip screen net-tools pam-devel openssl-devel openldap-devel;;
	*)
		apt-get -y install iptables iptables-services
		apt-get -y install gcc zip git curl wget unzip screen net-tools pam-devel openssl-devel openldap-devel;;
	esac

	wget -P /root "http://downloads.sourceforge.net/project/ss5/ss5/3.8.9-8/ss5-3.8.9-8.tar.gz"
	tar -xzvf ss5-3.8.9-8.tar.gz;cd ss5-3.8.9;./configure;make;make install;rm -rf /root/ss5-3.8.9-8.tar.gz
	sed -i '87c auth    0.0.0.0/0               -              u' /etc/opt/ss5/ss5.conf
	sed -i '203c permit  u       0.0.0.0/0       -       0.0.0.0/0       -       -       -       -       -' /etc/opt/ss5/ss5.conf
	sed -i '18c  [[ ${NETWORKING} = "no" ]] && exit 0' /etc/rc.d/init.d/ss5
	
	#关闭防火墙(iptables,firewalld)
	CLOSE_THE_FIREWALL
	
	chmod u+x /etc/rc.d/init.d/ss5
	chkconfig --add ss5
	chkconfig ss5 on
	service ss5 start
	
	echo;echo "Socks5已经安装完成了,添加用户后,便可使用."
}

UNINSTALL_SOCKS5(){
	if [ -e /etc/opt/ss5/ss5.conf ];then
		read -p "确认卸载Socks5? [y/n]:" REPLY
		case "${REPLY}" in
			y)
				echo "卸载中..."
				cd /root/ss5-3.8.9
				make uninstall
				rm -rf /root/ss5-3.8.9
				echo "卸载完成.";;
			*)
				echo "取消卸载.";;
		esac
	else
		echo "Socks5尚未安装哦."
	fi
}

INSTALL_BBR(){
	wget --no-check-certificate "https://github.com/teddysun/across/raw/master/bbr.sh"
	chmod +x bbr.sh
	./bbr.sh
}

INSTALL_SERVERSPEEDER(){
	wget -N --no-check-certificate "https://github.com/91yun/serverspeeder/raw/master/serverspeeder.sh"
	bash serverspeeder.sh
}

INSTALL_FAIL2BAN(){
	wget "https://raw.githubusercontent.com/FunctionClub/Fail2ban/master/fail2ban.sh"
	bash fail2ban.sh
}

INTERACTION(){
clear;echo "##################################
# 【安装/卸载】                  #
# [1]安装Socks5                  #
# [2]卸载Socks5                  #
##################################
# 【用户管理】                   #
# [3]添加用户                    #
# [4]删除用户                    #
##################################
# 【服务管理】                   #
# [5]启动Socks5                  #
# [6]停止Socks5                  #
# [7]重启Socks5                  #
# [8]查看运行状态                #
##################################
# 【其他选项】                   #
# [a]安装BBR                     #
# [b]安装锐速                    #
# [c]安装fail2ban                #
##################################"
read -p "请选择选项:" OPTIONS

case "${OPTIONS}" in
	1)
	if [ -e /etc/opt/ss5/ss5.conf ];then
		echo "Socks5已经安装了.";exit
	else
		INSTALL_SOCKS5
	fi;;
	2)
	UNINSTALL_SOCKS5;;
	3)
	ADD_USER;;
	4)
	DELETE_USER;;
	5)
	INSTALL_CHECK
	service ss5 start;;
	6)
	INSTALL_CHECK
	service ss5 stop;;
	7)
	INSTALL_CHECK
	service ss5 restart;;
	8)
	INSTALL_CHECK
	service ss5 status;;
	a)
	INSTALL_BBR;;
	b)
	INSTALL_SERVERSPEEDER;;
	c)
	INSTALL_FAIL2BAN;;
	*)
	echo;echo "选项不在范围.";;
esac
}

case "${1}" in
	start)
		INSTALL_CHECK
		service ss5 start
		echo "Done.";;
	stop)
		INSTALL_CHECK
		service ss5 stop
		echo "Done.";;
	restart)
		INSTALL_CHECK
		service ss5 restart
		echo "Done.";;
	status)
		INSTALL_CHECK
		service ss5 status;;
	install)
		if [ -e /etc/opt/ss5/ss5.conf ];then
			echo "Socks5已经安装了.";exit
		else
			INSTALL_SOCKS5
		fi;;
	uninstall)
		UNINSTALL_SOCKS5;;
	user)
		case "${2}" in
			add)
				clear;ADD_USER;;
			del)
				clear;DELETE_USER;;
			*)
				echo "bash ss5.sh user {add|del}";;
		esac;;
	*)
		INTERACTION;;
esac

#END 2018-02-15
