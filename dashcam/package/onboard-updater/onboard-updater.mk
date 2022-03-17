################################################################################
#
# onboard-updater
#
################################################################################

ONBOARD_UPDATER_VERSION = 36e55818161268325d5f432547c21aa02daed00b
ONBOARD_UPDATER_SITE = $(call github,cshaw9-rtr,onboardupdater,$(ONBOARD_UPDATER_VERSION))
ONBOARD_UPDATER_DEPENDENCIES = python-transitions
ONBOARD_UPDATER_SETUP_TYPE = setuptools

define ONBOARD_UPDATER_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/onboard-updater/onboard-updater.service \
		$(TARGET_DIR)/usr/lib/systemd/system/onboard-updater.service
endef

$(eval $(python-package))