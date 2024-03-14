################################################################################
#
# camera-node
#
################################################################################

CAMERA_NODE_VERSION = 435fc8317ab138ccc8c613295d1db16079db9227
CAMERA_NODE_SITE = git@github.com:Hivemapper/odc-api.git
CAMERA_NODE_SITE_METHOD = git
CAMERA_NODE_DEPENDENCIES = host-nodejs nodejs

# Define NPM for other packages to use
# $(NPM) does not work. ncc will build incorrectly.
NPM_HOST = $(TARGET_CONFIGURE_OPTS) \
	LDFLAGS="$(NODEJS_LDFLAGS)" \
	LD="$(TARGET_CXX)" \
	$(HOST_DIR)/bin/npm

ARCH_STRING=napi-v6-linux-glibc-x64

# Note: We cannot build the binary node_sqlite3.node correctly
#       because we are on a different arch than the target.
#       So instead we will use the node_sqlite3.node found in
#       raspberrypi/overlays
define CAMERA_NODE_BUILD_CMDS
	mkdir -p $(@D)/node_modules
	$(NPM_HOST) install --prefix $(@D)
	$(NPM_HOST) run --prefix $(@D) compile-gh --camera=hdc

	# Check for expected string and fail if it's not there.
	# This is better than having a borked firmware build.
	# If this fails, you're probably compiling on a new arch and need
	# to change ARCH_STRING to match compiled/lib/binding/<name>.
	grep $(ARCH_STRING) $(@D)/compiled/odc-api-hdc.js

	# change to match the node_sqlite3 path in overlays
	sed -i 's/$(ARCH_STRING)/napi-v6-darwin-unknown-arm64/g' $(@D)/compiled/odc-api-hdc.js
endef

define CAMERA_NODE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 644 $(@D)/compiled/odc-api-hdc.js \
		$(TARGET_DIR)/opt/dashcam/bin/dashcam-api.js
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/camera-node/files/camera-node.service \
		$(TARGET_DIR)/usr/lib/systemd/system/camera-node.service
endef

$(eval $(generic-package))
