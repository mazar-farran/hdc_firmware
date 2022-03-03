################################################################################
#
# camera-cpp
#
################################################################################

CAMERA_CPP_VERSION = 0600b5bf1354d1ed577135641df956fd47df4525
CAMERA_CPP_SITE = $(call github,CapableRobot,capable_camera_firmware,$(CAMERA_CPP_VERSION))
CAMERA_CPP_CONF_OPTS = -DENABLE_OPENCV=0
CAMERA_CPP_DEPENDENCIES = boost libcamera libjpeg 
CAMERA_CPP_SUBDIR = camera

$(eval $(cmake-package))
