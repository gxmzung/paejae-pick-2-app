# 배재Pick 2.0 v1.1 Android Release Config

## Goal

v1.1 prepares the Android project for internal testing and later Play Store release.

This version focuses on release configuration rather than new features.

## Scope

- Android app label
- Flutter versionName / versionCode
- Debug APK build path
- Release APK/AAB preparation
- Git ignore rules for build artifacts
- Release note structure

## Android App Label

Current target app name:

```text
배재Pick 2.0
Version

Current Flutter version:

1.0.0+1

Meaning:

versionName: 1.0.0
versionCode: 1
Build Commands
Debug APK
flutter build apk --debug

Output:

build/app/outputs/flutter-apk/app-debug.apk
Release APK
flutter build apk --release

Output:

build/app/outputs/flutter-apk/app-release.apk
App Bundle for Play Store
flutter build appbundle --release

Output:

build/app/outputs/bundle/release/app-release.aab
Important

v1.1 does not yet configure signing keys.

For Play Store upload, Android signing configuration must be added later.

Current Release Strategy
Debug APK internal testing
Feedback from 5~10 students
UI/UX polish
Privacy policy draft
Release signing configuration
Play Console internal testing
