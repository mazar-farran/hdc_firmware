################################################################################
#
# camera-bridge
#
################################################################################

CAMERA_BRIDGE_VERSION = 76e09ef5ec49b81094ca6298ca524d26c45c2fa3
CAMERA_BRIDGE_SITE = $(call github,CapableRobot,capable_camera_firmware,$(CAMERA_BRIDGE_VERSION))
CAMERA_BRIDGE_CONF_OPTS = -DENABLE_OPENCV=0 -DCMAKE_INSTALL_PREFIX="/opt/dashcam"
CAMERA_BRIDGE_DEPENDENCIES = boost libcamera libjpeg 
CAMERA_BRIDGE_SUBDIR = camera

define CAMERA_BRIDGE_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/camera-bridge/camera-bridge.service \
		$(TARGET_DIR)/usr/lib/systemd/system/camera-bridge.service
endef

$(eval $(cmake-package))
