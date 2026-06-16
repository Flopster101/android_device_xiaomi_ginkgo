#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from sm6125-common
include device/xiaomi/sm6125-common/BoardConfigCommon.mk

DEVICE_PATH := device/xiaomi/ginkgo

# A/B
AB_OTA_UPDATER := false

# Assert
TARGET_OTA_ASSERT_DEVICE := ginkgo,willow

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := ginkgo

ifeq ($(WITH_GMS),true)
# Compression
PRODUCT_FS_COMPRESSION := 1
BOARD_EROFS_COMPRESSOR := lz4

# Compression block length
BOARD_EROFS_PCLUSTER_SIZE := 262144
endif

# Display
TARGET_SCREEN_DENSITY := 440

# Camera
PRODUCT_NO_CAMERA := true

# Kernel
TARGET_KERNEL_CONFIG += vendor/ginkgo.config

# Retrofit
PARTITIONS := system vendor product
ifeq ($(WITH_GMS),true)
$(foreach p, $(call to-upper, $(PARTITIONS)), \
    $(eval BOARD_$(p)IMAGE_FILE_SYSTEM_TYPE := erofs))
else
$(eval BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4)
$(eval BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs)
$(eval BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4)
endif

$(foreach p, $(call to-upper, $(PARTITIONS)), \
    $(eval TARGET_COPY_OUT_$(p) := $(call to-lower, $(p))))

BOARD_SUPER_PARTITION_SIZE := 6442450944
BOARD_SUPER_PARTITION_GROUPS := ginkgo_dynapart
BOARD_GINKGO_DYNAPART_PARTITION_LIST := $(PARTITIONS)
BOARD_GINKGO_DYNAPART_SIZE := 6438252544
BOARD_SUPER_PARTITION_BLOCK_DEVICES := system vendor product
BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE := 1610612736
BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE := 1610612736
BOARD_SUPER_PARTITION_PRODUCT_DEVICE_SIZE := 3221225472
BOARD_SUPER_PARTITION_METADATA_DEVICE := system

# $(foreach p, $(call to-upper, $(PARTITIONS)), \
#     $(eval BOARD_$(p)IMAGE_PARTITION_RESERVED_SIZE := 100000000)) # 100 MB
-include vendor/lineage/config/BoardConfigReservedSize.mk

# Partitions
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_CACHEIMAGE_PARTITION_SIZE := 402653184
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x04000000

# NFC
ODM_MANIFEST_WILLOW_FILES := $(DEVICE_PATH)//manifest_willow.xml
ODM_MANIFEST_SKUS += willow

# Properties
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Recovery
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_INCLUDE_RECOVERY_DTBO := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.qcom

# Releasetools
TARGET_RELEASETOOLS_EXTENSIONS := $(DEVICE_PATH)

# Sepolicy
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Security patch level - V12.5.12.0.RCOEUXM
BOOT_SECURITY_PATCH := 2022-10-01
VENDOR_SECURITY_PATCH := $(BOOT_SECURITY_PATCH)

# Inherit from the proprietary version
include vendor/xiaomi/ginkgo/BoardConfigVendor.mk
