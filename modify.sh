#!/bin/bash
# ========================================================
# 固件编译前定制脚本（支持自定义修改、预下载数据库与内核等）
# 注意：此时当前工作目录（PWD）是在 openwrt-ib 目录下
# 我们需要把文件下载到上层目录的 files/ 中
# ========================================================

echo "🔧 正在执行自定义高级预处理脚本..."

# 定义上层仓库的 files 路径
REPO_FILES_DIR="../files"
OPENCLASH_DIR="\${REPO_FILES_DIR}/etc/openclash"
CORE_DIR="\${OPENCLASH_DIR}/core"

# 创建所需的本地目录结构
mkdir -p "\${CORE_DIR}"

# --------------------------------------------------------
# 1. 下载 OpenClash GeoIP 数据库 (Country.mmdb)
# --------------------------------------------------------
echo "📥 正在下载 GeoIP 数据库 (Country.mmdb)..."
# 使用 Loyalsoldier 维护的经典版本，或替换为你信任的源
GEOIP_URL="https://github.com"
wget -qO "\({OPENCLASH_DIR}/Country.mmdb" "\)GEOIP_URL"

if [ -s "\${OPENCLASH_DIR}/Country.mmdb" ]; then
    echo "✅ Country.mmdb 下载成功！"
else
    echo "❌ Country.mmdb 下载失败或文件为空，请检查链接！"
fi

# --------------------------------------------------------
# 2. 下载 Mihomo (Clash Meta) 内核并预置
# --------------------------------------------------------
echo "📥 正在下载 Mihomo 内核 (Meta 内核)..."
# 这里以 x86_64 架构、Linux 系统的最新稳定版为例。如果固件是给 ARM 设备编译，请修改为对应的架构（如 armv8/arm64）
MIHOMO_URL="https://github.com"

# 下载并直接解压出内核文件
wget -qO- "\(MIHOMO_URL" \vert{} tar -zxf - -C "\){CORE_DIR}"

# OpenClash 识别 Meta 内核的文件名必须是 `clash_meta`
if [ -f "\${CORE_DIR}/mihomo-linux-amd64-compatible" ]; then
    mv "\({CORE_DIR}/mihomo-linux-amd64-compatible" "\){CORE_DIR}/clash_meta"
    # 【核心步骤】赋予内核可执行权限，否则在固件中无法运行
    chmod +x "\${CORE_DIR}/clash_meta"
    echo "✅ Mihomo 内核下载并成功重命名为 clash_meta！"
else
    echo "❌ Mihomo 内核解压失败，请检查架构链接！"
fi

# --------------------------------------------------------
# 3. 其它自定义修改（例如可选的软件源替换等）
# --------------------------------------------------------
if [ -f "repositories.conf" ]; then
    echo "正在将官方软件源替换为腾讯云镜像源..."
    sed -i 's|https://koolcenter.com|https://tencent.com|g' repositories.conf
fi

echo "✅ modify.sh 脚本全部执行完毕！"
