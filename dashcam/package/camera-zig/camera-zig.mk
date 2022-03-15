################################################################################
#
# camera-zig
#
################################################################################

CAMERA_ZIG_VERSION = 3f4380d57fbcda8ff0cab7d190e8e1c9ef993b8b
CAMERA_ZIG_SITE = $(call github,CapableRobot,capable_camera_firmware,$(CAMERA_ZIG_VERSION))
CAMERA_ZIG_DEPENDENCIES = host-zig-x86-64

define CAMERA_ZIG_BUILD_CMDS
  # zig installs to a bin directory by default, so that's why we don't prefix to dashcam/bin.
	zig build install --build-file $(@D)/build.zig --prefix $(TARGET_DIR)/opt/dashcam/
endef

$(eval $(generic-package))
