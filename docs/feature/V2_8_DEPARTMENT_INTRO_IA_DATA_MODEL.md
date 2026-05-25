# 배재Pick 2.0 v2.8 Department Intro IA / Data Model

## Goal

v2.8 defines the information architecture and data model for the Department Intro feature.

The feature is not just for department promotion.

It supports campus exploration, department discovery, transfer exploration, and building-based Nasumi collection.

## Why This Feature Matters

배재대학교는 전과가 가능하고, 학생들은 본인 학과 외 다른 학과나 건물 정보를 잘 모르는 경우가 많습니다.

특히 신입생, 통학생, 기숙사생, 전과 관심자에게 학과 소개와 건물 안내는 실제 가치가 있습니다.

## Product Role

Department Intro connects:

- Campus Map
- Department Nasumi Tour
- QR Mission
- Campus Collection
- Department offices
- Professor/research areas
- Transfer interest
- Student council / department events

## User Types

### 1. Freshman

Needs to understand:

- where departments are
- what each department does
- where the department office is
- what kind of people/events exist

### 2. Transfer-interested student

Needs to understand:

- what the department studies
- what career paths are common
- what subjects or skills are important
- what building or office to visit

### 3. Dorm student

May have time to explore campus and collect department Nasumi.

### 4. Commuter

Needs quick, location-based information because they do not stay on campus long.

### 5. Student council / department operator

Can provide verified department introduction and event information.

## Department Detail Fields

### Basic

- department_id
- department_name
- college_name
- short_intro
- keywords
- main_building
- building_code
- department_office_location
- contact_status

### Academic

- what_students_learn
- required_skills
- common_courses
- career_paths
- related_certifications
- transfer_interest_note

### Campus Life

- student_council_status
- department_events
- club_or_study_groups
- freshman_tip
- commuter_tip
- dorm_student_tip

### Map / Mission

- related_nasumi_id
- qr_mission_code
- map_pin_id
- nearby_places
- walking_hint

### Trust / Verification

- info_source
- verification_status
- last_updated
- responsible_contact

## Verification Status

Use these labels:

- mock
- 확인 필요
- 학과 제공 정보
- 학생회 확인
- 교수/학과실 확인
- 학교 공식 정보

## Data Model Example

```json
{
  "department_id": "computer_engineering",
  "department_name": "컴퓨터공학과",
  "college_name": "AI·SW창의융합대학",
  "short_intro": "소프트웨어와 시스템을 설계하고 구현하는 학과",
  "keywords": ["앱", "서버", "AI", "임베디드", "보안"],
  "main_building": "정보과학관",
  "building_code": "IT",
  "department_office_location": "확인 필요",
  "what_students_learn": ["프로그래밍", "자료구조", "운영체제", "네트워크", "소프트웨어공학"],
  "career_paths": ["소프트웨어 개발자", "백엔드 개발자", "임베디드 개발자", "보안 엔지니어"],
  "transfer_interest_note": "전과 관심자는 프로그래밍 기초와 수학/논리 과목 준비가 필요합니다.",
  "related_nasumi_id": "cs_nasumi",
  "qr_mission_code": "CS-NASUMI",
  "verification_status": "mock"
}
Screen IA
Department List

Shows:

department name
college
keywords
building
verification status
related Nasumi status
Department Detail

Shows:

Hero card
What students learn
Career paths
Building / office guide
Student life / events
Transfer note
Related Nasumi
Related mission
Building Connection

From Department Detail, users should be able to move to:

Campus Map building detail
Department Nasumi mission
Related QR mission
nearby campus places
Product Principle

Department Intro should not become an official admission page.

It should be a student-friendly campus guide.

When information is not verified, the app must clearly mark it as mock or 확인 필요.

Next Step

v2.9 should implement the first mock Department Intro screen with a small seed dataset.
