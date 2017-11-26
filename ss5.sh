#!/bin/bash

Check_OS(){
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

Install_Socks5(){
	#环境
	case "${release}" in
	centos)
		yum -y install iptables firewalld iptables-services
		yum -y install gcc zip git curl wget unzip screen net-tools pam-devel openssl-devel openldap-devel;;
	*)
		apt-get -y install iptables firewalld iptables-services
		apt-get -y install gcc zip git curl wget unzip screen net-tools pam-devel openssl-devel openldap-devel;;
	esac
	#安装
	wget -P /root "http://downloads.sourceforge.net/project/ss5/ss5/3.8.9-8/ss5-3.8.9-8.tar.gz"
	tar -xzvf ss5-3.8.9-8.tar.gz;cd ss5-3.8.9;./configure;make;make install
	#认证
	sed -i '87c auth    0.0.0.0/0               -              u' /etc/opt/ss5/ss5.conf
	sed -i '203c permit  u       0.0.0.0/0       -       0.0.0.0/0       -       -       -       -       -' /etc/opt/ss5/ss5.conf
	#配置
	sed -i '18c  [[ ${NETWORKING} = "no" ]] && exit 0' /etc/rc.d/init.d/ss5
	chmod u+x /etc/rc.d/init.d/ss5
	chkconfig --add ss5
	chkconfig ss5 on
	service ss5 start
	#删除
	rm -rf /root/ss5-3.8.9-8.tar.gz
}

ADD_USER(){
	read -p "连接用户:" USER_NAME
		if [[ ${USER_NAME} = '' ]];then
			echo "该项不允许为空.";exit 0
		fi
	read -p "连接密码:" USER_PASSWD
		if [[ ${USER_PASSWD} = '' ]];then
			echo "该项不允许为空.";exit 0
		fi
	echo "${USER_NAME} ${USER_PASSWD}" >> /etc/opt/ss5/ss5.passwd
	service ss5 start > /dev/null
	echo "添加完成,连接用户:${USER_NAME},连接密码:${USER_PASSWD}"
}

DELETE_USER(){
	echo "当前用户列表如下:"
	cat -n /etc/opt/ss5/ss5.passwd;echo
	
	read -p "请输入需要删除的连接用户ID:" DELETE_USER_ID
		if [[ ${DELETE_USER_ID} = '' ]];then
			echo "该项不允许为空.";exit 0
		fi
	sed -i "${DELETE_USER_ID}d" /etc/opt/ss5/ss5.passwd
	service ss5 start > /dev/null
	echo "已删除该连接用户."
}

Shut_down_iptables(){
	iptables -F;iptables -X
	iptables -I INPUT -p tcp -m tcp --dport 1:65535 -j ACCEPT
	iptables -I INPUT -p udp -m udp --dport 1:65535 -j ACCEPT
	iptables-save > /etc/sysconfig/iptables
	echo 'iptables-restore /etc/sysconfig/iptables' >> /etc/rc.local
}

Shut_down_firewall(){
	systemctl stop firewalld.service
	systemctl disable firewalld.service
}

Check_Install(){
	if [ ! -f /etc/opt/ss5/ss5.conf ];then
		echo "Socks5尚未安装.";exit 0
	fi
}

clear;echo "#############################
# 【安装/卸载】             #
# [1]安装Socks5             #
# [2]卸载Socks5             #
#############################
# 【用户管理】              #
# [3]添加用户               #
# [4]删除用户               #
#############################
# 【服务管理】              #
# [5]启动Socks5             #
# [6]停止Socks5             #
# [7]重启Socks5             #
# [8]查看运行状态           #
#############################
# 【其他选项】              #
# [9]安装fail2ban           #
#############################"
read -p "请选择选项:" SS5_Options

echo;case "${SS5_Options}" in
	1)
	Check_OS
	Install_Socks5
	Shut_down_iptables
	Shut_down_firewall;;
	2)
	Check_Install
	echo "该选项功能尚未完善.";;
	3)
	Check_Install
	ADD_USER;;
	4)
	Check_Install
	DELETE_USER;;
	5)
	Check_Install
	service ss5 start;;
	6)
	Check_Install
	service ss5 stop;;
	7)
	Check_Install
	service ss5 restart;;
	8)
	Check_Install
	service ss5 status;;
	9)
	if [ ! -f /root/fail2ban.sh ];then
		wget "https://raw.githubusercontent.com/qinghuas/ss-panel-and-ss-py-mu/master/tools/fail2ban.sh"
	fi
	bash fail2ban.sh;;
	*)
	echo "选项不在范围内.";;
esac

#END