# 배재Pick 2.0 v3.9 Department Screenshot QA / Gap Report

## Goal

v3.9 compares the actual Flutter Department Dictionary screens with the generated visual concept.

The goal is not to add new features.

The goal is to find UI gaps before polishing the Department Dictionary further.

## Screens To Compare

### 1. Department Dictionary Main

Check:

- Header title
- Subtitle readability
- Hero card size
- Nasumi placement
- Search field
- Filter chips
- Result count
- First department cards
- Bottom spacing

### 2. Search Result State

Check:

- Search field input readability
- Result count update
- Department card spacing after filtering
- Empty result message

### 3. Category Filter State

Check:

- Selected chip color
- Unselected chip contrast
- Horizontal scrolling
- Category names
- Result count

### 4. Department Detail

Check:

- Hero card visual balance
- Department title readability
- Recommendation section
- Learning topics
- Career paths
- Admission/transfer note
- Nasumi / QR mission section
- Back button placement

### 5. Filter Guide

Check:

- Explanation clarity
- Card spacing
- Icon consistency
- Nasumi label
- Bottom note

## Visual Gap Checklist

| Area | Current State | Target Direction | Priority |
|---|---|---|---|
| Hero card | 확인 필요 | Generated concept style | High |
| Department card | 확인 필요 | More visual, less text-heavy | High |
| Filter chips | 확인 필요 | Clear selected state | Medium |
| Search field | 확인 필요 | Rounded, bright, readable | Medium |
| Nasumi usage | 확인 필요 | More consistent mascot placement | High |
| Detail screen | 확인 필요 | Stronger section hierarchy | High |
| Text density | 확인 필요 | Reduce long blocks | High |
| Screenshot readiness | 확인 필요 | Good enough for story/DM sharing | High |

## QA Result Labels

Use these labels:

- OK
- Minor gap
- Major gap
- Needs redesign
- Blocked

## Priority Rules

### P0

Must fix before showing to professors or student councils.

Examples:

- broken layout
- text overflow
- unreadable contrast
- wrong department names
- wrong terminology

### P1

Should fix before public tester sharing.

Examples:

- awkward card spacing
- too much text
- weak visual hierarchy
- unclear button wording

### P2

Can fix later.

Examples:

- animation
- small icon polish
- microcopy improvement
- decorative illustration

## Current Assumption

The Department Dictionary is functionally working as a prototype.

However, visual consistency with the generated design concept still needs QA through real device screenshots.

## Next Step

v4.0 should apply UI fixes based on this gap report.
