# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=picoclaw
PKG_VERSION:=0.3.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/sipeed/picoclaw/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=df66f2f9a6fecf6f1396311b4a7881afc34d5f4209e2bebd6d91fb2b142d78d0

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_DEPENDS:=golang/host PACKAGE_picoclaw-launcher:node/host
PKG_CONFIG_DEPENDS:=CONFIG_PACKAGE_picoclaw-launcher
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
# Match the metadata injected by upstream GoReleaser. Keep these recursive:
# the host Go toolchain is installed only when the package is built.
GO_PKG_LDFLAGS_X=github.com/sipeed/picoclaw/pkg/config.Version=$(PKG_VERSION) \
	github.com/sipeed/picoclaw/pkg/config.GitCommit=2cf030d \
	github.com/sipeed/picoclaw/pkg/config.BuildTime=$(shell date -u $(if $(SOURCE_DATE_EPOCH),-d '@$(SOURCE_DATE_EPOCH)') +%Y-%m-%dT%H:%M:%SZ) \
	github.com/sipeed/picoclaw/pkg/config.GoVersion=$(shell $(STAGING_DIR_HOSTPKG)/lib/go-$(GO_HOST_VERSION)/bin/go env GOVERSION)

ifneq ($(CONFIG_PACKAGE_picoclaw-launcher),)
GO_PKG_BUILD_PKG+=$(GO_PKG)/web/backend
# Go's embed directives need the generated UI and tray icons as well as Go files.
GO_PKG_INSTALL_EXTRA+=web/backend/dist/ web/backend/icon
endif

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

# Upstream Linux releases are built without cgo, including the launcher.
GO_PKG_TARGET_VARS+=CGO_ENABLED=0
GO_PKG_DEFAULT_LDFLAGS:=-s -w

# The OpenWrt packages feed does not provide node-pnpm/host. Download the
# upstream-pinned CLI with a verified hash and run it using node/host.
PICOCLAW_PNPM_VERSION:=10.33.0
PICOCLAW_PNPM_SOURCE:=pnpm-$(PICOCLAW_PNPM_VERSION).tgz
PICOCLAW_PNPM=$(STAGING_DIR_HOSTPKG)/bin/node $(PKG_BUILD_DIR)/.pnpm/bin/pnpm.cjs

define Download/picoclaw-pnpm
  FILE:=$(PICOCLAW_PNPM_SOURCE)
  URL:=https://registry.npmjs.org/pnpm/-/
  HASH:=bfcc1bcbad279b13a516c446a75b3c58b6904b45d57a1951411015e50b751a80
endef

# Register downloads even before the SDK has selected binary subpackages.
$(eval $(call Download,picoclaw-pnpm))

ifneq ($(CONFIG_PACKAGE_picoclaw-launcher),)
define Build/Configure
	$(INSTALL_DIR) $(PKG_BUILD_DIR)/.pnpm
	$(HOST_TAR) -xzf $(DL_DIR)/$(PICOCLAW_PNPM_SOURCE) \
		-C $(PKG_BUILD_DIR)/.pnpm --strip-components=1
	cd $(PKG_BUILD_DIR)/web/frontend && \
		PATH="$(STAGING_DIR_HOSTPKG)/bin:$(PATH)" CI=true $(PICOCLAW_PNPM) install --frozen-lockfile
	cd $(PKG_BUILD_DIR)/web/frontend && \
		PATH="$(STAGING_DIR_HOSTPKG)/bin:$(PATH)" $(PICOCLAW_PNPM) build:backend
	$(call GoPackage/Build/Configure)
endef
endif

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

define Package/picoclaw-launcher
  SECTION:=net
  CATEGORY:=Network
  TITLE:=PicoClaw web launcher
  URL:=https://github.com/sipeed/picoclaw
  DEPENDS:=$(GO_ARCH_DEPENDS) +picoclaw
endef

define Package/picoclaw-launcher/description
 Optional PicoClaw web console with embedded frontend, configuration
 management and gateway process control. Run picoclaw-launcher -console
 -no-browser on headless systems.
endef

define Package/picoclaw/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/picoclaw $(1)/usr/bin/picoclaw
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/picoclaw.init $(1)/etc/init.d/picoclaw
endef

define Package/picoclaw-launcher/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/backend $(1)/usr/bin/picoclaw-launcher
endef

$(eval $(call GoBinPackage,picoclaw))
$(eval $(call BuildPackage,picoclaw))
$(eval $(call GoBinPackage,picoclaw-launcher))
$(eval $(call BuildPackage,picoclaw-launcher))
