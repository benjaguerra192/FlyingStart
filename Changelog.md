# Changelog

## 1.5

- Flipped the launch tangent so `physics.setCarPosition` points the car down the recta instead of backwards.
- Launch velocity uses the corrected direction.
- Gear selection now reads `drivetrain.ini`, `engine.ini`, `tyres.ini` and `ai.ini` to calculate gear speed ranges.
- The app engages the matching gear before applying flying lap velocity.
- Diagnostics now show gear API, source and gear max speeds.

## 1.4

- Pressing Start now teleports the car to the flying start point first.
- Countdown starts only after the car is positioned.
- GO applies velocity from that point instead of moving the car again.
- Main window closes 2 seconds after the flying lap starts.
- Main window reopens on new/restarted session.
- Main UI background is opaque before starting.

## 1.3

- Uses `physics.setCarPosition` plus `physics.setCarVelocity` as the primary launch method.
- Keeps `saveCarStateAsync`/`loadCarState` only as a fallback if direct positioning is unavailable.
- Reapplies velocity shortly after direct positioning when CSP timeout helpers are available.
- Adds diagnostics for direct position API availability.

## 1.2

- Removed all runtime reads of mod-car gearing/physics fields (`gearRatios`, `rpmLimiter`, `finalRatio`, `tyreRadius`).
- Launch speed now uses the configured fallback maximum speed only, avoiding the freeze after launch-point calculation.
- Added phase logs for speed selection, state save, state edit and state load.
- Added reset/state-loading availability check before trying to teleport.

## 1.1

- Added visible in-app version/build check: `v1.1 / 2026-06-06-preparing-fix`.
- Added changelog viewer inside the Assetto Corsa Lua app.
- Lazy-loads `shared/sim/cars` only when launching instead of during circuit/app load.
- Added a 6 second timeout for `ac.saveCarStateAsync`.
- Added defensive error reporting around car state editing/loading.
- Avoids `physics.raycastTrack` while computing the launch point.

## 1.0

- Initial release.
- CSP spline-based launch position.
- Direction detection from sampled spline tangent.
- Car state teleport with velocity injection.
- Configurable launch speed, countdown, distance, fallback Vmax and diagnostics.
- Professional CSP UI with settings window and runtime API reporting.