# 注意
这是一个过时的项目，不再维护。但是，有更好的选择来快速创建一个socks5代理。访问 [gost doc](https://docs.ginuerzh.xyz/gost/socks/) 或 [brook doc](https://txthinking.github.io/brook/#/zh-cn/brook-socks5) 了解详细用法

# Socks5 Install
用于在 CentOS 6/7 系统上编译安装Socks5，以便在 Telegram 和 ShadowRocket 等客户端中使用

使用教程
---
```
yum -y install wget curl

wget https://raw.githubusercontent.com/qinghuas/socks5-install/master/socks5.sh;bash socks5.sh
```
![](https://i.loli.net/2018/03/25/5ab743d5c479b.png)

使用命令 `socks5 install` 来编译安装Socks5

![](https://i.loli.net/2018/03/25/5ab744d61c045.png)

使用命令 `socks5 user add` 来添加用户，具体参考如下提示

![](https://i.loli.net/2018/03/25/5ab744fd645cf.png)

示例，添加用户为admin，密码为123456的用户：`socks5 user add admin 123456`

![](https://i.loli.net/2018/03/25/5ab745b5b6960.png)

可以在应用程序内填入上述信息，或通过链接导入均可

更多命令
---
socks5 安装 / 卸载

`socks5 {install|uninstall}`

socks5 用户 添加 / 删除 / 列出

`socks5 user {add|del|list}`

socks5 启动 / 停止 / 重启 / 查看状态

`socks5 {start|stop|restart|status}`

socks5 更新 / 查看信息

`socks5 {update|info}`
