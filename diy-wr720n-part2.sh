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
# sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# 去掉shadowsocksr-libev的libopenssl-legacy依赖支持
#sed -i 's/ +libopenssl-legacy//g' feeds/helloworld/shadowsocksr-libev/Makefile

# 修改golang源码以编译xray1.8.8+版本
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang
sed -i '/-linkmode external \\/d' feeds/packages/lang/golang/golang-package.mk

# 固定shadowsocks-rust版本以免编译失败
rm -rf feeds/helloworld/shadowsocks-rust
wget -P feeds/helloworld/shadowsocks-rust https://github.com/wekingchen/my-file/raw/master/shadowsocks-rust/Makefile

# 解决helloworld源缺少依赖问题
mkdir -p package/helloworld
git clone https://github.com/immortalwrt/packages.git
cp -r packages/net/pdnsd-alt package/helloworld/pdnsd-alt
cp -r packages/net/kcptun package/helloworld/kcptun
rm -rf packages
