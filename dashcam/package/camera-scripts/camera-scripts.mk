################################################################################
#
# camera-scripts
#
################################################################################

CAMERA_SCRIPTS_VERSION = 8ff2a042db7ae72e0392064c724b8fcc908f17ed
CAMERA_SCRIPTS_SITE = git@github.com:Hivemapper/capable_camera_firmware.git
CAMERA_SCRIPTS_SITE_METHOD = git
CAMERA_SCRIPTS_SUBDIR = scripts

define CAMERA_SCRIPTS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/scripts/* $(TARGET_DIR)/opt/dashcam/bin
endef

$(eval $(generic-package))
