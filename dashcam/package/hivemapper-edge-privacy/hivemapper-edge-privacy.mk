################################################################################
#
# hivemapper-edge-privacy
#
################################################################################

HIVEMAPPER_EDGE_PRIVACY_VERSION = 0.4.0
HIVEMAPPER_EDGE_PRIVACY_SITE = https://github.com/streamingfast/hivemapper-edge-privacy/releases/download/v$(HIVEMAPPER_EDGE_PRIVACY_VERSION)
HIVEMAPPER_EDGE_PRIVACY_SOURCE = hivemapper_edge_privacy.tar.gz
HIVEMAPPER_EDGE_PRIVACY_DEPENDENCIES = python3
HIVEMAPPER_EDGE_PRIVACY_STRIP_COMPONENTS = 0

define HIVEMAPPER_EDGE_PRIVACY_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/opt/dashcam/bin/hivemapper_edge_privacy/
	cp -r $(@D)/yolov8 $(TARGET_DIR)/opt/dashcam/bin/hivemapper_edge_privacy/
	cp -r $(@D)/main.py $(TARGET_DIR)/opt/dashcam/bin/hivemapper_edge_privacy/
endef

define HIVEMAPPER_EDGE_PRIVACY_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/hivemapper-edge-privacy/hivemapper-edge-privacy.service \
		$(TARGET_DIR)/usr/lib/systemd/system/hivemapper_edge_privacy.service
endef

$(eval $(generic-package))
