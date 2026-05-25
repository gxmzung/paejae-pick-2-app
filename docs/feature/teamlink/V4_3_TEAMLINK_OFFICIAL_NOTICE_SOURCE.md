# 배재Pick 2.0 v4.3 TeamLink Official Notice Source

## Goal

v4.3 connects the TeamLink concept to an official notice source.

TeamLink should not become a random unofficial contest board.

It should clearly distinguish:

- official university notices
- student-created team recruitment posts
- mock/sample data
- external contest links

## Official Source Candidate

배재대학교 일반공지

URL:

https://www.pcu.ac.kr/kor/article/Notify_1

## Why This Matters

Contest and program notices are often posted on official university notice pages.

If TeamLink only shows student-created posts, trust becomes weak.

If TeamLink starts from official notices, students can trust that the contest or program exists.

## Product Rule

TeamLink must separate two layers.

### 1. Official Contest Notice

This is the source notice.

Examples:

- university official notice
- department notice
- career center notice
- external contest notice linked by university

### 2. Student Team Recruitment

This is the student-created layer.

Examples:

- looking for developer
- looking for designer
- looking for presenter
- looking for planning/research member

## UI Label Rules

Use labels:

- 학교 공지
- 외부 공모전
- 학생 모집글
- 확인 필요
- 마감 임박
- 모집 중

## Safety Rule

Do not present student recruitment posts as official notices.

Do not present mock data as real contest data.

Official notice source and student team post must be visually separated.

## MVP Behavior

In the MVP, TeamLink can show:

- a source card for the official notice board
- mock contest cards
- mock recruitment cards
- clear limitation message

## Future Behavior

Later versions can add:

- notice crawling or manual registration
- admin verification
- deadline parser
- official notice link button
- saved contests
- deadline notification
- team recruitment under each notice

## Next Step

v4.4 should add TeamLink recruitment detail and create recruitment mock flow.
