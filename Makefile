include $(TOPDIR)/rules.mk

PKG_NAME:=ifmqtoggle
PKG_VERSION:=1.1.0
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

SRC_DIR=./src

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=network
  CATEGORY:=Network
  TITLE:=Network Interface MQTT Toggle
  DEPENDS:=+jq +mosquitto-client-ssl
  PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
  Service listening for MQTT messages to toggle a network interface.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(SRC_DIR)/ifmqtoggle $(1)/usr/bin/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) $(SRC_DIR)/config $(1)/etc/config/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(SRC_DIR)/init $(1)/etc/init.d/$(PKG_NAME)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
