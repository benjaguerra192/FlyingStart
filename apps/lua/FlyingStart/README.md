# Flying Start

Flying Start is a CSP Lua app for Assetto Corsa that places the user car near the start/finish line and launches it at a configurable percentage of estimated maximum speed.

## Requirements

- Assetto Corsa
- Content Manager
- A recent Custom Shaders Patch build with Lua apps enabled

## Installation

Drag `FlyingStart_v1.6_CM.zip` into Content Manager or copy `apps/lua/FlyingStart` into your Assetto Corsa installation.

For Content Manager compatibility, the zip root must contain `apps/lua/FlyingStart/...`. Do not zip only the `FlyingStart` folder by itself.

Enable the app in Content Manager, start a session, open **Flying Start**, then press **Start Flying Lap**.

## How It Works

- Uses `ac.hasTrackSpline`, `ac.trackCoordinateToWorld` or `ac.trackProgressToWorldCoordinate`.
- Computes a point before normalized progress `1.0`, using the configured distance and the current track length.
- Samples adjacent spline points to get the correct forward tangent.
- Uses `physics.setCarPosition` and `physics.setCarVelocity` when available.
- Engages the best gear for the configured launch speed.
- Can hold max throttle briefly after GO when Max throttle exit is enabled.

`ac.loadCarState` is restricted by CSP/AC to supported offline modes. If the current session blocks it, the app reports the exact failure in its diagnostics panel.

## Options

- Launch speed: 50%, 60%, 70%, 80%, 90%, 100%
- Countdown duration
- Distance before finish
- Fallback maximum speed
- Surface offset
- Max throttle exit
- Global accent color
- Diagnostics panel

## Logs

Look for lines prefixed with `[FlyingStart]` in CSP Lua logs.
