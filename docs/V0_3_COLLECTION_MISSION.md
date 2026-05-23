# Paejae Pick 2.0 v0.3 Collection Mission

## Goal

v0.3 makes the app feel closer to a real campus collection app.

The user can enter a mission code, complete a campus mission, and save an acquired card locally.

## Scope

- Mission code input screen
- Mission complete screen
- Local card acquisition storage
- Home to mission screen navigation
- Sample campus mission codes

## Sample Codes

| Code | Reward |
|---|---|
| BAEJAE-FOOD | 학생식당 나섬이 |
| LIBRARY-NIGHT | 도서관 나섬이 |
| IT-CODE | IT관 개발자 나섬이 |
| CLUB-HUB | 동아리 헌터 배지 |
| CLEAN-CAMPUS | 클린캠퍼스 배지 |

## Storage

This version uses SharedPreferences.

Later versions can migrate to Firebase or Supabase.

## Limits

- QR scanning is not implemented yet.
- Code validation is local mock logic.
- Card collection is stored only on the current device.
