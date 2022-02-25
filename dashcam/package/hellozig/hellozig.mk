################################################################################
#
# hellozig
#
################################################################################

HELLOZIG_VERSION = fbd3fa0b91e95ee6bfd13ec2244a34569e0c3d10
HELLOZIG_SITE = $(call github,cshaw9-rtr,hellozig,$(HELLOZIG_VERSION))
HELLOZIG_DEPENDENCIES = host-zig-x86-64

define HELLOZIG_BUILD_CMDS
	(cd $(@D); zig build-exe -target aarch64-linux-gnu $(@D)/hello.zig)
endef

define HELLOZIG_INSTALL_TARGET_CMDS
	install -D -m 0755 $(@D)/hello $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))