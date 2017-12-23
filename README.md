# Socks5 Install
Telegram支持Socks5代理，设置好后就可以当“QQ”用了，网上的教程均是手动部署，而我能懒则懒，因此本脚本应运而生。脚本提供最基本的功能，即安装 / 卸载Socks5，添加 / 删除用户

准备
---
Centos
```
yum -y install git wget curl zip unzip screen
```
Debian/Ubuntu
```
apt-get -y install git wget curl zip unzip screen
```

安装
---
```
wget https://raw.githubusercontent.com/qinghuas/socks5-install/master/ss5.sh
```
```
bash ss5.sh
```

快捷选项
---
用户添加 / 删除  
`bash ss5.sh  user {add|del}`  

Socks5 安装 / 卸载  
`bash ss5.sh {install|uninstall}`  

Socks5 启动 / 停止 / 重启 / 状态  
`bash ss5.sh {start|stop|restart|status}`  

选项预览
---
![](https://raw.githubusercontent.com/qinghuas/socks5-install/master/socks5-install.png)

更新日志
---
`2017-12-23`  
- 增添功能快捷选项  

其他说明
---
1.可以在安装Socks5之前安装BBR/锐速来为Socks5加速  

2.Socks5安装完成后，需要添加用户才能使用
