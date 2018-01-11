# Socks5 Install
Telegram support Socks5 proxy, set up can be used as "QQ", the online tutorials are manually deployed, and I lazy lazy, so this script came into being. Scripting provides the most basic features, namely, install / uninstall Socks5, add / delete users

Requirements
---
Centos
```
yum -y install git wget curl zip unzip screen
```
Debian/Ubuntu
```
apt-get -y install git wget curl zip unzip screen
```

Installation
---
```
wget https://raw.githubusercontent.com/AmirSbss/socks5-install/master/ss5.sh
```
```
bash ss5.sh
```

Shortcut options
---
Add/Delete user
`bash ss5.sh  user {add|del}`  

Socks5 install/uninstall  
`bash ss5.sh {install|uninstall}`  

Socks5 start/stop/restart/status  
`bash ss5.sh {start|stop|restart|status}`  

Options preview
---
![](https://raw.githubusercontent.com/AmirSbss/socks5-install/master/ss5-options.png)

Update log
---
`2017-12-23`  
- Added shortcut options  

Other instructions
---
1.You can install Socks5 before installing BBR / Sphinx speed to accelerate

2.You need to add users to use Socks5
