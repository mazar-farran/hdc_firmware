################################################################################
#
# camera-cpp
#
################################################################################

CAMERA_CPP_VERSION = 3f4380d57fbcda8ff0cab7d190e8e1c9ef993b8b
CAMERA_CPP_SITE = $(call github,CapableRobot,capable_camera_firmware,$(CAMERA_CPP_VERSION))
CAMERA_CPP_CONF_OPTS = -DENABLE_OPENCV=0
CAMERA_CPP_DEPENDENCIES = boost libcamera libjpeg 
CAMERA_CPP_SUBDIR = camera

$(eval $(cmake-package))
