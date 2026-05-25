# 배재Pick 2.0 v1.9.1 Club Submit Entry Hotfix

## Goal

v1.9 added the club notice submit mock screen.

v1.9.1 ensures that the screen is reachable from the Club Notice Hall UI.

## Fixed

- Added visible "공고 등록 요청" entry inside ClubScreen
- Linked ClubScreen to ClubNoticeSubmitMockScreen
- Verified debug APK build

## Why

A mock submission screen is not useful if club operators cannot find it.

The club notice hall should support both:

- students viewing recruitment notices
- club operators requesting notice registration

## Test

- Open 동아리 tab
- Find "동아리 운영진인가요?" card
- Tap "공고 등록 요청"
- Confirm ClubNoticeSubmitMockScreen opens
