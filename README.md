# Paejae Pick 2.0

Paejae Pick 2.0 is a Flutter-based smart campus MVP app concept for Paichai University students.

It connects cafeteria information, campus exploration, Nasumi collection, code-based missions, department tours, club notices, and future CityBrain operation data.

## Current Version

`v1.5-internal-test-package`

## Core Strategy

The first reason to install Paejae Pick is cafeteria information.

The reason to return is Nasumi collection, campus missions, department tours, and club notices.

## Implemented Features

### v0.1 Flutter MVP Shell

- Flutter project structure
- Bottom navigation
- Home
- Campus map mock
- Collection mock
- Club notice mock
- My page mock

### v0.2 Design Polish

- Splash screen
- Login mock screen
- Nasumi visual concept

### v0.3 Collection Mission

- Mission code input
- Local card acquisition
- Mission complete screen
- SharedPreferences storage

### v0.4 Collection Detail

- Collection progress
- Acquired / locked card state
- Card detail screen
- Acquisition condition display

### v0.5 CityBrain Cafeteria

- Cafeteria detail screen
- Today's menu
- Congestion status mock
- Estimated waiting time
- Recommended visit time
- Menu satisfaction buttons
- Menu card acquisition
- Local collection integration

### v0.6 Release PRD

- Product requirements document
- v1.0 release scope
- Cost and privacy plan
- Android release readiness checklist

### v0.7 Department Nasumi Tour

- Department Nasumi Tour screen
- Department mission codes
- Department building information
- Local collection integration

### v0.8 Club Notice Detail

- Club notice detail screen
- Structured recruitment information
- Favorite club local storage
- My Page favorite count integration

### v0.9 Auth and Privacy Design

- Privacy guide screen
- Local data reset
- Login privacy notice link
- My Page privacy menu

### v1.0 Release Candidate

- Android-first MVP scope
- Release candidate documentation
- Store-readiness direction
- Privacy-light local-first strategy


### v1.3 QR Mission Polish

- QR scan mock screen
- Improved mission code entry
- Quick internal test code buttons
- Better success/failure feedback
- Mission code list for internal testing

### v1.4 UI / Screenshot Prep

- Screenshot target list
- Internal test demo flow
- Release-facing demo scenario
- Build verification for presentation


### v1.5 Internal Test Package

- Internal tester guide
- Android APK installation guide
- Feedback form questions
- Release package notes
- Internal testing preparation
\n
### v1.9 Club Notice Submit Mock

- Club notice submission mock
- Structured recruitment request flow
- Club name / title / category / contact / description fields
- Submit confirmation without backend
- Direction toward admin-approved club notices


### v2.0 Campus Participation Hub

- Reframes club notice hall as campus participation infrastructure
- Adds participation type explanation
- Clarifies that the app does not operate events directly
- Positions the app as a structured notice and recruitment hub
- Prepares expansion to department events, projects, volunteer groups, and contest teams
\n
### v2.1 Participation Notice Types

- Defines Campus Participation Hub notice types
- Club recruitment
- Department / office events
- Project team recruitment
- Volunteer / supporters notices
- Contest team recruitment
- Clarifies host/app responsibility split


### v2.2 Participation Status Labels

- Defines notice status labels
- Host submitted
- Info check needed
- Under review
- Visible
- Closed
- Hidden
- Clarifies that checked does not mean officially approved

## Tech Stack

- Flutter
- Dart
- SharedPreferences
- Android first
- iOS planned later

## v1.0 Scope

Included:

- Splash / Login mock
- Home
- Cafeteria detail
- Code-based mission
- Collection / card detail
- Department Nasumi Tour
- Club notice detail
- My Page
- Privacy guide
- Local data reset

Excluded from v1.0:

- Real school email authentication
- Real QR camera scanner
- Firebase/Supabase sync
- Real-time location tracking
- Admin console
- Official school data integration
- POS/kiosk integration
- YOLO congestion integration

## Release Direction

v1.0 targets Android internal testing first.

The app intentionally avoids heavy backend usage and sensitive personal data storage in the early stage.

## Test Focus

- Does cafeteria information create a reason to install?
- Does Nasumi collection create a reason to return?
- Does department tour help students learn campus structure?
- Does the club notice hall feel more structured than scattered posts?
