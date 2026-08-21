# Smart Mobility API Contract (Draft)

This document defines the boundary between Paejae Pick and future university,
shuttle, and NEXUS ROS2 systems. The current Flutter screens use local demo data.

## Indoor map

- `GET /v1/campus/buildings`
- `GET /v1/campus/buildings/{buildingId}/floors/{floorId}`
- `GET /v1/campus/locations/search?q={roomOrDepartmentOrProfessor}`
- `POST /v1/campus/indoor-routes`

Only officially published room and professor-office locations should be served.
Professor presence, schedules, and live occupancy are out of scope.

## Autonomous shuttle pickup

- `GET /v1/mobility/shuttles`
- `GET /v1/mobility/stops`
- `POST /v1/mobility/pickups`
- `DELETE /v1/mobility/pickups/{pickupId}`

Vehicle telemetry should expose an intentionally reduced public payload: vehicle
ID, service state, route, approximate location, ETA, and available seats.

## Autonomous delivery

- `GET /v1/delivery/zones`
- `POST /v1/deliveries`
- `GET /v1/deliveries/{deliveryId}`
- `POST /v1/deliveries/{deliveryId}/cancel`

Suggested delivery states are `accepted`, `robot_dispatched`, `in_transit`,
`arriving`, `delivered`, `cancelled`, and `operator_intervention`.

## Ownership

- Paejae Pick: authentication, consent, destination selection, requests, status UI.
- University/vehicle operator: service hours, stops, permissions, safety operations.
- NEXUS ROS2: localization, path planning, perception, control, and robot telemetry.

No production endpoint is implemented in the MVP.
