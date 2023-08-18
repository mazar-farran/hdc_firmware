################################################################################
#
# python-opencv-python
#
################################################################################

PYTHON_OPENCV_PYTHON_VERSION = 4.1.1.26
PYTHON_OPENCV_PYTHON_SOURCE = opencv_python-$(PYTHON_OPENCV_PYTHON_VERSION).tar.gz
/opencv_python-4.8.0.76-cp37-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.whl
PYTHON_OPENCV_PYTHON_SITE = https://files.pythonhosted.org/packages/1c/1f/e2fecc126554b84ddea6a159564f3ee21ae9ce52148d72e0d66d655a511c
PYTHON_OPENCV_PYTHON_SETUP_TYPE = setuptools
PYTHON_OPENCV_PYTHON_LICENSE = Apache-2.0
PYTHON_OPENCV_PYTHON_LICENSE_FILES = LICENSE

$(eval $(python-package))
