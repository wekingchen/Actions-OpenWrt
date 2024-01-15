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

# 跟随最新版naiveproxy
rm -rf feeds/passwall_packages/naiveproxy
git clone -b v5 https://github.com/sbwml/openwrt_helloworld.git
cp -r openwrt_helloworld/naiveproxy feeds/passwall_packages
rm -rf openwrt_helloworld

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
git clone https://github.com/VictC79/luci-app-vssr.git package/luci-app-vssr

# 添加OpenClash
# cd package
# git init
# git remote add origin https://github.com/vernesong/OpenClash.git
# git config core.sparseCheckout true
# echo "luci-app-openclash/*" >> .git/info/sparse-checkout
# git pull origin master
# rm -rf .git
# cd ..

wget https://codeload.github.com/vernesong/OpenClash/zip/refs/heads/master -O OpenClash.zip
unzip OpenClash.zip
cp -r OpenClash-master/luci-app-openclash package/
rm -rf OpenClash.zip OpenClash-master

# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/luci-app-openclash/tools/po2lmo
make && sudo make install
popd
