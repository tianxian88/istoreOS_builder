#!/bin/bash
# ========================================================
# 固件编译前定制脚本（支持自定义修改、预下载数据库与内核等）
# 注意：此时当前工作目录（PWD）是在 openwrt-ib 目录下
# ========================================================
# Force opkg to overwrite files
sed -i "s/install \$(BUILD_PACKAGES)/install \$(BUILD_PACKAGES) --force-overwrite/" Makefile
# 修改分区大小
sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/" .config

echo "🔧 正在执行自定义高级预处理脚本..."

# 此时 PWD 是 openwrt-ib，所以上一层才是仓库根目录
echo "Current Path: $PWD"
cd ..
mkdir -p files/etc/openclash && cd files/etc/openclash

# --------------------------------------------------------
# 1. 批量下载 OpenClash 所需的 4 个核心数据库文件
# --------------------------------------------------------
echo "📥 正在下载 OpenClash 专属数据库组件..."

# [1/4] Country.mmdb
URL_MMDB="https://testingcf.jsdelivr.net/gh/alecthw/mmdb_china_ip_list@release/lite/Country.mmdb"
wget -qO "Country.mmdb" "$URL_MMDB"
[ -s "Country.mmdb" ] && echo "  ✅ Country.mmdb 下载成功！" || echo "  ❌ Country.mmdb 下载失败！"

# [2/4] geoip.dat
URL_GEOIP="https://testingcf.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat"
wget -qO "geoip.dat" "$URL_GEOIP"
[ -s "geoip.dat" ] && echo "  ✅ geoip.dat 下载成功！" || echo "  ❌ geoip.dat 下载失败！"

# [3/4] geosite.dat
URL_GEOSITE="https://testingcf.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat"
wget -qO "geosite.dat" "$URL_GEOSITE"
[ -s "geosite.dat" ] && echo "  ✅ geosite.dat 下载成功！" || echo "  ❌ geosite.dat 下载失败！"

# [4/4] GeoLite2-ASN.mmdb
URL_ASN="https://testingcf.jsdelivr.net/gh/xishang0128/geoip@release/GeoLite2-ASN.mmdb"
wget -qO "GeoLite2-ASN.mmdb" "$URL_ASN"
[ -s "GeoLite2-ASN.mmdb" ] && echo "  ✅ GeoLite2-ASN.mmdb 下载成功！" || echo "  ❌ GeoLite2-ASN.mmdb 下载失败！"

# --------------------------------------------------------
# 2. 下载 Mihomo (Clash Meta) 内核并预置 (单文件格式)
# --------------------------------------------------------
mkdir -p ./core && cd ./core
echo "📥 正在下载 Mihomo 内核 (单文件格式)..."
MIHOMO_URL="https://raw.githubusercontent.com/tianxian88/mihomo/refs/heads/main/bin/meta/clash-linux-amd64"

# 直接下载到当前目录，重命名为 OpenClash 识别的 clash_meta
wget -qO "clash_meta" "$MIHOMO_URL"

if [ -s "clash_meta" ]; then
    chmod +x "clash_meta"
    echo "✅ Mihomo 内核下载成功，并已预置为 clash_meta！"
else
    echo "❌ Mihomo 内核下载失败，请检查网络链接！"
fi

echo "✅ modify.sh 脚本全部执行完毕！"

