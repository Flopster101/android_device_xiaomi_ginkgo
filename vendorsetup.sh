#!/bin/bash
SCRIPTS_ROOT="$(realpath device/xiaomi/ginkgo)"

apply_patch_if_missing() {
  local repo_path="$1"
  local marker_file="$2"
  local marker_text="$3"
  local patch_file="$4"

  if [ ! -f "$marker_file" ] || ! grep -qF "$marker_text" "$marker_file"; then
    (
      cd "$repo_path" || exit 1
      if [ -d ".git/rebase-apply" ] || [ -d ".git/rebase-merge" ]; then
        git am --abort >/dev/null 2>&1 || true
      fi
      git am -3 "$patch_file" || {
        git am --abort >/dev/null 2>&1 || true
        exit 1
      }
    ) || return 1
  fi

  return 0
}

echo "-> Checking for Settings patches to apply..."
if [ -f "packages/apps/Settings/res/values/strings.xml" ] && ! grep -q "build_maintainer" "packages/apps/Settings/res/values/strings.xml"; then
  (
    cd "packages/apps/Settings"
    git am -3 "$SCRIPTS_ROOT/patches/Settings/0001-Settings-Add-Maintainer-string-into-device-info.patch"
  )
fi

echo "-> Checking for frameworks/native patches to apply..."
if ! grep -q "kMaxPasses = 3" "frameworks/native/libs/renderengine/skia/filters/KawaseBlurFilter.h"; then
  (
    cd "frameworks/native"
    git am -3 "$SCRIPTS_ROOT/patches/frameworks/native/0001-blur-Fast-Hybrid-Kawase-blur-for-low-end-devices.patch"
  )
fi

# SBC HD (Dual Channel) Bluetooth audio patches
# Set SKIP_SBC_HD_PATCHES=1 to disable these patches
if [ "$SKIP_SBC_HD_PATCHES" != "1" ]; then
  echo "-> Checking for SBC HD Bluetooth patches to apply..."

  # packages/modules/Bluetooth patches
  if ! apply_patch_if_missing \
      "packages/modules/Bluetooth" \
      "packages/modules/Bluetooth/framework/java/android/bluetooth/BluetoothCodecConfig.java" \
      "CHANNEL_MODE_DUAL_CHANNEL" \
      "$SCRIPTS_ROOT/patches/SBC_HD/packages_modules_Bluetooth/0001-Add-CHANNEL_MODE_DUAL_CHANNEL-constant.patch"; then
    echo "-> Failed to apply SBC HD Bluetooth patch 0001"
    return 1 2>/dev/null || exit 1
  fi

  if ! apply_patch_if_missing \
      "packages/modules/Bluetooth" \
      "packages/modules/Bluetooth/system/stack/a2dp/a2dp_sbc.cc" \
      "Fallback: force Dual Channel even if not advertised (SBC HD feature)" \
      "$SCRIPTS_ROOT/patches/SBC_HD/packages_modules_Bluetooth/0002-Explicit-SBC-Dual-Channel-SBC-HD-native-stack-suppor.patch"; then
    echo "-> Failed to apply SBC HD Bluetooth patch 0002"
    return 1 2>/dev/null || exit 1
  fi

  if ! apply_patch_if_missing \
      "packages/modules/Bluetooth" \
      "packages/modules/Bluetooth/system/stack/a2dp/a2dp_sbc_encoder.cc" \
      "A2DP_SBC_2DH5_DEFAULT_BITRATE" \
      "$SCRIPTS_ROOT/patches/SBC_HD/packages_modules_Bluetooth/0003-Increase-SBC-HD-bitrates-with-2DH5-fallback-support.patch"; then
    echo "-> Failed to apply SBC HD Bluetooth patch 0003"
    return 1 2>/dev/null || exit 1
  fi

  if ! apply_patch_if_missing \
      "packages/modules/Bluetooth" \
      "packages/modules/Bluetooth/android/app/src/com/android/bluetooth/a2dp/A2dpCodecConfig.java" \
      "persist.bluetooth.sbc_hd.enabled" \
      "$SCRIPTS_ROOT/patches/SBC_HD/packages_modules_Bluetooth/0004-Allow-auto-enabling-SBC-HD.patch"; then
    echo "-> Failed to apply SBC HD Bluetooth patch 0004"
    return 1 2>/dev/null || exit 1
  fi

  if ! apply_patch_if_missing \
      "packages/modules/Bluetooth" \
      "packages/modules/Bluetooth/system/stack/a2dp/a2dp_sbc_encoder.cc" \
      "persist.bluetooth.sbc_hd.force_max_bitrate" \
      "$SCRIPTS_ROOT/patches/SBC_HD/packages_modules_Bluetooth/0005-Add-force-max-SBC-HD-bitrate-option.patch"; then
    echo "-> Failed to apply SBC HD Bluetooth patch 0005"
    return 1 2>/dev/null || exit 1
  fi

  # SettingsLib patches
  if ! apply_patch_if_missing \
      "frameworks/base" \
      "frameworks/base/packages/SettingsLib/res/values/arrays.xml" \
      "Dual Channel (SBC HD)" \
      "$SCRIPTS_ROOT/patches/SBC_HD/frameworks_base/0001-Add-Dual-Channel-SBC-HD-to-Bluetooth-Audio-Channel-Mode-strings.patch"; then
    echo "-> Failed to apply SBC HD frameworks/base patch 0001"
    return 1 2>/dev/null || exit 1
  fi

  if ! apply_patch_if_missing \
      "frameworks/base" \
      "frameworks/base/packages/SettingsLib/res/values/strings.xml" \
      "bluetooth_enable_sbc_hd" \
      "$SCRIPTS_ROOT/patches/SBC_HD/frameworks_base/0002-SettingsLib-Add-SBC-HD-toggle-strings.patch"; then
    echo "-> Failed to apply SBC HD frameworks/base patch 0002"
    return 1 2>/dev/null || exit 1
  fi

  # packages/apps/Settings patches
  if ! apply_patch_if_missing \
      "packages/apps/Settings" \
      "packages/apps/Settings/src/com/android/settings/development/bluetooth/BluetoothChannelModeDialogPreferenceController.java" \
      "CHANNEL_MODE_DUAL_CHANNEL = 0x1 << 2;" \
      "$SCRIPTS_ROOT/patches/SBC_HD/packages_apps_Settings/0001-Add-Dual-Channel-into-Bluetooth-Audio-Channel-Mode-dialog.patch"; then
    echo "-> Failed to apply SBC HD Settings patch 0001"
    return 1 2>/dev/null || exit 1
  fi

  if ! apply_patch_if_missing \
      "packages/apps/Settings" \
      "packages/apps/Settings/src/com/android/settings/development/DevelopmentSettingsDashboardFragment.java" \
      "BluetoothSbcHdPreferenceController" \
      "$SCRIPTS_ROOT/patches/SBC_HD/packages_apps_Settings/0002-Settings-Add-SBC-HD-Developer-Options-toggles.patch"; then
    echo "-> Failed to apply SBC HD Settings patch 0002"
    return 1 2>/dev/null || exit 1
  fi

  echo "-> SBC HD patches applied."
else
  echo "-> Skipping SBC HD patches (SKIP_SBC_HD_PATCHES=1)"
fi
