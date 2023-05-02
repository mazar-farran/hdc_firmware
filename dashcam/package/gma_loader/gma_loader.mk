################################################################################
#
# GMA_LOADER
#
################################################################################

GMA_LOADER_VERSION = 0.1.0
GMA_LOADER_SITE = https://github.com/streamingfast/gnss_assistnow_offline/releases/download/v$(GMA_LOADER_VERSION)
GMA_LOADER_SOURCE = gnss_assistnow_offline_$(GMA_LOADER_VERSION)_Linux_arm64.tar.gz
GMA_LOADER_STRIP_COMPONENTS = 0

define GMA_LOADER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/gma_loader $(TARGET_DIR)/opt/dashcam/bin
endef

define GMA_LOADER_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/gma_loader/gma_loader.service \
		$(TARGET_DIR)/usr/lib/systemd/system/gma_loader.service
endef

$(eval $(generic-package))
