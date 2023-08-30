################################################################################
#
# python-inotify
#
################################################################################

PYTHON_INOTIFY_VERSION = 0.2.10
PYTHON_INOTIFY_SOURCE = inotify-$(PYTHON_INOTIFY_VERSION).tar.gz
PYTHON_INOTIFY_SITE = https://files.pythonhosted.org/packages/35/cb/6d564f8a3f25d9516298dce151670d01e43a4b3b769c1c15f40453179cd5
PYTHON_INOTIFY_SETUP_TYPE = setuptools
PYTHON_INOTIFY_LICENSE = Apache-2.0
PYTHON_INOTIFY_LICENSE_FILES = LICENSE

$(eval $(python-package))
