################################################################################
#
# camera-scripts
#
################################################################################

CAMERA_SCRIPTS_VERSION = ebc79d8f1183a4428a46f97ad30df6a9e56d9af3
CAMERA_SCRIPTS_SITE = git@github.com:Hivemapper/capable_camera_firmware.git
CAMERA_SCRIPTS_SITE_METHOD = git
CAMERA_SCRIPTS_SUBDIR = scripts

define CAMERA_SCRIPTS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/scripts/* $(TARGET_DIR)/opt/dashcam/bin
endef

$(eval $(generic-package))
