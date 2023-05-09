################################################################################
#
# onboard-updater
#
################################################################################

ONBOARD_UPDATER_VERSION = 4ae977fbb06cc8ea7b015589f8fe20786753fbe0
# Note that this is a private repo being accessed over SSH, so you need to have
# SSH keys setup for BitBucket.
ONBOARD_UPDATER_SITE = ssh://git@bitbucket.org/hellbenderinc/onboardupdater.git
ONBOARD_UPDATER_SITE_METHOD = git
ONBOARD_UPDATER_DEPENDENCIES = python-transitions
ONBOARD_UPDATER_SETUP_TYPE = setuptools

define ONBOARD_UPDATER_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/onboard-updater/onboard-updater.service \
		$(TARGET_DIR)/usr/lib/systemd/system/onboard-updater.service
endef

$(eval $(python-package))