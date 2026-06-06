# Flying Start

Flying Start is a CSP Lua app for Assetto Corsa that places the user car near the start/finish line and launches it at a configurable percentage of estimated maximum speed.

## Requirements

- Assetto Corsa
- Content Manager
- A recent Custom Shaders Patch build with Lua apps enabled

## Installation

Drag the package into Content Manager or copy `apps/lua/FlyingStart` into your Assetto Corsa installation.

Enable the app in Content Manager, start a session, open **Flying Start**, then press **Start Flying Lap**.

## How It Works

- Uses `ac.hasTrackSpline`, `ac.trackCoordinateToWorld` or `ac.trackProgressToWorldCoordinate`.
- Computes a point before normalized progress `1.0`, using the configured distance and the current track length.
- Samples adjacent spline points to get the correct forward tangent.
- Saves the current car state, transforms it to the launch point, adds forward velocity, and reloads it with `ac.loadCarState`.
- Uses `physics.setCarVelocity` when available to reinforce initial speed.

`ac.loadCarState` is restricted by CSP/AC to supported offline modes. If the current session blocks it, the app reports the exact failure in its diagnostics panel.

## Options

- Launch speed: 50%, 60%, 70%, 80%, 90%
- Countdown duration
- Distance before finish
- Fallback maximum speed
- Surface offset
- Diagnostics panel

## Logs

Look for lines prefixed with `[FlyingStart]` in CSP Lua logs.