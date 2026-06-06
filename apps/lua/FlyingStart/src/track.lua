local Track = {}

local function hasFunction(name)
  local holder = ac
  for part in string.gmatch(name, '[^%.]+') do
    holder = holder and holder[name]
  end
  return type(holder) == 'function'
end

function Track.inspectAPIs(state)
  state.api = state.api or {}
  state.api.hasTrackSpline = hasFunction('hasTrackSpline')
  state.api.trackProgressToWorldCoordinate = hasFunction('trackProgressToWorldCoordinate')
  state.api.trackCoordinateToWorld = hasFunction('trackCoordinateToWorld')
  state.api.worldCoordinateToTrack = hasFunction('worldCoordinateToTrack')
  state.api.getTrackAISplineSides = hasFunction('getTrackAISplineSides')
  state.api.raycastTrack = physics and type(physics.raycastTrack) == 'function'
  state.api.trackSplineAvailable = state.api.hasTrackSpline and ac.hasTrackSpline() or false
  state.trackID = ac.getTrackFullID and ac.getTrackFullID('/') or (ac.getTrackID and ac.getTrackID() or 'unknown')
  state.trackLengthM = (ac.getSim() and ac.getSim().trackLengthM) or 0
  if state.api.trackSplineAvailable then
    state.logTrack = 'Track spline loaded'
    ac.log('[FlyingStart] Track spline loaded')
  else
    state.logTrack = 'Track spline not reported by CSP'
    ac.log('[FlyingStart] Track spline not reported by CSP')
  end
end

function Track.progressBeforeFinish(distanceMeters)
  local sim = ac.getSim()
  local length = sim and sim.trackLengthM or 0
  if length <= 1 then return 0.995 end
  return (1 - (distanceMeters / length)) % 1
end

function Track.worldAtProgress(progress, heightOffset)
  if ac.trackProgressToWorldCoordinate then
    local ok, pos = pcall(ac.trackProgressToWorldCoordinate, progress, false)
    if ok and pos then
      pos.y = pos.y + (heightOffset or 0)
      return pos, 'trackProgressToWorldCoordinate'
    end
  end
  if ac.trackCoordinateToWorld then
    local ok, pos = pcall(ac.trackCoordinateToWorld, vec3(0, heightOffset or 0, progress))
    if ok and pos then return pos, 'trackCoordinateToWorld' end
  end
  return nil, 'none'
end

function Track.ground(pos, offset)
  return pos
end

function Track.sample(progress, config, Utils)
  local sim = ac.getSim()
  local length = math.max(1, sim and sim.trackLengthM or 1)
  local delta = math.max(0.0005, math.min(0.01, 2 / length))
  local p0 = Utils.wrap01(progress - delta)
  local p1 = Utils.wrap01(progress + delta)
  local center, source = Track.worldAtProgress(progress, config.surface_offset_m or 0.18)
  local before = Track.worldAtProgress(p0, config.surface_offset_m or 0.18)
  local after = Track.worldAtProgress(p1, config.surface_offset_m or 0.18)

  if not center or not before or not after then
    return nil, 'CSP did not provide spline world coordinates'
  end

  center = Track.ground(center, config.surface_offset_m)
  before = Track.ground(before, config.surface_offset_m)
  after = Track.ground(after, config.surface_offset_m)

  local tangent = Utils.normalize(before - after, vec3(0, 0, 1))
  return {
    progress = progress,
    position = center,
    tangent = tangent,
    up = vec3(0, 1, 0),
    source = source,
    lengthM = length
  }
end

function Track.computeLaunchPoint(config, Utils)
  local progress = Track.progressBeforeFinish(config.distance_before_finish or 10)
  local sample, err = Track.sample(progress, config, Utils)
  if not sample then return nil, err end
  Utils.log('Start finish detected at progress 1.000')
  Utils.log(string.format('Launch position computed at progress %.5f, %.1f m before finish', progress, config.distance_before_finish or 10))
  return sample
end

return Track