# Socks5 Install
Telegram支持Socks5代理，设置好后就可以当“QQ”用了，网上的教程均是手动部署，而我能懒则懒，因此本脚本应运而生。脚本提供最基本的功能，即安装/卸载Socks5，增添/删除用户

安装
---
首先：   

Centos:
```
yum -y install git wget curl zip unzip screen;wget "https://raw.githubusercontent.com/qinghuas/socks5-install/master/ss5.sh"
```

Debian/Ubuntu:
```
apt-get -y install git wget curl zip unzip screen;wget "https://raw.githubusercontent.com/qinghuas/socks5-install/master/ss5.sh"
```

然后：  

```
bash ss5.sh
```

截图
---
![](https://raw.githubusercontent.com/qinghuas/socks5-install/master/socks5-install.png)

其他
---
1.可以在安装Socks5之前安装BBR/锐速来为Socks5加速  
2.Socks5安装完成后，需要添加用户才能使用
