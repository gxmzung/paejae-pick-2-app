# 배재Pick 2.0 v4.3 TeamLink Official Notice Source

## Goal

v4.3 connects TeamLink to an official university notice source.

TeamLink should not become a random unofficial contest board.

It should clearly distinguish:

- official university notices
- external official contest notices
- student-created team recruitment posts
- mock/sample data

## Official Source Candidate

배재대학교 일반공지

URL:

https://www.pcu.ac.kr/kor/article/Notify_1

## Why This Matters

Contest, program, mentoring, startup, career, and student participation notices can appear on official university notice pages.

If TeamLink only shows student-created posts, trust becomes weak.

If TeamLink starts from official notices, students can trust that the contest or program exists.

## Product Rule

TeamLink must separate two layers.

### 1. Official Notice Layer

This is the source notice.

Examples:

- university general notice
- department notice
- career center notice
- startup support notice
- external contest linked by university

### 2. Student Team Recruitment Layer

This is the student-created team layer.

Examples:

- looking for developer
- looking for designer
- looking for presenter
- looking for planning/research member
- looking for team leader

## UI Label Rules

Use labels:

- 학교 공지
- 외부 공식
- 학생 모집글
- 확인 필요
- 마감 임박
- 모집 중

## Safety Rule

Do not present student recruitment posts as official notices.

Do not present mock data as real contest data.

Official notice source and student team recruitment must be visually separated.

## MVP Behavior

In the MVP, TeamLink can show:

- a source card for the official notice board
- mock contest cards
- mock recruitment cards
- clear limitation message

## Future Behavior

Later versions can add:

- manual notice registration
- admin verification
- deadline parser
- official notice link button
- saved contests
- deadline notification
- team recruitment under each notice

## Next Step

v4.4 should add TeamLink recruitment detail and create recruitment mock flow.
