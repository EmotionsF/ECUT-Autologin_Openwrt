#!/bin/bash

# 更新 OpenWrt 软件包列表
echo "更新软件包列表..."
opkg update

# 安装 screen 和 Python 相关依赖
echo "安装 screen 和 Python3..."
opkg install screen python3 python3-pip git git-http

# 确保 pip 可用
echo "更新 pip..."
python3 -m ensurepip
python3 -m pip install --upgrade pip

# 安装 Python 依赖
echo "安装 PyYAML、numpy 和 requests..."
pip install pyyaml numpy requests

# 安装校园网自动登录程序
git clone https://github.com/EmotionsF/ECUT-Autologin_Openwrt.git
mv ECUT-Autologin_Openwrt ECUTS
mv ECUTS /opt


# 创建并配置 configs.yaml
CONFIG_FILE="/opt/ECUTS/configs.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "请输入校园网账号（自己的学号）:"
    read -p USERNAME < /dev/tty
    echo "请输入校园网密码（输入时看不到密码，属于正常现象）:"
    read -s -p PASSWORD < /dev/tty  # -s 选项隐藏输入

    # 提示选择运营商
    echo "请选择运营商（移动填 cmcc、电信填 telecom、联通填 unicom）："
    while true; do
        read -p OPERATOR < /dev/tty
        if [ "$OPERATOR" = "cmcc" ] || [ "$OPERATOR" = "telecom" ] || [ "$OPERATOR" = "unicom" ]; then
            echo "你选择的运营商是：$OPERATOR"
            break
        else
            echo "无效的选择，请输入 'cmcc'（移动）、'telecom'（电信）或 'unicom'（联通）："
        fi
    done

    # 创建 configs.yaml 文件
    echo "# 账号" > "$CONFIG_FILE"
    echo "user_account: \"$USERNAME\"" >> "$CONFIG_FILE"
    echo "# 运营商自己选择" >> "$CONFIG_FILE"
    echo "operator: \"$OPERATOR\"" >> "$CONFIG_FILE"
    echo "# 密码" >> "$CONFIG_FILE"
    echo "user_password: \"$PASSWORD\"" >> "$CONFIG_FILE"
    echo "" >> "$CONFIG_FILE"
    echo "# 填写示例" >> "$CONFIG_FILE"
    echo "# 账号" >> "$CONFIG_FILE"
    echo "# user_account: \"2020123456\"" >> "$CONFIG_FILE"
    echo "# 运营商自己选择" >> "$CONFIG_FILE"
    echo "# operator: 'cmcc'" >> "$CONFIG_FILE"
    echo "# 密码" >> "$CONFIG_FILE"
    echo "# user_password: \"1234abcdef\"" >> "$CONFIG_FILE"
    echo "" >> "$CONFIG_FILE"
    echo "# 注意，运营商需要从 'cmcc'（移动）、'telecom'（电信）、'unicom'（联通）中选择，其它选项均无效" >> "$CONFIG_FILE"

    echo "配置已保存到 $CONFIG_FILE"
else
    echo "检测到已有配置文件，跳过创建步骤。"
fi

# 创建 OpenWrt 开机启动脚本
echo "创建校园王自动登录并保持状态脚本..."
cat <<EOF > /etc/init.d/keeponline
#!/bin/sh /etc/rc.common
START=99

start() {
    echo "启动 screen 并运行 Python 脚本..."
    screen -dmS keeponline /usr/bin/python3 /opt/ECUTS/main.py
}
EOF

# 赋予执行权限
chmod +x /etc/init.d/keeponline

# 设置开机自启
echo "设置开机自启..."
/etc/init.d/keeponline enable

# 立即运行脚本
echo "立即运行脚本..."
/etc/init.d/keeponline start

echo "所有步骤完成！"
echo "现在可以打开百度试试了！"
