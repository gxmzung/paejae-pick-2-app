# 배재Pick 2.0 v1.7.1 Feedback Entry Hotfix

## Goal

v1.7 added the Tester Feedback Hub screen, but the My Page entry point was not inserted automatically.

v1.7.1 fixes that issue by adding a visible navigation entry to the feedback hub.

## Scope

- Add "테스트 피드백 보기" entry
- Link My Page to TesterFeedbackScreen
- Verify debug APK build

## Why

A screen that cannot be reached by users is not a completed feature.

The tester feedback hub must be reachable from the app UI before internal testing.

## Test

- Open My Page
- Tap "테스트 피드백 보기"
- Confirm Tester Feedback Hub opens
