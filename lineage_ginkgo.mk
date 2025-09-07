#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from ginkgo device
$(call inherit-product, device/xiaomi/ginkgo/device.mk)

## AxionOS
TARGET_DISABLE_EPPE := true
AXION_CAMERA_REAR_INFO := 48,8,2,2
AXION_CAMERA_FRONT_INFO := 13
AXION_MAINTAINER := Flopster101
AXION_PROCESSOR := Snapdragon_665
TARGET_ENABLE_BLUR := true
TARGET_INCLUDE_VIPERFX := false
# /sys/class/power_supply/battery/input_suspend for this device
BYPASS_CHARGE_SUPPORTED := true

## Performance
AXION_CPU_SMALL_CORES := 0,1,2,3
AXION_CPU_BIG_CORES := 4,5,6,7
## CPUsets configuration
# CPUset used for bg/audio cpusets 
AXION_CPU_BG := 0-2
# CPUset used for foreground cpusets
AXION_CPU_FG ?= 0-7
# CPUset that will be used when limiting other cpusets except top-app
AXION_CPU_LIMIT_BG := 0-1
# CPUset that will be used to unlimit critical cpusets for UI
AXION_CPU_UNLIMIT_UI ?= 0-7
# CPUset that will be used when limiting critical cpusets for UI
AXION_CPU_LIMIT_UI ?= 0-4
# CPUset that will be used for critical display processes
AXION_CPU_DISPLAY ?= 4-7
# CPUset that will be used for audio processes e.g. audioserver
AXION_CPU_AUDIO ?= 0-3

AXION_DEBUGGING_ENABLED := true

PRODUCT_NAME := lineage_ginkgo
PRODUCT_DEVICE := ginkgo
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Redmi Note 8

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

BUILD_FINGERPRINT := xiaomi/ginkgo_eea/ginkgo:11/RKQ1.201004.002/V12.5.12.0.RCOEUXM:user/release-keys
