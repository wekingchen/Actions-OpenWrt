#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 修复 helloworld 新版 GN 在 Ubuntu 22.04 上的 host 编译兼容问题
GN_MAKEFILE="feeds/helloworld/gn/Makefile"

if [ -f "$GN_MAKEFILE" ] && ! grep -q 'CC=gcc-12 CXX=g++-12 AR=ar' "$GN_MAKEFILE"; then
    sed -i '/$(PYTHON).*build\/gen.py/ s|$(PYTHON)|CC=gcc-12 CXX=g++-12 AR=ar $(PYTHON)|' "$GN_MAKEFILE"
fi

# Modify default IP
sed -i 's/192.168.1.1/10.10.10.252/g' package/base-files/files/bin/config_generate
sed -i 'set network.$1.gateway='10.10.10.251'' package/base-files/files/bin/config_generate

rm -rf feeds/packages/net/xray-core
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/packages/net/sing-box
rm -rf feeds/packages/net/chinadns-ng
rm -rf feeds/packages/net/dns2socks
# rm -rf feeds/packages/net/dns2tcp
rm -rf feeds/packages/net/microsocks
cp -r feeds/passwall_packages/xray-core feeds/packages/net
cp -r feeds/passwall_packages/v2ray-geodata feeds/packages/net
cp -r feeds/passwall_packages/sing-box feeds/packages/net
cp -r feeds/passwall_packages/chinadns-ng feeds/packages/net
cp -r feeds/passwall_packages/dns2socks feeds/packages/net
# cp -r feeds/passwall_packages/dns2tcp feeds/packages/net
cp -r feeds/passwall_packages/microsocks feeds/packages/net

# 修改golang源码以编译xray26.9.9+版本
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 27.x feeds/packages/lang/golang
sed -i '/-linkmode external \\/d' feeds/packages/lang/golang/golang-package.mk

# =====================================================================
# 自动更新 FRP 到官方最新稳定版
# =====================================================================
FRP_DIR="feeds/packages/net/frp"
FRP_MAKEFILE="$FRP_DIR/Makefile"

FRP_VERSION="$(
    git ls-remote --tags --refs https://github.com/fatedier/frp.git \
    | sed -n 's#.*refs/tags/v\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)$#\1#p' \
    | sort -V \
    | tail -1
)"

curl -fL "https://codeload.github.com/fatedier/frp/tar.gz/v${FRP_VERSION}" \
    -o /tmp/frp.tar.gz

FRP_HASH="$(sha256sum /tmp/frp.tar.gz | cut -d' ' -f1)"

sed -i -E "s/^PKG_VERSION:=.*/PKG_VERSION:=${FRP_VERSION}/" "$FRP_MAKEFILE"
sed -i -E "s/^PKG_HASH:=.*/PKG_HASH:=${FRP_HASH}/" "$FRP_MAKEFILE"

# FRP 0.68.0+ 官方支持 noweb
if grep -q '^GO_PKG_TAGS:=' "$FRP_MAKEFILE"; then
    sed -i -E 's/^GO_PKG_TAGS:=.*/GO_PKG_TAGS:=noweb/' "$FRP_MAKEFILE"
else
    sed -i '/^GO_PKG_BUILD_PKG:=/a GO_PKG_TAGS:=noweb' "$FRP_MAKEFILE"
fi

# 当前旧版 OpenWrt recipe 会强制执行 npm/Web 编译，
# noweb 模式下改为只执行 Go 编译
sed -i '/^define Build\/Compile$/,/^endef$/c\
define Build/Compile\
	$(call GoPackage/Build/Compile)\
endef' "$FRP_MAKEFILE"

rm -f /tmp/frp.tar.gz

# =====================================================================
# 自动更新 Tailscale 到官方最新稳定版
# =====================================================================
TAILSCALE_MAKEFILE="feeds/packages/net/tailscale/Makefile"
TAILSCALE_VERSION="$(git ls-remote --tags --refs https://github.com/tailscale/tailscale.git | sed -n 's#.*refs/tags/v\([0-9.]*\)$#\1#p' | sort -V | tail -1)"

curl -fL "https://codeload.github.com/tailscale/tailscale/tar.gz/v${TAILSCALE_VERSION}" -o /tmp/tailscale.tar.gz
TAILSCALE_HASH="$(sha256sum /tmp/tailscale.tar.gz | cut -d' ' -f1)"

sed -i -E "s/^PKG_VERSION:=.*/PKG_VERSION:=${TAILSCALE_VERSION}/" "$TAILSCALE_MAKEFILE"
sed -i -E "s/^PKG_HASH:=.*/PKG_HASH:=${TAILSCALE_HASH}/" "$TAILSCALE_MAKEFILE"

rm -rf feeds/packages/net/tailscale/patches /tmp/tailscale.tar.gz

# 解决helloworld源缺少依赖问题
mkdir -p package/helloworld
git clone https://github.com/immortalwrt/packages.git
cp -r packages/net/dns2socks package/helloworld/dns2socks
cp -r packages/net/microsocks package/helloworld/microsocks
cp -r packages/net/ipt2socks package/helloworld/ipt2socks
cp -r packages/net/pdnsd-alt package/helloworld/pdnsd-alt
cp -r packages/net/redsocks2 package/helloworld/redsocks2
rm -rf packages

# 添加luci-app-adguardhome代码
git clone https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# 添加go-aliyundrive-webdav代码
git clone https://github.com/jerrykuku/go-aliyundrive-webdav package/go-aliyundrive-webdav
git clone https://github.com/jerrykuku/luci-app-go-aliyundrive-webdav package/luci-app-go-aliyundrive-webdav

# 添加aliyundrive-webdav
rm -rf feeds/packages/multimedia/aliyundrive-webdav
rm -rf feeds/luci/applications/luci-app-aliyundrive-webdav
git clone https://github.com/messense/aliyundrive-webdav.git
cp -r aliyundrive-webdav/openwrt/aliyundrive-webdav feeds/packages/multimedia
cp -r aliyundrive-webdav/openwrt/luci-app-aliyundrive-webdav feeds/luci/applications
rm -rf aliyundrive-webdav

# 添加Hello World
git clone https://github.com/jerrykuku/lua-maxminddb.git package/lua-maxminddb
git clone https://github.com/dqylyln/luci-app-vssr.git package/luci-app-vssr

# 添加Cloudflared Zero Trust Tunnel
git clone https://github.com/openwrt/luci.git openwrt-luci
cp -r openwrt-luci/applications/luci-app-cloudflared package/
sed -i 's|include ../../luci.mk|include $(TOPDIR)/feeds/luci/luci.mk|' package/luci-app-cloudflared/Makefile
rm -rf openwrt-luci
git clone https://github.com/openwrt/packages.git openwrt-packages
rm -rf feeds/packages/net/cloudflared
cp -r openwrt-packages/net/cloudflared feeds/packages/net
rm -rf openwrt-packages
./scripts/feeds install -f luci-app-cloudflared

# 添加OpenClash
wget https://codeload.github.com/vernesong/OpenClash/zip/refs/heads/master -O OpenClash.zip
unzip OpenClash.zip
cp -r OpenClash-master/luci-app-openclash package/
rm -rf OpenClash.zip OpenClash-master

# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/luci-app-openclash/tools/po2lmo
make && sudo make install
popd
