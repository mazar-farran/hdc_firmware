################################################################################
#
# python-scipy
#
################################################################################

PYTHON_SCIPY_VERSION = 1.4.1
PYTHON_SCIPY_SOURCE = scipy-$(PYTHON_SCIPY_VERSION).tar.gz
PYTHON_SCIPY_SITE = https://files.pythonhosted.org/packages/04/ab/e2eb3e3f90b9363040a3d885ccc5c79fe20c5b8a3caa8fe3bf47ff653260
PYTHON_SCIPY_SETUP_TYPE = setuptools
PYTHON_SCIPY_LICENSE = Apache-2.0
PYTHON_SCIPY_LICENSE_FILES = LICENSE

$(eval $(python-package))
