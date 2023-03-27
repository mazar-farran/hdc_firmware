################################################################################
#
# imu-logger
#
################################################################################

IMU_LOGGER_VERSION = 8ff2a042db7ae72e0392064c724b8fcc908f17ed
IMU_LOGGER_SITE = ssh://git@github.com:Hivemapper/capable_camera_firmware.git
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
