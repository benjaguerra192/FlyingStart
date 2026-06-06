local Physics = {}

local carsUtils = nil
local carsUtilsLoadAttempted = false

local function getCarsUtils(Utils)
  if carsUtilsLoadAttempted then return carsUtils end
  carsUtilsLoadAttempted = true
  local okCars, loadedCars = pcall(require, 'shared/sim/cars')
  if okCars then
    carsUtils = loadedCars
  elseif Utils then
    Utils.log('shared/sim/cars unavailable: ' .. tostring(loadedCars))
  end
  return carsUtils
end

local function hasFunction(root, name)
  return root and type(root[name]) == 'function'
end

function Physics.inspectAPIs(state)
  state.api = state.api or {}
  state.api.saveCarStateAsync = hasFunction(ac, 'saveCarStateAsync')
  state.api.loadCarState = hasFunction(ac, 'loadCarState')
  state.api.isCarResetAllowed = hasFunction(ac, 'isCarResetAllowed') and ac.isCarResetAllowed()
  state.api.physicsSetCarPosition = physics and hasFunction(physics, 'setCarPosition')
  state.api.physicsSetCarVelocity = physics and hasFunction(physics, 'setCarVelocity')
  state.api.physicsEngageGear = physics and hasFunction(physics, 'engageGear')
  state.api.forceUserThrottleFor = physics and hasFunction(physics, 'forceUserThrottleFor')
  state.api.lockUserControlsFor = physics and hasFunction(physics, 'lockUserControlsFor')
  state.api.overrideCarControls = hasFunction(ac, 'overrideCarControls')
  state.api.carsUtils = carsUtils ~= nil or not carsUtilsLoadAttempted
  ac.log('[FlyingStart] Physics API inspected')
end

function Physics.estimateMaxSpeedKmh(config)
  return config.fallback_max_speed_kmh or 300, 'fallback'
end

local function readCarConfig(fileName)
  if not ac.INIConfig or not ac.INIConfig.carData then return nil end
  local ok, cfg = pcall(ac.INIConfig.carData, 0, fileName)
  if ok then return cfg end
  return nil
end

local function cfgGet(cfg, section, key, defaultValue)
  if not cfg then return defaultValue end
  local ok, value = pcall(function() return cfg:get(section, key, defaultValue) end)
  if ok and value ~= nil then return tonumber(value) or value end
  return defaultValue
end

function Physics.getGearTable(Utils)
  local drivetrain = readCarConfig('drivetrain.ini')
  local engine = readCarConfig('engine.ini')
  local tyres = readCarConfig('tyres.ini')
  local ai = readCarConfig('ai.ini')

  local count = math.floor(cfgGet(drivetrain, 'GEARS', 'COUNT', 0) or 0)
  local final = cfgGet(drivetrain, 'GEARS', 'FINAL', 0) or 0
  local limiter = cfgGet(engine, 'ENGINE_DATA', 'LIMITER', 0) or cfgGet(engine, 'HEADER', 'LIMITER', 0) or 0
  if limiter <= 0 then limiter = cfgGet(engine, 'ENGINE', 'LIMITER', 0) or 0 end
  local autoUp = cfgGet(drivetrain, 'AUTO_SHIFTER', 'UP', 0) or cfgGet(ai, 'GEARS', 'UP', 0) or 0
  local rearRadius = cfgGet(tyres, 'REAR', 'RADIUS', 0) or cfgGet(tyres, 'FRONT', 'RADIUS', 0) or 0

  if count <= 0 or final <= 0 or rearRadius <= 0 then
    if Utils then Utils.log('Gear table unavailable, using fallback gear choice') end
    return nil
  end

  local shiftRpm = autoUp > 0 and autoUp or (limiter > 0 and limiter * 0.94 or 7000)
  if limiter > 0 then shiftRpm = math.min(shiftRpm, limiter * 0.98) end

  local gears = {}
  for i = 1, count do
    local ratio = cfgGet(drivetrain, 'GEARS', 'GEAR_' .. tostring(i), 0) or 0
    if ratio > 0 then
      local speedKmh = ((shiftRpm / (ratio * final)) / 60) * (2 * math.pi * rearRadius) * 3.6
      gears[#gears + 1] = { gear = i, ratio = ratio, maxKmh = speedKmh }
    end
  end

  if #gears == 0 then return nil end
  return gears, string.format('drivetrain.ini %.0f rpm', shiftRpm)
end

function Physics.chooseGearForSpeed(speedKmh, Utils)
  local gears, source = Physics.getGearTable(Utils)
  if gears then
    for _, entry in ipairs(gears) do
      if speedKmh <= entry.maxKmh * 0.98 then
        return entry.gear, source, gears
      end
    end
    return gears[#gears].gear, source, gears
  end

  if speedKmh < 80 then return 2, 'fallback', nil end
  if speedKmh < 150 then return 3, 'fallback', nil end
  return 4, 'fallback', nil
end

function Physics.applyVelocity(carIndex, velocity, Utils)
  if physics and physics.setCarVelocity then
    local ok, result = pcall(physics.setCarVelocity, carIndex, velocity)
    if ok then
      Utils.log('Velocity applied with physics.setCarVelocity')
      return true
    end
    Utils.log('physics.setCarVelocity failed: ' .. tostring(result))
  end
  return false
end

function Physics.setPosition(target, Utils, callback)
  if physics and physics.setCarPosition then
    Utils.log('Setting car position with physics.setCarPosition')
    local okPosition, positionError = pcall(physics.setCarPosition, 0, target.position, target.tangent)
    if okPosition then
      Utils.log('Direct position success')
      callback(true)
    else
      Utils.log('physics.setCarPosition failed: ' .. tostring(positionError))
      callback(false, 'physics.setCarPosition failed: ' .. tostring(positionError))
    end
    return
  end
  callback(false, 'physics.setCarPosition is not available in this CSP build')
end

function Physics.launchVelocity(targetVelocity, Utils)
  Physics.applyVelocity(0, targetVelocity, Utils)
  if type(setTimeout) == 'function' then
    setTimeout(function()
      Physics.applyVelocity(0, targetVelocity, Utils)
    end, 0.05)
  end
end

function Physics.applyGear(gear, Utils)
  if physics and physics.engageGear and gear then
    local ok, result = pcall(physics.engageGear, 0, gear)
    if ok then
      Utils.log('Gear engaged: ' .. tostring(gear))
      return true
    end
    Utils.log('physics.engageGear failed: ' .. tostring(result))
  end
  return false
end

function Physics.teleportWithState(target, targetVelocity, gear, Utils, callback)
  local directDone = false
  Physics.setPosition(target, Utils, function(ok, reason)
    if ok then
      directDone = true
      Physics.launchVelocity(targetVelocity, Utils)
      Utils.log('Direct teleport success')
      callback(true)
    else
      callback(false, reason)
    end
  end)
  if directDone or (physics and physics.setCarPosition) then return end

  if ac.isCarResetAllowed and not ac.isCarResetAllowed() then
    callback(false, 'Car reset/state loading is not allowed in this session. Use single-car offline Practice or Hotlap.')
    return
  end

  local cars = getCarsUtils(Utils)
  if not ac.saveCarStateAsync or not ac.loadCarState or not cars then
    callback(false, 'Car state APIs are not available in this CSP mode')
    return
  end

  local completed = false
  Utils.log('Saving car state')
  ac.saveCarStateAsync(function(err, data)
    if completed then return end
    completed = true
    local okCallback, callbackError = pcall(function()
      if err and err ~= '' then
        callback(false, err)
        return
      end

      Utils.log('Car state saved')
      local currentTransform = cars.getCarStateTransform(data)
      if not currentTransform then
        callback(false, 'Unable to read saved car transform')
        return
      end

      Utils.log('Editing car state transform')
      local targetTransform = mat4x4.look(target.position, target.position + target.tangent, target.up or vec3(0, 1, 0))
      local transformDelta = targetTransform:mul(currentTransform:inverse())
      local edited = cars.alterCarStateTransform(data, transformDelta)
      if edited then
        edited = cars.alterCarStateVelocity(edited, targetVelocity, vec3())
      end
      if not edited then
        callback(false, 'Unable to alter saved car state')
        return
      end

      Utils.log('Loading edited car state')
      local loaded = ac.loadCarState(edited, nil, 0, 30)
      if loaded then
        Physics.applyVelocity(0, targetVelocity, Utils)
        Utils.log('Teleport success')
        callback(true)
      else
        callback(false, 'ac.loadCarState returned false; only offline practice/hotlap-like modes can load arbitrary car states')
      end
    end)
    if not okCallback then
      callback(false, 'Unexpected physics error: ' .. tostring(callbackError))
    end
  end)

  return function()
    if completed then return false end
    completed = true
    callback(false, 'Timed out while saving car state; try Practice or Hotlap offline with CSP Lua apps enabled')
    return true
  end
end

function Physics.releaseControl(targetSpeedKmh)
  if physics and physics.lockUserControlsFor then physics.lockUserControlsFor(0) end
  if physics and physics.forceUserThrottleFor then physics.forceUserThrottleFor(0.35, 1) end
end

return Physics