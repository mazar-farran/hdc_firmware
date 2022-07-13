################################################################################
#
# camera-node
#
################################################################################

CAMERA_NODE_VERSION = 1.0.0
CAMERA_NODE_SITE = $(BR2_EXTERNAL_DASHCAM_PATH)/package/camera-node/files
CAMERA_NODE_SITE_METHOD = local
CAMERA_NODE_DEPENDENCIES = nodejs

define GPSD_AND_CONFIG_INSTALL_TARGET_CMDS
	#Add your node file to files and replace HELLOWORLD.js with your file's name
	$(INSTALL) -D -m 644 $(@D)/HELLOWORLD.js \
		$(TARGET_DIR)/opt/dashcam/bin/HELLOWORLD.js
	#Uncomment the command below once camera-node.service has been configured appropriately
	#$(INSTALL) -D -m 644 $(@D)/camera-node.service \
	#	$(TARGET_DIR)/usr/lib/systemd/system/camera-node.service
endef

$(eval $(generic-package))
