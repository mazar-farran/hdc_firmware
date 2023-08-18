################################################################################
#
# python-scipy
#
################################################################################

PYTHON_SCIPY_VERSION = 1.10.1
PYTHON_SCIPY_SOURCE = scipy-$(PYTHON_SCIPY_VERSION).tar.gz
PYTHON_SCIPY_SITE = https://files.pythonhosted.org/packages/84/a9/2bf119f3f9cff1f376f924e39cfae18dec92a1514784046d185731301281
PYTHON_SCIPY_SETUP_TYPE = setuptools
PYTHON_SCIPY_LICENSE = Apache-2.0
PYTHON_SCIPY_LICENSE_FILES = LICENSE

$(eval $(python-package))
