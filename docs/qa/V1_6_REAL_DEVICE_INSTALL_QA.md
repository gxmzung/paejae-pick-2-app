# 배재Pick 2.0 v1.6 Real Device Install QA

## Goal

v1.6 verifies that the Android APK can be installed and launched on a real Android device.

This step is required before sharing the app with internal testers.

## Test Target

- App name: 배재Pick 2.0
- Package name: com.gxmzung.paejaepick
- Version: 1.0.0+1
- APK: build/app/outputs/flutter-apk/app-release.apk

## Install Commands

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
If install fails because an older version exists:

adb uninstall com.gxmzung.paejaepick
adb install -r build/app/outputs/flutter-apk/app-release.apk
Launch Command
adb shell monkey -p com.gxmzung.paejaepick 1
QA Checklist
Install
 Android device detected by adb
 APK installs successfully
 App name appears as 배재Pick 2.0
 App launches successfully
Core Screens
 Splash / Login screen opens
 Home screen opens
 Cafeteria detail opens
 QR mock screen opens
 Mission code screen opens
 Quick code input works
 Mission complete screen opens
 Collection screen reflects acquired card
 Department Nasumi Tour opens
 Club notice detail opens
 Favorite club state saves
 My Page opens
 Privacy guide opens
 Local data reset works
Known Limits
Real school email authentication is not included.
Real QR camera scanning is not included.
Real-time location tracking is not included.
Official school data integration is not included.
Current cafeteria/club data is mock data.
Result

Status:

Pending / Pass / Fail

Test Device:

Device name:
Android version:
Date:
Tester:

Notes:

-

