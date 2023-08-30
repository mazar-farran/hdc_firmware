################################################################################
#
# onnx-yolov8-object-detection
#
################################################################################

ONNX_YOLOV8_OBJECT_DETECTION_VERSION = 0.1.0
ONNX_YOLOV8_OBJECT_DETECTION_SITE = https://github.com/streamingfast/ONNX-YOLOv8-Object-Detection/releases/download/v$(ONNX_YOLOV8_OBJECT_DETECTION_VERSION)
ONNX_YOLOV8_OBJECT_DETECTION_SOURCE = onnx_yolov8.tar.gz
ONNX_YOLOV8_OBJECT_DETECTION_DEPENDENCIES = python3
ONNX_YOLOV8_OBJECT_DETECTION_STRIP_COMPONENTS = 0

define ONNX_YOLOV8_OBJECT_DETECTION_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/opt/dashcam/bin/onnx_yolov8/
	cp -r $(@D)/yolov8 $(TARGET_DIR)/opt/dashcam/bin/onnx_yolov8/
	cp -r $(@D)/main.py $(TARGET_DIR)/opt/dashcam/bin/onnx_yolov8/
endef

define ONNX_YOLOV8_OBJECT_DETECTION_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_DASHCAM_PATH)/package/onnx-yolov8-object-detection/onnx_yolov8.service \
		$(TARGET_DIR)/usr/lib/systemd/system/onnx_yolov8.service
endef

$(eval $(generic-package))
