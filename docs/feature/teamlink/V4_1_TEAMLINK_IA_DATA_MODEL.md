# 배재Pick 2.0 v4.1 TeamLink IA / Data Model

## Feature Name

배재 팀링크

## Proposal Title

배재 팀링크: 공모전 팀원 매칭을 통한 학생 소통·협력 활성화 방안

## One-Line Summary

공모전에 참여하고 싶은 학생들이 관심 분야와 역할을 기준으로 팀원을 찾고, 학과 간 협업을 시작할 수 있게 돕는 교내 팀 매칭 기능입니다.

## Problem

공모전에 참여하고 싶어도 많은 학생들이 팀원을 구하지 못해 참여를 포기합니다.

예시:

- 개발은 가능하지만 디자인을 못하는 학생
- 발표는 잘하지만 기획이 어려운 학생
- 자료조사는 가능하지만 팀장을 맡기 부담스러운 학생
- 아이디어는 있지만 구현할 사람을 못 찾는 학생
- 타 학과 학생과 협업하고 싶지만 연결 경로가 없는 학생
- 공모전 공지를 늦게 보거나 놓치는 학생

현재는 에브리타임, 카카오톡방, 지인 소개, 학과 공지에 의존해야 합니다.

이 방식은 빠르지만 구조적이지 않고, 다른 학과와 연결되기 어렵습니다.

## Core Goal

TeamLink의 목표는 단순 모집 게시판이 아닙니다.

핵심 목표는 다음과 같습니다.

- 공모전 참여율 증가
- 학과 간 협업 활성화
- 학생 역량 강화
- 학교 대외 성과 향상
- 앱 접속 명분 강화

## Why It Belongs Inside The App

웹사이트보다 앱이 더 적합한 이유:

- 학생이 공모전 마감일을 빠르게 확인할 수 있음
- 팀원 모집 알림을 받을 수 있음
- 학과백과, 동아리, 참여 허브와 연결 가능
- 모바일에서 바로 지원/문의 흐름으로 이어짐
- 공지 확인을 앱 접속 명분으로 만들 수 있음

## Information Architecture

### 1. Contest Notice Hub

공모전 정보를 모아 보여주는 영역입니다.

- 어떤 공모전이 열렸는지 확인
- 마감일 확인
- 팀 모집 가능 여부 확인
- 관련 분야 확인

### 2. Team Recruitment Board

공모전별 팀원 모집글을 보여주는 영역입니다.

- 현재 팀이 필요한 역할 확인
- 내 역할과 맞는 팀 찾기
- 팀장 부담 없이 참여 시작

### 3. Role Matching

역할 기반으로 팀원을 찾는 영역입니다.

- 기획, 개발, 디자인, 발표 등 필요한 역할 표시
- 자기 강점 기반 팀 탐색
- 학과 간 협업 유도

### 4. My TeamLink Profile

학생이 본인의 관심 분야와 가능한 역할을 설정하는 영역입니다.

- 내가 가능한 역할 표시
- 관심 분야 표시
- 포트폴리오 / GitHub / 작업물 링크 연결 가능

## Core Data Models

### ContestNotice

Fields:

- contest_id
- title
- field
- organizer
- deadline
- team_size
- description
- official_link
- status
- required_roles
- created_at
- updated_at
- verification_status

### TeamRecruitment

Fields:

- team_id
- contest_id
- team_name
- leader_name_or_alias
- leader_department
- current_member_count
- max_member_count
- needed_roles
- description
- contact_method
- status
- created_at
- updated_at
- visibility

### RoleTag

Fields:

- role_id
- role_name
- role_group
- description

### TeamLinkProfile

Fields:

- user_id
- department
- grade
- available_roles
- interest_fields
- available_time
- portfolio_link
- github_link
- contact_preference
- visibility

### ApplicationStatus

Fields:

- application_id
- team_id
- user_id
- role
- message
- status
- created_at
- updated_at

## Role Tags

### Planning

- 기획
- 아이디어 정리
- 정책 제안
- 문서 작성
- 자료조사

### Development

- 앱 개발
- 웹 개발
- 백엔드
- AI
- 데이터 분석
- 임베디드
- 하드웨어

### Design / Media

- UI 디자인
- 발표자료 디자인
- 영상 제작
- 카드뉴스
- 포스터

### Presentation / Operation

- 발표
- 팀장
- 일정 관리
- 대외 연락
- 제출 관리

## Status Values

### Contest Status

- 모집 예정
- 모집 중
- 마감 임박
- 마감
- 결과 발표
- 종료

### Team Status

- 모집 중
- 일부 모집 완료
- 모집 완료
- 제출 준비 중
- 제출 완료
- 종료

### Application Status

- 지원 완료
- 확인 중
- 수락
- 거절
- 취소

## MVP Screens

### 1. TeamLink Home

- upcoming contests
- deadline-soon contests
- open team recruitments
- role tags

### 2. Contest Detail

- contest information
- deadline
- organizer
- required roles
- teams recruiting for this contest

### 3. Team Recruitment Detail

- team name
- contest target
- current members
- needed roles
- contact method
- short team description

### 4. Create Team Recruitment

- select contest
- enter team name
- select needed roles
- write description
- set contact method

### 5. My TeamLink Profile

- select possible roles
- set interest fields
- add portfolio link
- set visibility

## Safety / Trust Rules

TeamLink cannot guarantee team quality.

The app must not claim that matching guarantees success.

Required safety rules:

- report inappropriate posts
- hide personal contact if needed
- allow anonymous or alias display
- distinguish official contest notice from student-created recruitment
- make responsibility boundaries clear

## Important Limitation

The app can connect students.

The app cannot:

- resolve all team conflicts
- guarantee work quality
- verify every student ability
- handle official contest submission
- replace professor or department guidance

## Product Principle

TeamLink should lower the first barrier.

The target user should move from:

“I want to join a contest but I have no team.”

to:

“I found a role I can join.”

## Next Step

v4.2 should implement the first TeamLink mock screen.
