# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=picoclaw
PKG_VERSION:=0.3.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/sipeed/picoclaw/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=df66f2f9a6fecf6f1396311b4a7881afc34d5f4209e2bebd6d91fb2b142d78d0

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/sipeed/picoclaw
GO_PKG_BUILD_PKG:=$(GO_PKG)/cmd/picoclaw
# The module-root embed requires the onboarding Markdown templates.
GO_PKG_INSTALL_EXTRA:=workspace/
GO_PKG_TAGS:=goolm stdjson
ifneq ($(filter mips mipsel mipsle,$(ARCH)),)
GO_PKG_TAGS:=stdjson
endif
GO_PKG_LDFLAGS_X:=github.com/sipeed/picoclaw/pkg/config.Version=v$(PKG_VERSION) \
	github.com/sipeed/picoclaw/pkg/config.GitCommit=2cf030d

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/picoclaw
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Lightweight personal AI assistant
  URL:=https://github.com/sipeed/picoclaw
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/picoclaw/description
 PicoClaw core CLI and gateway for messaging channels, tools and local
 automation. Managed by procd; no web launcher is included.
endef

define Package/picoclaw/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/picoclaw.init $(1)/etc/init.d/picoclaw
endef

$(eval $(call GoBinPackage,picoclaw))
$(eval $(call BuildPackage,picoclaw))
