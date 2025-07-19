#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Pixelage stuff.
$(call inherit-product, vendor/pixelage/config/common_full_phone.mk)

# Inherit from ginkgo device
$(call inherit-product, device/xiaomi/ginkgo/device.mk)

# Pixelage
PIXELAGE_MAINTAINER := Flopster101
TARGET_FACE_UNLOCK_SUPPORTED := true
TARGET_SUPPORTS_QUICK_TAP := true

# Boot animation
TARGET_BOOT_ANIMATION_RES := 1080

PRODUCT_NAME := pixelage_a25x
PRODUCT_DEVICE := ginkgo
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Redmi Note 8

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

# Recovery
TARGET_USES_AOSP_RECOVERY := true

BUILD_FINGERPRINT := xiaomi/ginkgo_eea/ginkgo:11/RKQ1.201004.002/V12.5.12.0.RCOEUXM:user/release-keys
