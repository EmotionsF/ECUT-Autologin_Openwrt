# ECUT-Autologin_Openwrt
>-*- coding:utf-8 -*-</br>
> @author : washiobi3109@gmail.com</br>
> @Github : https://github.com/EmotionsF </br>
> @Time : 2025/03/27 15:20  </br>
东华理工大学校园网维持登录状态脚本的openwrt软路由版本

此脚本为软路由专用，用于维持软路由登录校园网的状态。
原项目链接：https://github.com/EmotionsF/ECUT_autologin-logout

本项目提供一键运行并安装脚本，无需手动下载文件。
一键安装脚本如下（直接复制并粘贴到openwrt控制台，按提示操作即可）：

```bash

wget -qO- https://raw.githubusercontent.com/EmotionsF/ECUT-Autologin_Openwrt/refs/heads/main/setup.sh | sh

```

若一键安装脚本安装失败，可逐行复制粘贴下列命令进行操作：

```bash

# 安装软件包相关依赖
opkg update
opkg install screen python3 python3-pip git git-http

# 更新python-pip版本确保python可用
python3 -m pip install --upgrade pip

# 安装python相关依赖
pip install pyyaml numpy requests

# 安装校园网自动登录程序
git clone https://github.com/EmotionsF/ECUT-Autologin_Openwrt.git
mv ECUT-Autologin_Openwrt ECUTS
mv ECUTS /opt

# 创建配置文件
vi /opt/ECUTS/configs.yaml

# 写入如下内容
user_account: "2020123456" # 改成你的校园网账号（学号）

operator: "cmcc" # 改成你校园网运营商（移动写"cmcc"，联通"unicom"，电信"telecom"）

user_password: "1234abcdef" # 改成你的校园网密码

# 启动screen让脚本后台运行
screen -dmS keeponline /usr/bin/python3 /opt/ECUTS/main.py

# 设置软路由开机自启
cat <<EOF > /etc/init.d/keeponline
#!/bin/sh /etc/rc.common
START=99

start() {
    echo "启动 screen 并运行 Python 脚本..."
    screen -dmS keeponline /usr/bin/python3 /opt/ECUTS/main.py
}
EOF

chmod +x /etc/init.d/keeponline
/etc/init.d/keeponline enable

```

