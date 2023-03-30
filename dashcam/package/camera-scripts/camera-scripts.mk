################################################################################
#
# camera-scripts
#
################################################################################

CAMERA_SCRIPTS_VERSION = 63f0953022bc5ccc515045e0cebfccd5677f263a
CAMERA_SCRIPTS_SITE = git@github.com:Hivemapper/capable_camera_firmware.git
CAMERA_SCRIPTS_SITE_METHOD = git
CAMERA_SCRIPTS_SUBDIR = scripts

define CAMERA_SCRIPTS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/scripts/* $(TARGET_DIR)/opt/dashcam/bin
endef

$(eval $(generic-package))
