#!/bin/bash
DEVICE_ROOT="$(realpath device/xiaomi/ginkgo)"

if [ -f "vendor/google/pixel/Android.bp" ] && grep -q "SystemUIClocks-BigNum" "vendor/google/pixel/Android.bp"; then
  echo "Removing SystemUIClock modules from vendor/google/pixel..."

  perl -0pe 's/android_app_import \{[^}]*name: "SystemUIClocks-[^}]*\}[^}]*\}//gms; s/\n{3,}/\n\n/g' "vendor/google/pixel/Android.bp" > "vendor/google/pixel/Android.bp.tmp" && mv "vendor/google/pixel/Android.bp.tmp" "vendor/google/pixel/Android.bp"

  echo "SystemUIClock modules removed."
fi

if ! grep -q "build_maintainer" "packages/apps/Settings/res/values/cm_strings.xml"; then
  echo "Applying Settings maintainer patch..."

  (
      cd "packages/apps/Settings"
      git am -3 "$DEVICE_ROOT/patches/0001-Settings-Add-Maintainer-string-into-device-info.patch"
  )
  echo "Settings maintainer patch applied successfully."
fi

if ! grep -q "FLAG_ACTIVITY_NEW_TASK" "packages/apps/Launcher3/src/com/android/launcher3/quickspace/QuickEventsController.java"; then
  echo "Applying Launcher3 Quickspace crash fix..."

  (
    cd "packages/apps/Launcher3"
    git am -3 "$DEVICE_ROOT/patches/0001-Launcher3-Fix-QuickSpace-crash-by-adding-FLAG_ACTIVI.patch"
  )
  echo "Launcher3 Quickspace crash fix applied successfully."
fi

if ! grep -q "Grid size settings" "packages/apps/Launcher3/res/values/cr_strings.xml"; then
  echo "Applying Launcher3 grid size patch..."

  (
    cd "packages/apps/Launcher3"
    git am -3 "$DEVICE_ROOT/patches/0001-Launcher3-Allow-changing-app-drawer-and-home-screen-.patch"
  )
  echo "Launcher3 grid size patch applied successfully."
fi
