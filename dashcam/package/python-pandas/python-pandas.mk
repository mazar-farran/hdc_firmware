################################################################################
#
# python-pandas
#
################################################################################

PYTHON_PANDAS_VERSION = 2.0.3
PYTHON_PANDAS_SOURCE = pandas-$(PYTHON_TORCHVISION_VERSION)-cp38-cp38-manylinux_2_17_aarch64.manylinux2014_aarch64.whl
PYTHON_PANDAS_SITE = https://files.pythonhosted.org/packages/a7/87/828d50c81ce0f434163bf70b925a0eec6076808e0bca312a79322b141f66
PYTHON_PANDAS_SETUP_TYPE = setuptools
PYTHON_PANDAS_LICENSE = Apache-2.0
PYTHON_PANDAS_LICENSE_FILES = LICENSE

$(eval $(python-package))
