# 배재Pick 2.0 v2.7 Design Lock / UI Spec

## Goal

v2.7 locks the visual direction of Paejae Pick 2.0.

Generated concept images are now treated as the UI reference direction, not just inspiration.

The goal is to make the real Flutter app visually match the approved concept as closely as possible.

## Core Product Identity

배재Pick 2.0은 단순 학교 앱 목업이 아니라, 배재대학교 학생 생활과 참여 흐름을 연결하는 캠퍼스 생활·참여 인프라 MVP입니다.

## Core Value Structure

### 1. 학생식당 / CityBrain

Install reason.

Students open the app because they want to know:

- today's menu
- congestion
- recommended visit time
- cafeteria status

### 2. 나섬이 / 미션 / 도감

Repeat-use reason.

Students return because they can:

- collect Nasumi
- scan QR missions
- unlock campus cards
- see progress

### 3. 캠퍼스 참여 허브

Campus spread reason.

Students share and use the app because it connects:

- club recruitment
- department events
- project team recruitment
- volunteer/supporter notices
- contest team recruitment

### 4. 학과 소개 / 전과 탐색

Discovery reason.

Students use the app to understand:

- departments
- buildings
- department offices
- student council info
- professor/research areas
- transfer possibilities

## Visual Direction

### Design Keywords

- clean
- bright
- blue-accented
- campus-friendly
- game-like but not childish
- trustworthy for school use
- mascot-driven
- card-based
- soft 3D illustration

### Mood

The app should feel like:

- a smart campus app
- a campus RPG guide
- a useful school service
- a collectible mission app

It should not feel like:

- an anonymous board
- a dating/matching app
- a heavy administrative portal
- a childish game only for fun

## Main Color System

### Primary Blue

Used for main buttons, selected tabs, progress bars, highlighted text, and important chips.

Suggested value: #0B72F0

### Dark Navy

Used for main title, strong text, and app identity.

Suggested value: #071A3A

### Background

Used for app base.

Suggested value: #F7FAFF

### Card Background

Suggested value: #FFFFFF

### Soft Blue Card

Used for progress cards and friendly highlight areas.

Suggested value: #EAF4FF

### Warning Red

Used for campus alerts only.

Suggested value: #EF4444

## Typography

### App Title

- Bold
- Large
- Navy with blue accent
- Example: 배재Pick 2.0

### Section Title

- Bold
- 22 to 28px equivalent
- Short and clear

### Card Title

- Bold
- 17 to 20px equivalent

### Card Body

- Medium weight
- 13 to 15px equivalent
- Avoid long paragraphs on Home

## Layout Rules

### Global

- Rounded corners everywhere
- Generous whitespace
- Card-based layout
- Light background
- High contrast text

### Screen Padding

- Horizontal padding: 20 to 24px
- Card spacing: 12 to 16px
- Section spacing: 20 to 28px

### Card Radius

- Main hero card: 28 to 32px
- Normal card: 20 to 24px
- Small chip/button: 14 to 18px

### Shadow

Use soft shadows only.

Avoid strong black shadows.

## Bottom Navigation

Recommended 5 tabs:

1. 홈
2. 도감
3. 미션
4. 모집
5. 마이

Optional center paw button can be used for mission, scan, or main action.

If used, it should look like a floating central action, not a normal tab.

## Mascot Rule

### Name

나섬이

Never use:

- 나심
- 나션
- 나썸

### Role

나섬이는 단순 장식이 아니라 walking, collecting, missions, department discovery, and campus map exploration을 안내하는 캐릭터입니다.

### Motion Concept

Future animation states:

- idle
- walking
- running
- jumping
- waving
- mission complete
- locked card
- guide pointer

### 360 View

For future asset planning:

- front
- 45-degree
- side
- back
- running pose
- jumping pose

## Screen Inventory

### A. Entry

1. Splash
2. Login / school email mock
3. Privacy-light explanation

### B. Home

4. Home dashboard
5. Today's Pick
6. Walking progress card
7. Main feature cards

### C. Cafeteria / CityBrain

8. Cafeteria detail
9. Today's menu
10. Congestion forecast
11. Menu card acquisition

### D. Mission / QR

12. QR mission main
13. QR scan mock
14. Code mission input
15. Mission complete
16. Duplicate QR state
17. Invalid QR state

### E. Collection / Nasumi

18. Collection grid
19. Card detail
20. Locked card
21. Department Nasumi collection
22. 360 mascot preview

### F. Campus Map

23. Campus map
24. Building detail
25. Route guide
26. Mission pin
27. Smoking area guide
28. Facility alert pin

### G. Campus Participation Hub

29. Participation hub list
30. Notice detail
31. Notice submit mock
32. Notice type guide
33. Notice status guide
34. Filter / deadline guide

### H. Department Intro

35. Department list
36. Department detail
37. Department building location
38. Department office info
39. Transfer exploration note
40. Related Nasumi / mission

### I. Campus Alert

41. Safety alert
42. Facility inconvenience
43. Smoking area guide
44. Alert detail

### J. My Page / Trust

45. My Page
46. Privacy guide
47. Tester feedback hub
48. App status / roadmap
49. Local data reset

### K. Admin Future

50. Admin console dashboard
51. Notice approval
52. Facility report review
53. Cafeteria data input
54. Statistics

## Home Screen Locked Structure

Home should show:

1. App title
2. Notification / profile
3. Today's Pick hero
4. Walking progress with Nasumi
5. Student cafeteria card
6. Campus collection card
7. QR mission card
8. Club/event recruitment card
9. Campus info card
10. Walking progress bottom card
11. Bottom navigation

Home must immediately communicate:

- 학생식당 = 설치 이유
- 나섬이/미션 = 재방문 이유
- 캠퍼스 참여 허브 = 학교 안 확산 이유

## Department Intro Feature

학과 소개 기능은 단순 홍보가 아니라 캠퍼스 탐색 기능입니다.

It helps:

- freshmen
- transfer-interested students
- commuters
- dorm students
- students visiting other buildings
- students looking for professor offices or department offices

### Department Detail Fields

- 학과명
- 소속 단과대
- 대표 키워드
- 한 줄 소개
- 배우는 내용
- 진로 방향
- 주요 건물
- 학과 사무실 위치
- 교수님 연구/실험실 안내
- 학생회/행사 정보
- 전과 관심자 참고 메모
- 관련 나섬이
- 관련 QR 미션

### Rule

Do not present department information as official unless verified.

Use labels like:

- 확인 필요
- 학과 제공 정보
- 운영진 확인

## Campus Map Direction

Campus Map should be a campus exploration map, not just a normal map.

### Map Features

- real building names
- building pins
- Nasumi mission pins
- department links
- cafeteria
- library
- dormitory
- smoking area guide
- alert pins
- route guide

### Realism Rule

Use actual Paichai University building names and layout direction as much as possible.

Avoid fictional building names in final UI.

## Responsibility Boundaries

The app must not claim to operate events.

### App Handles

- notice structure
- visibility
- interest saving
- QR mission state
- local collection
- campus info organization
- guide screens

### App Does Not Handle

- venue reservation
- budget execution
- safety responsibility
- official school approval
- on-site staffing
- conflict judgment
- official representation

## Implementation Rule

Generated images are visual targets.

Flutter implementation should match:

- layout hierarchy
- color mood
- card shape
- mascot placement
- bottom navigation
- hero section structure

But exact generated image assets must be replaced with controlled assets before release.

## Risk

AI-generated images may contain:

- text mistakes
- inconsistent mascot details
- inaccurate buildings
- non-reproducible icons

Therefore, final implementation needs:

- fixed text strings
- reusable Flutter components
- controlled mascot assets
- verified building data
- real screenshots for store listing

## Next Step

v2.8 should create the Department Intro IA and data model.

v3.0 should not add new major features. It should package the internal beta candidate.
