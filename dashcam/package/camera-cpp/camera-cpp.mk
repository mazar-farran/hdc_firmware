################################################################################
#
# camera-cpp
#
################################################################################

CAMERA_CPP_VERSION = 76e09ef5ec49b81094ca6298ca524d26c45c2fa3
CAMERA_CPP_SITE = $(call github,CapableRobot,capable_camera_firmware,$(CAMERA_CPP_VERSION))
CAMERA_CPP_CONF_OPTS = -DENABLE_OPENCV=0 -DCMAKE_INSTALL_PREFIX="/opt/dashcam"
CAMERA_CPP_DEPENDENCIES = boost libcamera libjpeg 
CAMERA_CPP_SUBDIR = camera

define CAMERA_CPP_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/camera-cpp/camera-cpp.service \
		$(TARGET_DIR)/usr/lib/systemd/system/camera-cpp.service
endef

$(eval $(cmake-package))
