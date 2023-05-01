################################################################################
#
# FILE_MOVER
#
################################################################################

FILE_MOVER_VERSION = 0.1.8
FILE_MOVER_SITE = https://github.com/streamingfast/file_mover/releases/download/v$(FILE_MOVER_VERSION)
FILE_MOVER_SOURCE = file_mover_$(FILE_MOVER_VERSION)_Linux_arm64.tar.gz
FILE_MOVER_STRIP_COMPONENTS = 0

define FILE_MOVER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/file_mover $(TARGET_DIR)/opt/dashcam/bin
endef

define FILE_MOVER_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/file_mover/file_mover.service \
		$(TARGET_DIR)/usr/lib/systemd/system/file_mover.service
endef

$(eval $(generic-package))
