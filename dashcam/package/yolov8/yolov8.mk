################################################################################
#
# yolov8
#
################################################################################

YOLOV8_DEPENDENCIES = requests python-gitpython python-numpy python-scipy
YOLOV8_SETUP_TYPE = setuptools

$(eval $(python-package))