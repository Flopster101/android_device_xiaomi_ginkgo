#!/bin/bash
SCRIPTS_ROOT="$(realpath device/xiaomi/ginkgo)"

if [ -f "vendor/google/pixel/Android.bp" ] && grep -q "SystemUIClocks-BigNum" "vendor/google/pixel/Android.bp"; then
  echo "Removing SystemUIClock modules from vendor/google/pixel..."

  perl -0pe 's/android_app_import \{[^}]*name: "SystemUIClocks-[^}]*\}[^}]*\}//gms; s/\n{3,}/\n\n/g' "vendor/google/pixel/Android.bp" > "vendor/google/pixel/Android.bp.tmp" && mv "vendor/google/pixel/Android.bp.tmp" "vendor/google/pixel/Android.bp"

  echo "SystemUIClock modules removed."
fi

echo "-> Checking for Settings patches to apply..."
if ! grep -q "build_maintainer" "packages/apps/Settings/res/values/cm_strings.xml"; then
  (
    cd "packages/apps/Settings"
    git am -3 "$SCRIPTS_ROOT/patches/Settings/0001-Settings-Add-Maintainer-string-into-device-info.patch"
  )
fi

if ! grep -q "lso check system setting for 4G icon preference" "packages/apps/Settings/src/com/android/settings/network/telephony/NetworkSelectSettings.java"; then
  (
    cd "packages/apps/Settings"
    git am -3 "$SCRIPTS_ROOT/patches/Settings/0001-Settings-Apply-forced-4G-icon-consistently.patch"
  )
fi

echo "-> Checking for Launcher3 patches to apply..."
if ! grep -q "Grid size settings" "packages/apps/Launcher3/res/values/cr_strings.xml"; then
  (
    cd "packages/apps/Launcher3"
    git am -3 "$SCRIPTS_ROOT/patches/Launcher3/0001-Launcher3-Allow-changing-app-drawer-and-home-screen-.patch"
  )
fi

if ! grep -q "Try multiple wallpaper picker packages" "packages/apps/Launcher3/src/com/android/launcher3/views/OptionsPopupView.java"; then
  (
    cd "packages/apps/Launcher3"
    git am -3 "$SCRIPTS_ROOT/patches/Launcher3/0001-Launcher3-Support-multiple-wallpaper-pickers.patch"
  )
fi

echo "-> Checking for SystemUI patches to apply..."
if ! grep -q "convertLteToFourg" "frameworks/base/packages/SystemUI/src/com/android/systemui/qs/tiles/dialog/InternetDetailsContentController.java"; then
  (
    cd "frameworks/base"
    git am -3 "$SCRIPTS_ROOT/patches/SystemUI/0001-SystemUI-Apply-forced-4G-to-Quick-Settings-tile-too.patch"
  )
fi

echo "-> Checking for vendor/google patches to apply..."
if grep -q "GoogleSans-" "vendor/google/pixel/pixel-vendor.mk"; then
  (
    cd "vendor/google/pixel"
    git am -3 "$SCRIPTS_ROOT/patches/vendor_google/0001-pixel-Remove-Google-Sans-UI-fonts.patch"
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

  # packages/modules/Bluetooth patches (must be applied in order)
  if ! grep -q "CHANNEL_MODE_DUAL_CHANNEL" "packages/modules/Bluetooth/framework/java/android/bluetooth/BluetoothCodecConfig.java"; then
    (
      cd "packages/modules/Bluetooth"
      git am -3 "$SCRIPTS_ROOT/patches/SBC_HD/packages_modules_Bluetooth/0001-Add-CHANNEL_MODE_DUAL_CHANNEL-constant.patch"
      git am -3 "$SCRIPTS_ROOT/patches/SBC_HD/packages_modules_Bluetooth/0002-Explicit-SBC-Dual-Channel-SBC-HD-native-stack-suppor.patch"
      git am -3 "$SCRIPTS_ROOT/patches/SBC_HD/packages_modules_Bluetooth/0003-Increase-SBC-HD-bitrates-with-2DH5-fallback-support.patch"
      git am -3 "$SCRIPTS_ROOT/patches/SBC_HD/packages_modules_Bluetooth/0004-Allow-auto-enabling-SBC-HD.patch"
      git am -3 "$SCRIPTS_ROOT/patches/SBC_HD/packages_modules_Bluetooth/0005-Add-force-max-SBC-HD-bitrate-option.patch"
    )
  fi

  # SettingsLib patches (strings for channel mode and toggle)
  if ! grep -qF "Dual Channel (SBC HD)" "frameworks/base/packages/SettingsLib/res/values/arrays.xml" || ! grep -qF "bluetooth_enable_sbc_hd" "frameworks/base/packages/SettingsLib/res/values/strings.xml"; then
    (
      cd "frameworks/base"
      git am -3 "$SCRIPTS_ROOT/patches/SBC_HD/frameworks_base/0001-Add-Dual-Channel-SBC-HD-to-Bluetooth-Audio-Channel-Mode-strings.patch"
      git am -3 "$SCRIPTS_ROOT/patches/SBC_HD/frameworks_base/0002-SettingsLib-Add-SBC-HD-toggle-strings.patch"
    )
  fi

  # packages/apps/Settings patches (channel mode dialog + developer options toggles)
  if ! grep -q "BluetoothSbcHdPreferenceController" "packages/apps/Settings/src/com/android/settings/development/DevelopmentSettingsDashboardFragment.java"; then
    (
      cd "packages/apps/Settings"
      git am -3 "$SCRIPTS_ROOT/patches/SBC_HD/packages_apps_Settings/0001-Add-Dual-Channel-into-Bluetooth-Audio-Channel-Mode-dialog.patch"
      git am -3 "$SCRIPTS_ROOT/patches/SBC_HD/packages_apps_Settings/0002-Settings-Add-SBC-HD-Developer-Options-toggles.patch"
    )
  fi

  echo "-> SBC HD patches applied."
else
  echo "-> Skipping SBC HD patches (SKIP_SBC_HD_PATCHES=1)"
fi
