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

# 修改golang源码以编译xray1.8.8+版本
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang
sed -i '/-linkmode external \\/d' feeds/packages/lang/golang/golang-package.mk

rm -rf feeds/packages/net/frp && \
wget https://github.com/coolsnowwolf/packages/archive/0f7be9fc93d68986c179829d8199824d3183eb60.zip -O OldPackages.zip && \
unzip OldPackages.zip && \
cp -r packages-0f7be9fc93d68986c179829d8199824d3183eb60/net/frp feeds/packages/net/ && \
rm -rf OldPackages.zip packages-0f7be9fc93d68986c179829d8199824d3183eb60

# 修改frp版本为官网最新v0.65.0 https://github.com/fatedier/frp 格式：https://codeload.github.com/fatedier/frp/tar.gz/v${PKG_VERSION}?
sed -i 's/PKG_VERSION:=0.53.2/PKG_VERSION:=0.65.0/' feeds/packages/net/frp/Makefile
sed -i 's/PKG_HASH:=ff2a4f04e7732bc77730304e48f97fdd062be2b142ae34c518ab9b9d7a3b32ec/PKG_HASH:=bbec0d1855e66c96e3a79ff97b8c74d9b1b45ec560aa7132550254d48321f7de/' feeds/packages/net/frp/Makefile

# 修改tailscale版本为官网最新v1.86.2 https://github.com/tailscale/tailscale 格式：https://codeload.github.com/tailscale/tailscale/tar.gz/v$(PKG_VERSION)?
sed -i 's/PKG_VERSION:=1.84.2/PKG_VERSION:=1.86.2/' feeds/packages/net/tailscale/Makefile
sed -i 's/PKG_HASH:=32673e5552e1176f1028a6a90a4c892d2475c92d1e952ca16156dc523d14d914/PKG_HASH:=9b7fe9f915744ca1448efeb88d7333b7a86df375a4623941d2e41880c51c0aec/' feeds/packages/net/tailscale/Makefile
rm -rf feeds/packages/net/tailscale/patches

# 跟随最新版naiveproxy
# rm -rf feeds/passwall_packages/naiveproxy
# rm -rf feeds/helloworld/naiveproxy
# git clone -b v5 https://github.com/sbwml/openwrt_helloworld.git
# cp -r openwrt_helloworld/naiveproxy feeds/passwall_packages
# cp -r openwrt_helloworld/naiveproxy feeds/helloworld
# rm -rf openwrt_helloworld

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

# 固定shadowsocks-rust版本以免编译失败
# rm -rf feeds/helloworld/shadowsocks-rust
# wget -P feeds/helloworld/shadowsocks-rust https://github.com/wekingchen/my-file/raw/master/shadowsocks-rust/Makefile
# rm -rf feeds/passwall_packages/shadowsocks-rust
# wget -P feeds/passwall_packages/shadowsocks-rust https://github.com/wekingchen/my-file/raw/master/shadowsocks-rust/Makefile

# 添加OpenClash
wget https://codeload.github.com/vernesong/OpenClash/zip/refs/heads/master -O OpenClash.zip
unzip OpenClash.zip
cp -r OpenClash-master/luci-app-openclash package/
rm -rf OpenClash.zip OpenClash-master

# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/luci-app-openclash/tools/po2lmo
make && sudo make install
popd
