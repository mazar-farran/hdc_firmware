################################################################################
#
# camera-scripts
#
################################################################################

CAMERA_SCRIPTS_VERSION = e0534c9ca656d4a90eea20b240a9d41f0b2f4a8d
CAMERA_SCRIPTS_SITE = ssh://git@bitbucket.org/chr1sniessl/capable_camera_firmware-mirror.git
CAMERA_SCRIPTS_SITE_METHOD = git
CAMERA_SCRIPTS_SUBDIR = scripts

define CAMERA_SCRIPTS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/scripts/* $(TARGET_DIR)/opt/dashcam/bin
endef

$(eval $(generic-package))
