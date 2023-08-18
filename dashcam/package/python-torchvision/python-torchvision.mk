################################################################################
#
# python-torchvision
#
################################################################################

PYTHON_TORCHVISION_VERSION = 0.15.2
PYTHON_TORCHVISION_SOURCE = torchvision-$(PYTHON_TORCHVISION_VERSION)-cp38-cp38-manylinux2014_aarch64.whl
PYTHON_TORCHVISION_SITE = https://files.pythonhosted.org/packages/7b/41/c94ead27ee4750ec76e62efe6e2e432fd58586978da449327de1f0d2e998
PYTHON_TORCHVISION_SETUP_TYPE = setuptools
PYTHON_TORCHVISION_LICENSE = Apache-2.0
PYTHON_TORCHVISION_LICENSE_FILES = LICENSE

$(eval $(python-package))
