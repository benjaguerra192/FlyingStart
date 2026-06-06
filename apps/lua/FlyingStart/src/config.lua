local Config = {}

local defaults = {
  launch_speed_percent = 70,
  countdown_duration = 3,
  distance_before_finish = 10,
  fallback_max_speed_kmh = 300,
  surface_offset_m = 0.18,
  debug_panel = true
}

local storage = ac.storage(defaults)

function Config.load()
  return {
    launch_speed_percent = tonumber(storage.launch_speed_percent) or defaults.launch_speed_percent,
    countdown_duration = tonumber(storage.countdown_duration) or defaults.countdown_duration,
    distance_before_finish = tonumber(storage.distance_before_finish) or defaults.distance_before_finish,
    fallback_max_speed_kmh = tonumber(storage.fallback_max_speed_kmh) or defaults.fallback_max_speed_kmh,
    surface_offset_m = tonumber(storage.surface_offset_m) or defaults.surface_offset_m,
    debug_panel = storage.debug_panel ~= false
  }
end

function Config.save(config)
  storage.launch_speed_percent = config.launch_speed_percent
  storage.countdown_duration = config.countdown_duration
  storage.distance_before_finish = config.distance_before_finish
  storage.fallback_max_speed_kmh = config.fallback_max_speed_kmh
  storage.surface_offset_m = config.surface_offset_m
  storage.debug_panel = config.debug_panel
end

function Config.reset(config)
  for k, v in pairs(defaults) do config[k] = v end
  Config.save(config)
end

return Config