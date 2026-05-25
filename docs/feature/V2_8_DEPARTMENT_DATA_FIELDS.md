# 배재Pick 2.0 Department Data Fields

## Required Fields

| Field | Meaning | Example |
|---|---|---|
| department_id | internal id | computer_engineering |
| department_name | 학과명 | 컴퓨터공학과 |
| college_name | 단과대 | AI·SW창의융합대학 |
| short_intro | 한 줄 소개 | 소프트웨어와 시스템을 설계하는 학과 |
| keywords | 대표 키워드 | 앱, 서버, AI, 임베디드 |
| main_building | 주요 건물 | 정보과학관 |
| building_code | 건물 코드 | IT |
| verification_status | 정보 상태 | mock / 확인 필요 |

## Optional Fields

| Field | Meaning |
|---|---|
| department_office_location | 학과 사무실 위치 |
| professor_research_hint | 교수님 연구 분야 안내 |
| what_students_learn | 배우는 내용 |
| required_skills | 필요한 기초 역량 |
| common_courses | 주요 과목 |
| career_paths | 진로 방향 |
| related_certifications | 관련 자격증 |
| transfer_interest_note | 전과 관심자 참고 |
| student_council_status | 학생회 정보 |
| department_events | 학과 행사 |
| freshman_tip | 신입생 팁 |
| commuter_tip | 통학생 팁 |
| dorm_student_tip | 기숙사생 팁 |
| related_nasumi_id | 연결 나섬이 |
| qr_mission_code | QR 미션 코드 |
| map_pin_id | 캠퍼스맵 핀 |
| nearby_places | 주변 장소 |
| last_updated | 마지막 업데이트 |
| info_source | 정보 출처 |
| responsible_contact | 확인 담당 |

## Verification Rules

### mock

AI/개발자가 임시 작성한 정보입니다.

### 확인 필요

실제 학과/학생회/교수 확인이 아직 필요합니다.

### 학과 제공 정보

학과 측에서 제공한 정보입니다.

### 학생회 확인

학과 학생회 또는 대표 학생이 확인한 정보입니다.

### 교수/학과실 확인

교수님 또는 학과 사무실에서 확인한 정보입니다.

### 학교 공식 정보

학교 공식 페이지 또는 공식 자료 기반 정보입니다.

## Safety Rule

Do not show uncertain department information as official.

If the source is unclear, use 확인 필요.
