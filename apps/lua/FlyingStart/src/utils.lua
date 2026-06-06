local Utils = {}

Utils.prefix = '[FlyingStart] '

function Utils.log(message)
  local line = Utils.prefix .. tostring(message)
  if ac and ac.log then ac.log(line) end
  print(line)
end

function Utils.clamp(v, minValue, maxValue)
  if v < minValue then return minValue end
  if v > maxValue then return maxValue end
  return v
end

function Utils.wrap01(v)
  v = v % 1
  if v < 0 then v = v + 1 end
  return v
end

function Utils.safeCall(label, fn, ...)
  local ok, a, b, c, d = pcall(fn, ...)
  if not ok then
    Utils.log(label .. ' failed: ' .. tostring(a))
    return nil, a
  end
  return a, b, c, d
end

function Utils.v3(x, y, z)
  return vec3(x or 0, y or 0, z or 0)
end

function Utils.len(v)
  if not v then return 0 end
  return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

function Utils.normalize(v, fallback)
  local l = Utils.len(v)
  if l < 1e-6 then return fallback or vec3(0, 0, 1) end
  return vec3(v.x / l, v.y / l, v.z / l)
end

function Utils.dot(a, b)
  return a.x * b.x + a.y * b.y + a.z * b.z
end

function Utils.copyVec(v)
  return vec3(v.x, v.y, v.z)
end

function Utils.formatKmh(v)
  return string.format('%.0f km/h', v or 0)
end

function Utils.easeOutCubic(t)
  t = Utils.clamp(t, 0, 1)
  local u = 1 - t
  return 1 - u * u * u
end

function Utils.easeInOut(t)
  t = Utils.clamp(t, 0, 1)
  if t < 0.5 then return 4 * t * t * t end
  local f = -2 * t + 2
  return 1 - (f * f * f) / 2
end

return Utils