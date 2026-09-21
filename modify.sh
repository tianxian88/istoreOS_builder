#!/bin/bash
# ========================================================
# 固件编译前定制脚本（支持自定义修改、预下载数据库与内核等）
# 注意：此时当前工作目录（PWD）是在 openwrt-ib 目录下
# ========================================================
# Force opkg to overwrite files
sed -i "s/install \$(BUILD_PACKAGES)/install \$(BUILD_PACKAGES) --force-overwrite/" Makefile
# 修改分区大小
sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/" .config
#删除docker
sed -i 's/CONFIG_PACKAGE_docker=y/# CONFIG_PACKAGE_docker is not set/' .config
sed -i 's/CONFIG_PACKAGE_dockerd=y/# CONFIG_PACKAGE_dockerd is not set/' .config
sed -i 's/CONFIG_PACKAGE_luci-app-dockerman=y/# CONFIG_PACKAGE_luci-app-dockerman is not set/' .config
sed -i 's/CONFIG_PACKAGE_luci-i18n-dockerman-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-dockerman-zh-cn is not set/' .config


echo "🔧 正在执行自定义高级预处理脚本..."

# 此时 PWD 是 openwrt-ib，所以上一层才是仓库根目录
REPO_FILES_DIR="../files"
OPENCLASH_DIR="${REPO_FILES_DIR}/etc/openclash"
CORE_DIR="${OPENCLASH_DIR}/core"

# 创建所需的本地目录结构
mkdir -p "${OPENCLASH_DIR}"
mkdir -p "${CORE_DIR}"

# --------------------------------------------------------
# 1. 批量下载 OpenClash 所需的 4 个核心数据库文件
# --------------------------------------------------------
echo "📥 正在下载 OpenClash 专属数据库组件..."

# [1/4] Country.mmdb (全球 IP 库 / Lite 版中国 IP 列表)
URL_MMDB="https://testingcf.jsdelivr.net/gh/alecthw/mmdb_china_ip_list@release/lite/Country.mmdb"
wget -qO "${OPENCLASH_DIR}/Country.mmdb" "$URL_MMDB"
[ -s "${OPENCLASH_DIR}/Country.mmdb" ] && echo "  ✅ Country.mmdb 下载成功！" || echo "  ❌ Country.mmdb 下载失败！"

# [2/4] geoip.dat (GeoIP 数据流)
URL_GEOIP="https://testingcf.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat"
wget -qO "${OPENCLASH_DIR}/geoip.dat" "$URL_GEOIP"
[ -s "${OPENCLASH_DIR}/geoip.dat" ] && echo "  ✅ geoip.dat 下载成功！" || echo "  ❌ geoip.dat 下载失败！"

# [3/4] geosite.dat (GeoSite 域名路由规则)
URL_GEOSITE="https://testingcf.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat"
wget -qO "${OPENCLASH_DIR}/geosite.dat" "$URL_GEOSITE"
[ -s "${OPENCLASH_DIR}/geosite.dat" ] && echo "  ✅ geosite.dat 下载成功！" || echo "  ❌ geosite.dat 下载失败！"

# [4/4] GeoLite2-ASN.mmdb (ASN 自主系统编号数据)
# 注意：OpenClash 本地识别的名字通常也是 GeoLite2-ASN.mmdb
URL_ASN="https://testingcf.jsdelivr.net/gh/xishang0128/geoip@release/GeoLite2-ASN.mmdb"
wget -qO "${OPENCLASH_DIR}/GeoLite2-ASN.mmdb" "$URL_ASN"
[ -s "${OPENCLASH_DIR}/GeoLite2-ASN.mmdb" ] && echo "  ✅ GeoLite2-ASN.mmdb 下载成功！" || echo "  ❌ GeoLite2-ASN.mmdb 下载失败！"

# --------------------------------------------------------
# 2. 下载 Mihomo (Clash Meta) 内核并预置 (单文件格式)
# --------------------------------------------------------
echo "📥 正在下载 Mihomo 内核 (单文件格式)..."
MIHOMO_URL="https://raw.githubusercontent.com/tianxian88/mihomo/refs/heads/main/bin/meta/clash-linux-amd64"

# 直接下载到目标位置，并重命名为 OpenClash 识别的 clash_meta
wget -qO "${CORE_DIR}/clash_meta" "$MIHOMO_URL"

if [ -s "${CORE_DIR}/clash_meta" ]; then
    # 【核心步骤】赋予内核可执行权限，否则在固件中无法启动
    chmod +x "${CORE_DIR}/clash_meta"
    echo "✅ Mihomo 内核下载成功，并已预置为 clash_meta！"
else
    echo "❌ Mihomo 内核下载失败，请检查网络链接！"
fi

# --------------------------------------------------------
# ⚠️ 注意：保持默认，不对 repositories.conf 进行干预
# --------------------------------------------------------

echo "✅ modify.sh 脚本全部执行完毕！"
