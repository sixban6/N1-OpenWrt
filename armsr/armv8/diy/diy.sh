#!/bin/bash

# Adjust source code
patch -p1 -f < $(dirname "$0")/luci.patch

# Add packages
# 1. 下载原有插件
git clone https://github.com/ophub/luci-app-amlogic --depth=1 clone/amlogic
git clone https://github.com/Openwrt-Passwall/openwrt-passwall --depth=1 clone/passwall

# 2. 新增：下载 ImmortalWrt 经典主题 (Argon)
git clone https://github.com/jerrykuku/luci-theme-argon.git --depth=1 clone/luci-theme-argon
# 可选：如果你想要配置主题背景和颜色的插件，可以把下面这行注释取消掉
# git clone https://github.com/jerrykuku/luci-app-argon-config.git --depth=1 clone/luci-app-argon-config

# Update packages
# 3. 清理旧包
rm -rf feeds/luci/applications/luci-app-passwall
# 新增：先删除 feeds 里可能存在的旧版 argon，防止编译冲突
rm -rf feeds/luci/themes/luci-theme-argon

# 4. 移动新包到 feeds 目录
cp -rf clone/amlogic/luci-app-amlogic clone/passwall/luci-app-passwall feeds/luci/applications/
# 新增：移动 Argon 主题到 themes 目录
cp -rf clone/luci-theme-argon feeds/luci/themes/
# 可选：如果上面下载了 argon-config，这里也要移动
# cp -rf clone/luci-app-argon-config feeds/luci/applications/

sed -i '/luci-app-attendedsysupgrade/d' feeds/luci/collections/luci/Makefile

# Clean packages
rm -rf clone
