################################################################################
#
# camera-scripts
#
################################################################################

CAMERA_SCRIPTS_VERSION = 835f523737781363d6b8871f093cda6c1fcf3eed
CAMERA_SCRIPTS_SITE = git@github.com:Hivemapper/capable_camera_firmware.git
CAMERA_SCRIPTS_SITE_METHOD = git
CAMERA_SCRIPTS_SUBDIR = scripts

define CAMERA_SCRIPTS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/scripts/* $(TARGET_DIR)/opt/dashcam/bin
endef

$(eval $(generic-package))
