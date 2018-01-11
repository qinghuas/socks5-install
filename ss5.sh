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
	if [ ! -f /etc/opt/ss5/ss5.conf ];then
		echo "Socks5 not installed yet.";exit
	fi
}

ADD_USER(){
	INSTALL_CHECK
	read -p "Enter the connection user:" USER_NAME
		if [[ ${USER_NAME} = '' ]];then
			echo "This item is not allowed to be blank.";exit
		fi
	read -p "Enter the connection password:" USER_PASSWD
		if [[ ${USER_PASSWD} = '' ]];then
			echo "This item is not allowed to be blank.";exit
		fi
	echo "${USER_NAME} ${USER_PASSWD}" >> /etc/opt/ss5/ss5.passwd
	service ss5 start > /dev/null
	
	IP_ADDRESS=`curl -s https://ipv4.appspot.com`
	echo "Connection address:${IP_ADDRESS} | Connection port:1080 | Connection user:${USER_NAME} | Connection password:${USER_PASSWD}"
}

DELETE_USER(){
	INSTALL_CHECK
	echo "Current users information:"
	cat -n /etc/opt/ss5/ss5.passwd;echo
	
	read -p "User ID to delete:" DELETE_USER_ID
		if [[ ${DELETE_USER_ID} = '' ]];then
			echo "This item is not allowed to be blank.";exit
		fi
		
	sed -i "${DELETE_USER_ID}d" /etc/opt/ss5/ss5.passwd
	service ss5 start > /dev/null
	echo "User deleted."
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
	
	#Turn off the firewall (iptables,firewalld)
	CLOSE_THE_FIREWALL
	
	chmod u+x /etc/rc.d/init.d/ss5
	chkconfig --add ss5
	chkconfig ss5 on
	service ss5 start
}

UNINSTALL_SOCKS5(){
	INSTALL_CHECK
	cd ss5-3.8.9
	make uninstall
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
# 【Install/Uninstall】           #
# [1]Install Socks5              #
# [2]Uninstall Socks5            #
##################################
# 【User Management】             #
# [3]Add user                    #
# [4]Delete user                 #
##################################
# 【Service management】          #
# [5]Start Socks5                #
# [6]Stop Socks5                 #
# [7]Restart Socks5              #
# [8]Check the running status    #
##################################
# 【Other options】               #
# [a]Install BBR                 #
# [b]Install sharpness           #
# [c]Install fail2ban            #
##################################"
read -p "Please select an option:" OPTIONS

case "${OPTIONS}" in
	1)
	CHECK_OS
	INSTALL_SOCKS5;;
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
	echo;echo "Option out of range.";;
esac
}

SOCKS_OPTIONS=$1
SOCKS_OPTIONS_TWO=$2

#s5 {start|stop|restart|status}
if [[ ${SOCKS_OPTIONS} = "start" ]];then
	INSTALL_CHECK;service ss5 start;echo "Done."
elif [[ ${SOCKS_OPTIONS} = "stop" ]];then
	INSTALL_CHECK;service ss5 stop;echo "Done."
elif [[ ${SOCKS_OPTIONS} = "restart" ]];then
	INSTALL_CHECK;service ss5 restart;echo "Done."
elif [[ ${SOCKS_OPTIONS} = "status" ]];then
	INSTALL_CHECK;service ss5 status
elif [[ ${SOCKS_OPTIONS} = "install" ]];then
	CHECK_OS;INSTALL_SOCKS5
elif [[ ${SOCKS_OPTIONS} = "uninstall" ]];then
	INSTALL_CHECK;UNINSTALL_SOCKS5
elif [[ ${SOCKS_OPTIONS} = "user" ]];then
	if [[ ${SOCKS_OPTIONS_TWO} = "add" ]];then
		clear;ADD_USER
	elif [[ ${SOCKS_OPTIONS_TWO} = "del" ]];then
		clear;DELETE_USER
	fi
else
	INTERACTION
fi

#END
