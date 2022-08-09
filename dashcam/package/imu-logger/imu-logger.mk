################################################################################
#
# imu-logger
#
################################################################################

IMU_LOGGER_VERSION = be9e0d8ae8de15b1f790bccf4ffb3930c37a7e1b
IMU_LOGGER_SITE = ssh://git@bitbucket.org/chr1sniessl/capable_camera_firmware-mirror.git
IMU_LOGGER_SITE_METHOD = git
IMU_LOGGER_CONF_OPTS = -DCMAKE_INSTALL_PREFIX="/opt/dashcam" \
						-DINSTALL_CONFIG_FILES_PATH="/opt/dashcam/bin/"
IMU_LOGGER_DEPENDENCIES = boost json-for-modern-cpp
IMU_LOGGER_MAKE_OPTS = imu-logger

define IMU_LOGGER_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/imu-logger/imu-logger.service \
		$(TARGET_DIR)/usr/lib/systemd/system/imu-logger.service
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/imu-logger/imu-logger-config.txt \
		$(TARGET_DIR)/opt/dashcam/imu-logger-config.txt
endef

$(eval $(cmake-package))
