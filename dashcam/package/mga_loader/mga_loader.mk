################################################################################
#
# MGA_L
#
################################################################################

MGA_LOADER_VERSION = 0.1.6
MGA_LOADER_SITE = https://github.com/streamingfast/gnss_assistnow_offline/releases/download/v$(MGA_LOADER_VERSION)
MGA_LOADER_SOURCE = gnss_assistnow_offline_$(MGA_LOADER_VERSION)_Linux_arm64.tar.gz
MGA_LOADER_STRIP_COMPONENTS = 0

define MGA_LOADER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/mga_loader $(TARGET_DIR)/opt/dashcam/bin
endef

define MGA_LOADER_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/mga_loader/mga_loader.service \
		$(TARGET_DIR)/usr/lib/systemd/system/mga_loader.service
endef

$(eval $(generic-package))
