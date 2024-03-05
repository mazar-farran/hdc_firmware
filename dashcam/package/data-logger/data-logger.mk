###############################################################################
#
# data-logger
#
################################################################################

DATA_LOGGER_VERSION = 19423b636bd6ca383ede224da9072559ce9a9d4a
DATA_LOGGER_SITE = $(call github,Hivemapper,hivemapper-data-logger,$(DATA_LOGGER_VERSION))
DATA_LOGGER_SITE_METHOD = git
DATA_LOGGER_STRIP_COMPONENTS = 0
DATA_LOGGER_GOLANG_BUILD_TARGETS += ./cmd/datalogger
DATA_LOGGER_GOLANG_INSTALL_BINS += datalogger
DATA_LOGGER_GOMOD = ./cmd/datalogger


# Buildroot downloads and extracts the source into a subdirectory for some reason.
# This step moves all the contents of the subdirectory to the main directory so
# that it could be built.
define DATA_LOGGER_FIX_DOWNLOAD_DIR
	mv $(wildcard $(@D)/data-logger-${DATA_LOGGER_VERSION}/*) $(@D)
	mv $(@D)/data-logger-${DATA_LOGGER_VERSION}/.gitignore $(@D)
	mv $(@D)/data-logger-${DATA_LOGGER_VERSION}/.goreleaser.yaml $(@D)
	rmdir $(@D)/data-logger-${DATA_LOGGER_VERSION}/
endef

DATA_LOGGER_POST_PATCH_HOOKS += DATA_LOGGER_FIX_DOWNLOAD_DIR

define DATA_LOGGER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/bin/data-logger $(TARGET_DIR)/opt/dashcam/bin/datalogger
endef

define DATA_LOGGER_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/data-logger/data-logger.service \
		$(TARGET_DIR)/usr/lib/systemd/system/data-logger.service
endef

$(eval $(golang-package))
