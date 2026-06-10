local Launch = {}

Launch.State = {
  IDLE = 'IDLE',
  POSITIONING = 'POSITIONING',
  COUNTDOWN = 'COUNTDOWN',
  PREPARING = 'PREPARING',
  LAUNCHING = 'LAUNCHING',
  SUCCESS = 'SUCCESS',
  ERROR = 'ERROR'
}

function Launch.createState(config)
  return {
    mode = Launch.State.IDLE,
    timer = 0,
    countdown = config.countdown_duration or 3,
    message = 'Ready',
    error = '',
    lastLaunch = nil,
    api = {},
    uiAnim = 0,
    busy = false,
    launchTimeout = nil,
    launchTimeoutAt = nil,
    hideAfter = nil,
    windowHidden = false,
    sessionKey = nil
  }
end

local function computeLaunch(state, Track, Physics, Utils)
  state.mode = Launch.State.POSITIONING
  state.message = 'Positioning'
  state.busy = true
  state.timer = 0
  state.launchTimeout = nil
  state.launchTimeoutAt = nil
  state.hideAfter = nil

  local target, err = Track.computeLaunchPoint(state.config, Utils)
  if not target then
    state.mode = Launch.State.ERROR
    state.error = err or 'Unable to compute launch position'
    state.message = 'Error'
    state.busy = false
    Utils.log('ERROR: ' .. state.error)
    return
  end

  Utils.log('Choosing launch speed')
  local vmax, vmaxSource = Physics.estimateMaxSpeedKmh(state.config)
  local targetSpeedKmh = vmax * (state.config.launch_speed_percent or 70) / 100
  local targetVelocity = -target.tangent * (targetSpeedKmh / 3.6)
  local gear, gearSource, gearTable = Physics.chooseGearForSpeed(targetSpeedKmh, Utils)

  state.lastLaunch = {
    progress = target.progress,
    speedKmh = targetSpeedKmh,
    vmaxKmh = vmax,
    vmaxSource = vmaxSource,
    position = target.position,
    tangent = target.tangent,
    gear = gear,
    gearSource = gearSource,
    gearTable = gearTable,
    source = target.source
  }
  return target, targetVelocity, targetSpeedKmh, gear
end

function Launch.start(state, Track, Physics, Utils)
  if state.busy or state.mode == Launch.State.COUNTDOWN or state.mode == Launch.State.POSITIONING or state.mode == Launch.State.LAUNCHING then return end
  state.error = ''
  state.windowHidden = false

  local target, targetVelocity, targetSpeedKmh, gear = computeLaunch(state, Track, Physics, Utils)
  if not target then return end

  Utils.log('Moving to flying start point before countdown')
  Physics.setPosition(target, Utils, function(ok, reason)
    state.busy = false
    if ok then
      state.mode = Launch.State.COUNTDOWN
      state.timer = 0
      state.countdown = state.configCountdown or state.countdown or 3
      state.message = tostring(math.ceil(state.countdown))
      state.pendingVelocity = targetVelocity
      state.pendingSpeedKmh = targetSpeedKmh
      state.pendingGear = gear
      Utils.log('Countdown started after positioning')
    else
      state.mode = Launch.State.ERROR
      state.error = reason or 'Unable to move to flying start point'
      state.message = 'Error'
      Utils.log('ERROR: ' .. state.error)
    end
  end)
end

function Launch.prepareAndLaunch(state, Track, Physics, Utils)
  local targetVelocity = state.pendingVelocity
  local targetSpeedKmh = state.pendingSpeedKmh or 0
  if not targetVelocity then
    local target
    target, targetVelocity, targetSpeedKmh = computeLaunch(state, Track, Physics, Utils)
    if not target then return end
  end

  state.mode = Launch.State.LAUNCHING
  state.message = 'Launching'
  state.busy = false
  Physics.applyGear(state.pendingGear or 2, Utils)
  Physics.launchVelocity(targetVelocity, Utils)
  Physics.releaseControl(state.config)
  state.mode = Launch.State.SUCCESS
  state.timer = 0
  state.message = 'GO'
  state.pendingVelocity = nil
  state.pendingSpeedKmh = nil
  state.pendingGear = nil
  state.hideAfter = 2
  Utils.log('Flying lap started')
end

function Launch.update(state, dt, Track, Physics, Utils)
  state.timer = (state.timer or 0) + dt
  state.uiAnim = (state.uiAnim or 0) + dt
  if not state.config then return end

  if state.mode == Launch.State.COUNTDOWN then
    local duration = math.max(1, state.config.countdown_duration or 3)
    local remaining = duration - state.timer
    if remaining > 0 then state.message = tostring(math.max(1, math.ceil(remaining)))
    else
      state.message = 'GO'
      Launch.prepareAndLaunch(state, Track, Physics, Utils)
    end
  elseif state.mode == Launch.State.SUCCESS and state.timer > 2.5 then
    state.mode = Launch.State.IDLE
    state.message = 'Ready'
  elseif state.launchTimeout and state.launchTimeoutAt and state.timer > state.launchTimeoutAt then
    state.launchTimeout()
  end
end

function Launch.shouldHideWindow(state)
  return state.hideAfter and state.timer > state.hideAfter and not state.windowHidden
end

function Launch.markWindowHidden(state)
  state.windowHidden = true
end

function Launch.resetForSession(state, Utils)
  state.mode = Launch.State.IDLE
  state.timer = 0
  state.message = 'Ready'
  state.error = ''
  state.busy = false
  state.hideAfter = nil
  state.windowHidden = false
  state.pendingVelocity = nil
  state.pendingSpeedKmh = nil
  state.pendingGear = nil
  Utils.log('Session reset detected, Flying Start UI restored')
end

function Launch.cancel(state, Utils)
  state.mode = Launch.State.IDLE
  state.busy = false
  state.launchTimeout = nil
  state.launchTimeoutAt = nil
  state.message = 'Ready'
  state.error = ''
  if physics and physics.forceUserThrottleFor then physics.forceUserThrottleFor(0, 0) end
  if physics and physics.lockUserControlsFor then physics.lockUserControlsFor(0) end
  Utils.log('Launch cancelled')
end

return Launch
