################################################################################
#
# camera-node
#
################################################################################

CAMERA_NODE_VERSION = 435fc8317ab138ccc8c613295d1db16079db9227
CAMERA_NODE_SITE = git@github.com:Hivemapper/odc-api.git
CAMERA_NODE_SITE_METHOD = git
CAMERA_NODE_DEPENDENCIES = host-nodejs nodejs

define CAMERA_NODE_BUILD_CMDS
	mkdir -p $(@D)/node_modules
	$(NPM) install --prefix $(@D)
	$(NPM) run --prefix $(@D) compile-gh --camera=hdc
endef

define CAMERA_NODE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 644 $(@D)/compiled/odc-api-hdc.js \
		$(TARGET_DIR)/opt/dashcam/bin/dashcam-api.js
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/camera-node/files/camera-node.service \
		$(TARGET_DIR)/usr/lib/systemd/system/camera-node.service
endef

$(eval $(generic-package))
