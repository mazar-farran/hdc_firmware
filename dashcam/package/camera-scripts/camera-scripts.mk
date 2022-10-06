################################################################################
#
# camera-scripts
#
################################################################################

CAMERA_SCRIPTS_VERSION = 1dc49a9462bb77d888595558767e261c8c60c50f
CAMERA_SCRIPTS_SITE = ssh://git@bitbucket.org/chr1sniessl/capable_camera_firmware-mirror.git
CAMERA_SCRIPTS_SITE_METHOD = git
CAMERA_SCRIPTS_SUBDIR = scripts

define CAMERA_SCRIPTS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/scripts/* $(TARGET_DIR)/opt/dashcam/bin
endef

$(eval $(generic-package))
