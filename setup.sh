#!/bin/sh

# 更新 OpenWrt 软件包列表
echo "更新软件包列表..."
opkg update

# 安装 screen 和 Python 相关依赖
echo "安装 screen 和 Python3..."
opkg install screen python3 python3-pip

# 确保 pip 可用
echo "更新 pip..."
python3 -m ensurepip
python3 -m pip install --upgrade pip

# 安装 Python 依赖
echo "安装 PyYAML、numpy 和 requests..."
pip install pyyaml numpy requests

# 安装校园网自动登录程序


# 创建 OpenWrt 开机启动脚本
echo "创建启动脚本..."
cat <<EOF > /etc/init.d/myscript
#!/bin/sh /etc/rc.common
START=99

start() {
    echo "启动 screen 并运行 Python 脚本..."
    screen -dmS myscript /usr/bin/python3 /opt/ECUT/main.py
}
EOF

# 赋予执行权限
chmod +x /etc/init.d/myscript

# 设置开机自启
echo "设置开机自启..."
/etc/init.d/myscript enable

# 立即运行脚本
echo "立即运行脚本..."
/etc/init.d/myscript start

echo "所有步骤完成！"
