################################################################################
#
# camera-cpp
#
################################################################################

CAMERA_CPP_VERSION = dcb08d26b29c6aaa25d2813754b1ad535373a41c
CAMERA_CPP_SITE = $(call github,cshaw9-rtr,capable_camera_firmware,$(CAMERA_CPP_VERSION))
CAMERA_CPP_CONF_OPTS = -DENABLE_OPENCV=0
CAMERA_CPP_DEPENDENCIES = boost libcamera libjpeg 
CAMERA_CPP_SUBDIR = camera

$(eval $(cmake-package))
