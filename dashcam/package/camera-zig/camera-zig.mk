################################################################################
#
# camera-zig
#
################################################################################

CAMERA_ZIG_VERSION = 0600b5bf1354d1ed577135641df956fd47df4525
CAMERA_ZIG_SITE = $(call github,CapableRobot,capable_camera_firmware,$(CAMERA_ZIG_VERSION))
CAMERA_ZIG_DEPENDENCIES = host-zig-x86-64

define CAMERA_ZIG_BUILD_CMDS
	(cd $(@D); zig build)
endef

define CAMERA_ZIG_INSTALL_TARGET_CMDS
	install -D -m 0755 $(@D)/zig-out/bin/capable_camera_firmware $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))