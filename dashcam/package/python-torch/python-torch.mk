################################################################################
#
# python-torch
#
################################################################################

PYTHON_TORCH_VERSION = 2.0.1
PYTHON_TORCH_SOURCE = torch-$(PYTHON_TORCH_VERSION)-cp38-cp38-manylinux2014_aarch64.whl
PYTHON_TORCH_SITE = https://files.pythonhosted.org/packages/90/f6/b0358e90e10306f80c474379ae1c637760848903033401d3e662563f83a3
PYTHON_TORCH_SETUP_TYPE = setuptools
PYTHON_TORCH_LICENSE = Apache-2.0
PYTHON_TORCH_LICENSE_FILES = LICENSE

$(eval $(python-package))
