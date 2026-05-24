# Paejae Pick 2.0 v0.9 Auth and Privacy Design

## Goal

v0.9 defines the account, authentication, and privacy direction before v1.0 release candidate.

This version does not connect Firebase or Supabase yet.

The goal is to make the app release-ready in structure before adding real backend features.

## Why This Matters

Paejae Pick targets real student users.

Before release, the app must clearly define:

- what data is collected
- what data is stored locally
- what data is not collected
- how account/login will work later
- how users can reset local data
- what features are mock in v1.0

## v0.9 Scope

- Privacy guide screen
- Local data reset
- My Page privacy menu
- Login screen privacy notice link
- Auth roadmap document

## Current v1.0 Data Policy

v1.0 stores only local mock data.

Stored locally:

- collected cards
- favorite clubs
- mission/card states

Not stored on server:

- real name
- student number
- phone number
- real-time location
- cafeteria visit history
- facility report identity
- professor office visit logs

## Future Auth Plan

### v1.1 Candidate

- Firebase Auth or Supabase Auth
- school email verification
- nickname
- department
- grade

### Not in v1.0

- real school email authentication
- server sync
- ranking based on personal identity
- location tracking
- official school account integration

## Principle

Paejae Pick should be useful before collecting sensitive data.

The first release should prove student demand with minimum privacy risk.
