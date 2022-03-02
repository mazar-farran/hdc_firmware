################################################################################
#
# camera-cpp
#
################################################################################

CAMERA_CPP_VERSION = ae1161e8db5c5ecaad04858389ef177558f06294
CAMERA_CPP_SITE = $(call github,cshaw9-rtr,capable_camera_firmware,$(CAMERA_CPP_VERSION))
CAMERA_CPP_CONF_OPTS = -DENABLE_OPENCV=0
CAMERA_CPP_DEPENDENCIES = boost libcamera libjpeg 
CAMERA_CPP_SUBDIR = camera

$(eval $(cmake-package))
