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
if ! grep -q "FLAG_ACTIVITY_NEW_TASK" "packages/apps/Launcher3/src/com/android/launcher3/quickspace/QuickEventsController.java"; then
  (
    cd "packages/apps/Launcher3"
    git am -3 "$SCRIPTS_ROOT/patches/Launcher3/0001-Launcher3-Fix-QuickSpace-crash-by-adding-FLAG_ACTIVI.patch"
  )
fi

if ! grep -q "Grid size settings" "packages/apps/Launcher3/res/values/cr_strings.xml"; then
  (
    cd "packages/apps/Launcher3"
    git am -3 "$SCRIPTS_ROOT/patches/Launcher3/0001-Launcher3-Allow-changing-app-drawer-and-home-screen-.patch"
  )
fi

echo "-> Checking for SystemUI patches to apply..."
if ! grep -q "bottom|start" "frameworks/base/packages/SystemUI/res/layout/status_bar_wifi_group_inner.xml"; then
  (
    cd "frameworks/base"
    git am -3 "$SCRIPTS_ROOT/patches/SystemUI/0001-WifiStandard-Move-standard-icon-to-the-left-side.patch"
  )
fi

if ! grep -q "convertLteToFourg" "frameworks/base/packages/SystemUI/src/com/android/systemui/qs/tiles/dialog/InternetDialogController.java"; then
  (
    cd "frameworks/base"
    git am -3 "$SCRIPTS_ROOT/patches/SystemUI/0001-SystemUI-Apply-forced-4G-to-Quick-Settings-tile-too.patch"
  )
fi
