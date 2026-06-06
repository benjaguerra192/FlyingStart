local Version = {}

Version.number = '1.5'
Version.build = '2026-06-06-direction-and-gears'
Version.label = 'v' .. Version.number .. ' / ' .. Version.build

Version.changelog = {
  '1.5 - Direction and gears build',
  '- Flips track tangent for CSP setCarPosition direction convention.',
  '- Launch velocity now follows the corrected direction.',
  '- Reads drivetrain.ini, engine.ini, tyres.ini and ai.ini to calculate gear speed ranges.',
  '- Engages the gear matching the selected launch speed before applying velocity.',
  '- Diagnostics show gear API, gear source and calculated gear max speeds.',
  '',
  '1.4 - Position then countdown build',
  '- Start button moves the car to the flying start point first.',
  '- Countdown begins only after positioning succeeds.',
  '- GO applies velocity without moving the car again.',
  '- Main window closes 2 seconds after the flying lap starts.',
  '- Main window reopens when CSP reports a new or restarted session.',
  '- UI background is now opaque before starting.',
  '',
  '1.3 - Direct position build',
  '- Uses physics.setCarPosition + physics.setCarVelocity as the primary launch method.',
  '- Avoids saveCarStateAsync/loadCarState unless setCarPosition is unavailable.',
  '- Reapplies velocity shortly after direct positioning if CSP timeout helpers are available.',
  '- Adds diagnostics for Set position API availability.',
  '',
  '1.2 - No car physics read build',
  '- Stops reading gearRatios/rpmLimiter/finalRatio from mod cars.',
  '- Uses configured fallback speed only, avoiding the Preparing hang seen with f1_2010_redbull.',
  '- Adds logs for Choosing launch speed, Saving state, Editing state and Loading state.',
  '- Checks if car reset/state loading is allowed before launching.',
  '- Does not force gears; it only loads state and applies velocity.',
  '',
  '1.1 - Preparing watchdog build',
  '- Shows version and build ID inside the Assetto Corsa app.',
  '- Adds in-app changelog so you can verify which package is loaded.',
  '- Lazy-loads shared/sim/cars only when launching.',
  '- Adds a 6 second timeout if CSP never returns from saveCarStateAsync.',
  '- Wraps launch physics edits with error reporting instead of staying stuck.',
  '- Avoids raycastTrack during launch-point preparation.',
  '',
  '1.0 - Initial release',
  '- CSP spline-based flying start position.',
  '- Configurable speed, countdown, distance and diagnostics.'
}

function Version.writeToState(state)
  state.version = Version.number
  state.build = Version.build
  state.versionLabel = Version.label
  state.changelog = Version.changelog
end

return Version