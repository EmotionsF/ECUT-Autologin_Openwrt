#!/bin/sh

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
    read USERNAME
    echo "请输入校园网密码（输入时看不到密码，属于正常现象）:"
    read -s PASSWORD  # -s 选项隐藏输入

    # 提示选择运营商
    echo "请选择运营商（移动填 cmcc、电信填 telecom、联通填 unicom）："
    while true; do
        read OPERATOR
        case $OPERATOR in
            cmcc|telecom|unicom)
                echo "你选择的运营商是：$OPERATOR"
                break
                ;;
            *)
                echo "无效的选择，请输入 'cmcc'（移动）、'telecom'（电信）或 'unicom'（联通）："
                ;;
        esac
    done

    # 创建 configs.yaml 文件
    cat <<EOF > "$CONFIG_FILE"
# 账号
user_account: "$USERNAME"
# 运营商自己选择
operator: "$OPERATOR"
# 密码
user_password: "$PASSWORD"

# 填写示例
# 账号
# user_account: "2020123456"
# 运营商自己选择
# operator: 'cmcc'
# 密码
# user_password: "1234abcdef"

# 注意，运营商需要从 'cmcc'（移动）、'telecom'（电信）、'unicom'（联通）中选择，其它选项均无效
EOF

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
