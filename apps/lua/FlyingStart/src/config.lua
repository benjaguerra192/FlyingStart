local Config = {}

local defaults = {
  launch_speed_percent = 70,
  countdown_duration = 3,
  distance_before_finish = 10,
  fallback_max_speed_kmh = 300,
  surface_offset_m = 0.18,
  full_throttle_exit = false,
  accent_color = 1,
  debug_panel = true,
  min_countdown_duration = 0,
  max_countdown_duration = 999,
  min_distance_before_finish = 1,
  max_distance_before_finish = 200,
  min_fallback_max_speed_kmh = 50,
  max_fallback_max_speed_kmh = 500,
  min_surface_offset_m = 0,
  max_surface_offset_m = 1
}

local storage = ac.storage(defaults)

function Config.load()
  return {
    launch_speed_percent = tonumber(storage.launch_speed_percent) or defaults.launch_speed_percent,
    countdown_duration = tonumber(storage.countdown_duration) or defaults.countdown_duration,
    distance_before_finish = tonumber(storage.distance_before_finish) or defaults.distance_before_finish,
    fallback_max_speed_kmh = tonumber(storage.fallback_max_speed_kmh) or defaults.fallback_max_speed_kmh,
    surface_offset_m = tonumber(storage.surface_offset_m) or defaults.surface_offset_m,
    full_throttle_exit = storage.full_throttle_exit == true,
    accent_color = Config.clamp(tonumber(storage.accent_color) or defaults.accent_color, 1, 5),
    debug_panel = storage.debug_panel ~= false,
    min_countdown_duration = defaults.min_countdown_duration,
    max_countdown_duration = defaults.max_countdown_duration,
    min_distance_before_finish = defaults.min_distance_before_finish,
    max_distance_before_finish = defaults.max_distance_before_finish,
    min_fallback_max_speed_kmh = defaults.min_fallback_max_speed_kmh,
    max_fallback_max_speed_kmh = defaults.max_fallback_max_speed_kmh,
    min_surface_offset_m = defaults.min_surface_offset_m,
    max_surface_offset_m = defaults.max_surface_offset_m
  }
end

function Config.save(config)
  storage.launch_speed_percent = config.launch_speed_percent
  storage.countdown_duration = config.countdown_duration
  storage.distance_before_finish = config.distance_before_finish
  storage.fallback_max_speed_kmh = config.fallback_max_speed_kmh
  storage.surface_offset_m = config.surface_offset_m
  storage.full_throttle_exit = config.full_throttle_exit
  storage.accent_color = config.accent_color
  storage.debug_panel = config.debug_panel
end

function Config.reset(config)
  for k, v in pairs(defaults) do config[k] = v end
  Config.save(config)
end

function Config.clamp(value, min_val, max_val)
  if value < min_val then return min_val end
  if value > max_val then return max_val end
  return value
end

return Config
