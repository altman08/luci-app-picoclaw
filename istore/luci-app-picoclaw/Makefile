include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-picoclaw
PKG_VERSION:=1.2.1
PKG_RELEASE:=1
PKG_LICENSE:=MIT

LUCI_TITLE:=LuCI support for PicoClaw AI Assistant
LUCI_DESCRIPTION:=LuCI web interface for managing PicoClaw service, channels, config, hardware, skills and cron jobs.
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+luci-compat +luci-lib-jsonc +curl

define Package/$(PKG_NAME)/prerm
	link="$${IPKG_INSTROOT}/usr/share/linkeasefull/desktop-apps.d/40-picoclaw.json"
	if [ "$$(readlink "$$link")" = "/usr/share/picoclaw/picoclaw-plugin.json" ]; then
		rm -f "$$link"
	fi
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
