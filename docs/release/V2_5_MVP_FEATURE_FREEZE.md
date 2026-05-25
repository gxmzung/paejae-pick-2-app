# 배재Pick 2.0 v2.5 MVP Feature Freeze

## Goal

v2.5 freezes the MVP feature scope before preparing the internal beta candidate.

From this point, the project should avoid adding new major features until the internal beta test is completed.

## Product Positioning

배재Pick은 단순한 학교 앱 목업이 아니라, 배재대학교 학생 생활과 참여 흐름을 연결하는 캠퍼스 인프라 MVP입니다.

## Core Product Logic

- 학생식당 = 설치 이유
- 나섬이 / 미션 / 도감 = 재방문 이유
- 캠퍼스 참여 허브 = 학교 안 확산 이유

## Frozen MVP Scope

### 1. Entry / Account Mock

- Splash
- Login mock
- Privacy-light local-first explanation

### 2. Home

- Today's Pick
- App positioning card
- Cafeteria entry
- Mission / collection entry
- Campus Participation Hub entry

### 3. Cafeteria / CityBrain

- Cafeteria detail
- Menu mock
- Congestion mock
- Menu card acquisition

### 4. Nasumi Collection / Mission

- Collection list
- Card detail
- Code mission
- QR scan mock
- Mission complete flow
- Department Nasumi Tour

### 5. Campus Participation Hub

- Club notice hall
- Club detail
- Favorite club save
- Club notice submit mock
- Participation notice types
- Participation status labels
- Filter / deadline concept

### 6. Trust / Test Support

- Privacy guide
- Local data reset
- Tester feedback hub
- App status / roadmap
- Real device install QA checklist
- Internal tester guide
- APK install guide

## Explicitly Not Included

- Real school email authentication
- Real QR camera scanning
- Real-time location tracking
- Backend server sync
- Admin console
- Real cafeteria data integration
- Official school approval
- Real club manager account
- Payment / fee / settlement features
- Anonymous board
- Chat / comment system
- 과팅 or personal matching features

## MVP Freeze Rule

After v2.5, only the following changes are allowed before v3.0:

- Critical bug fixes
- Text correction
- Build/release configuration
- Screenshot preparation
- Internal beta packaging
- Test guide improvement

New major product features should wait until after internal feedback.

## Internal Beta Readiness Criteria

Before v3.0, verify:

- Debug APK builds
- Release APK builds
- AAB builds
- GitHub Release exists
- Android device install test is completed
- Core screens are reachable
- Mock limitations are clearly shown
- Testers understand that this is not an official school app

## Next Step

v3.0 should package the project as an Internal Beta Candidate.
