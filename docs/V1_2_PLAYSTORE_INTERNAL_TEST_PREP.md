# 배재Pick 2.0 v1.2 Play Store Internal Test Prep

## Goal

v1.2 prepares Paejae Pick 2.0 for Android internal testing.

This version focuses on Play Store readiness, not new app features.

## Scope

- Android package name check
- App Bundle build attempt
- Privacy policy draft
- Terms of service draft
- Internal test checklist
- Store listing checklist

## Current Android App

- App name: 배재Pick 2.0
- Version: 1.0.0+1
- Package name: com.gxmzung.paejaepick
- Target: Android first
- Backend: none
- Storage: local SharedPreferences

## Data Policy

Stored locally:

- collected cards
- favorite clubs
- mission/card states

Not collected:

- real name
- student number
- phone number
- real-time location
- cafeteria visit history
- facility report identity

## Internal Test Goal

The internal test should answer:

- Do students open the app because of cafeteria information?
- Does Nasumi collection create repeat usage?
- Does the department tour help students understand campus structure?
- Does the club notice hall feel useful?
- Is the privacy-light design acceptable?

## Not Ready Yet

- Real school email authentication
- Real QR scanner
- Firebase/Supabase sync
- App signing for production
- Official school approval
- Official use of school mascot/assets
