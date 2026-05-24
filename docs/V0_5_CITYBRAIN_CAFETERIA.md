# Paejae Pick 2.0 v0.5 CityBrain Cafeteria

## Goal

v0.5 makes the cafeteria feature a core reason to open Paejae Pick every day.

The cafeteria module is the practical entry point of the app.  
Nasumi collection, missions, and club notices make users return, but cafeteria information gives students an immediate reason to install and open the app.

## Why Cafeteria First?

Students repeatedly ask these questions:

- What is today's menu?
- Is the cafeteria crowded right now?
- Can I eat before class?
- Should I go later?
- Is today's menu worth eating?
- Should I go to a convenience store instead?

Therefore, Paejae Pick should not be only a collection app.  
It should start from a daily campus need.

## v0.5 Scope

- Cafeteria detail screen
- Today's menu
- Operating hours
- Current congestion status
- Estimated waiting time
- Recommended visit time
- Satisfaction buttons
- Menu card acquisition
- Local storage through SharedPreferences
- Link from Home cafeteria card to detail screen

## Current Implementation

This version uses local/mock data.

- No real POS integration
- No YOLO integration
- No server sync
- No personal visit history tracking
- No GPS tracking

## Privacy Principle

v0.5 does not store personal cafeteria visit history on a server.

The menu card acquisition is stored locally using SharedPreferences.  
This keeps the MVP low-cost and privacy-light.

## Future Expansion

Later versions can connect this screen to CityBrain API:

- Real menu data
- YOLO-based congestion estimate
- Manual manager input
- Crowd-sourced congestion vote
- Cafeteria satisfaction analytics
- Time-based operational report
