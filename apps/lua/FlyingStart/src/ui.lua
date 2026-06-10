local UI = {}

local green = rgbm(0.1, 0.95, 0.45, 1)
local red = rgbm(1, 0.18, 0.14, 1)
local muted = rgbm(0.65, 0.72, 0.78, 1)

local speedChoices = {50, 60, 70, 80, 90, 100}
local colorChoices = {
  { name = 'Cyan', color = rgbm(0.05, 0.78, 1.0, 1), button = rgbm(0.02, 0.46, 0.62, 0.95), hover = rgbm(0.04, 0.62, 0.82, 1) },
  { name = 'Lime', color = rgbm(0.25, 1.0, 0.38, 1), button = rgbm(0.10, 0.55, 0.22, 0.95), hover = rgbm(0.14, 0.72, 0.30, 1) },
  { name = 'Orange', color = rgbm(1.0, 0.48, 0.12, 1), button = rgbm(0.72, 0.30, 0.08, 0.95), hover = rgbm(0.92, 0.42, 0.10, 1) },
  { name = 'Violet', color = rgbm(0.70, 0.44, 1.0, 1), button = rgbm(0.42, 0.22, 0.72, 0.95), hover = rgbm(0.56, 0.32, 0.92, 1) },
  { name = 'Red', color = rgbm(1.0, 0.22, 0.24, 1), button = rgbm(0.70, 0.10, 0.12, 0.95), hover = rgbm(0.90, 0.16, 0.18, 1) }
}

local function theme(config)
  return colorChoices[math.floor(tonumber(config.accent_color) or 1)] or colorChoices[1]
end

local function pill(text, color)
  ui.pushStyleColor(ui.StyleColor.Text, color)
  ui.text(text)
  ui.popStyleColor()
end

local function sectionTitle(text, color)
  ui.dummy(vec2(1, 6))
  ui.pushStyleColor(ui.StyleColor.Text, color)
  ui.text(text)
  ui.popStyleColor()
end

local function themedButton(label, size, colors, disabled)
  ui.pushStyleColor(ui.StyleColor.Button, disabled and rgbm(0.18, 0.22, 0.25, 0.95) or colors.button)
  ui.pushStyleColor(ui.StyleColor.ButtonHovered, disabled and rgbm(0.18, 0.22, 0.25, 0.95) or colors.hover)
  ui.pushStyleColor(ui.StyleColor.ButtonActive, disabled and rgbm(0.18, 0.22, 0.25, 0.95) or colors.button)
  local clicked = ui.button(label, size)
  ui.popStyleColor(3)
  return clicked
end

local function drawHeader(state, colors)
  ui.pushFont(ui.Font.Title)
  ui.text('Flying Start')
  ui.popFont()
  ui.sameLine(0, 14)
  pill(state.mode or 'IDLE', state.mode == 'ERROR' and red or colors.color)
  ui.pushFont(ui.Font.Small)
  ui.text('Loaded: ' .. tostring(state.versionLabel or 'unknown build'))
  ui.popFont()
end

local function drawMainButton(state, Launch, Track, Physics, Utils, colors)
  local disabled = state.mode == Launch.State.COUNTDOWN or state.mode == Launch.State.PREPARING or state.mode == Launch.State.POSITIONING or state.mode == Launch.State.LAUNCHING
  local label = disabled and 'Working...' or 'Start Flying Lap'
  if themedButton(label, vec2(-0.1, 46), colors, disabled) then
    if not disabled then Launch.start(state, Track, Physics, Utils) end
  end
end

local function drawCountdown(state, Utils)
  local text = state.message or 'Ready'
  local t = (state.timer or 0) % 1
  local scale = 1 + (1 - Utils.easeOutCubic(t)) * 0.28
  local size = ui.measureText(text) * scale
  local w = ui.windowSize().x
  ui.dummy(vec2(1, 4))
  ui.setCursorX(math.max(0, (w - size.x) / 2))
  ui.pushFont(ui.Font.Huge)
  ui.pushStyleColor(ui.StyleColor.Text, state.mode == 'ERROR' and red or (state.mode == 'SUCCESS' and green or rgbm(1, 1, 1, 1)))
  ui.text(text)
  ui.popStyleColor()
  ui.popFont()
end

local function drawDiagnostics(state, config, Track, Physics, Utils, colors)
  if not config.debug_panel then return end
  ui.separator()
  sectionTitle('Diagnostics', colors.color)
  ui.pushFont(ui.Font.Small)
  ui.text('Version check: ' .. tostring(state.versionLabel or 'unknown build'))
  local api = state.api or {}
  pill('Reset allowed: ' .. tostring(api.isCarResetAllowed), api.isCarResetAllowed and green or red)
  ui.sameLine(0, 14)
  pill('Set position: ' .. tostring(api.physicsSetCarPosition), api.physicsSetCarPosition and green or red)
  ui.sameLine(0, 14)
  pill('Spline: ' .. tostring(api.trackSplineAvailable), api.trackSplineAvailable and green or red)
  ui.sameLine(0, 14)
  pill('State load: ' .. tostring(api.loadCarState), api.loadCarState and green or red)
  ui.sameLine(0, 14)
  pill('Velocity: ' .. tostring(api.physicsSetCarVelocity), api.physicsSetCarVelocity and green or muted)
  ui.sameLine(0, 14)
  pill('Gear: ' .. tostring(api.physicsEngageGear), api.physicsEngageGear and green or muted)
  if state.lastLaunch then
    ui.text(string.format('Last: %.5f / %s / gear %d', state.lastLaunch.progress or 0, Utils.formatKmh(state.lastLaunch.speedKmh), state.lastLaunch.gear or 0))
    ui.text('Spline source: ' .. tostring(state.lastLaunch.source))
    ui.text('Vmax source: ' .. tostring(state.lastLaunch.vmaxSource))
    ui.text('Gear source: ' .. tostring(state.lastLaunch.gearSource))
    if state.lastLaunch.gearTable then
      local ranges = {}
      for _, entry in ipairs(state.lastLaunch.gearTable) do
        ranges[#ranges + 1] = string.format('%d:%.0f', entry.gear, entry.maxKmh)
      end
      ui.textWrapped('Gear max km/h: ' .. table.concat(ranges, ' / '))
    end
  end
  if state.error and state.error ~= '' then
    ui.textWrapped('Error: ' .. state.error)
  end
  ui.popFont()
end

local function drawChangelog(state)
  ui.separator()
  if ui.button(state.showChangelog and 'Hide changelog' or 'Show changelog', vec2(-0.1, 28)) then
    state.showChangelog = not state.showChangelog
  end
  if not state.showChangelog then return end

  ui.pushFont(ui.Font.Small)
  for _, line in ipairs(state.changelog or {}) do
    if line == '' then
      ui.dummy(vec2(1, 4))
    else
      ui.textWrapped(line)
    end
  end
  ui.popFont()
end

function UI.main(state, config, Config, Launch, Track, Physics, Utils, dt)
  state.config = config
  local colors = theme(config)
  ui.setNextWindowSizeConstraints(vec2(350, 330), vec2(460, 650))
  ui.beginOutline()
  drawHeader(state, colors)
  ui.separator()
  drawCountdown(state, Utils)
  drawMainButton(state, Launch, Track, Physics, Utils, colors)

  if state.mode ~= Launch.State.IDLE then
    if ui.button('Cancel', vec2(-0.1, 30)) then Launch.cancel(state, Utils) end
  end

  sectionTitle('Launch speed', colors.color)
  for i, v in ipairs(speedChoices) do
    if i > 1 then ui.sameLine(0, 6) end
    local active = config.launch_speed_percent == v
    if active then ui.pushStyleColor(ui.StyleColor.Button, colors.button) end
    if ui.button(tostring(v) .. '%', vec2(54, 28)) then config.launch_speed_percent = v end
    if active then ui.popStyleColor() end
  end

  sectionTitle('Exit mode', colors.color)
  local coastLabel = config.full_throttle_exit and 'Coast assist' or 'Coast assist ON'
  local maxLabel = config.full_throttle_exit and 'Max throttle ON' or 'Max throttle'
  local coastActive = not config.full_throttle_exit
  local maxActive = config.full_throttle_exit
  if coastActive then ui.pushStyleColor(ui.StyleColor.Button, colors.button) end
  if ui.button(coastLabel, vec2(150, 30)) then config.full_throttle_exit = false end
  if coastActive then ui.popStyleColor() end
  ui.sameLine(0, 8)
  if maxActive then ui.pushStyleColor(ui.StyleColor.Button, colors.button) end
  if ui.button(maxLabel, vec2(-0.1, 30)) then config.full_throttle_exit = true end
  if maxActive then ui.popStyleColor() end
  ui.pushFont(ui.Font.Small)
  ui.textWrapped(config.full_throttle_exit and 'Launch keeps 100% throttle briefly after GO.' or 'Launch uses mild throttle assist after GO.')
  ui.popFont()

  sectionTitle('Countdown (seconds)', colors.color)
  local countdownStr = ui.inputText('##countdown_main', tostring(math.floor(config.countdown_duration)), 6)
  if countdownStr ~= tostring(math.floor(config.countdown_duration)) then
    local val = tonumber(countdownStr) or config.countdown_duration
    config.countdown_duration = Config.clamp(val, config.min_countdown_duration, config.max_countdown_duration)
  end

  drawDiagnostics(state, config, Track, Physics, Utils, colors)
  drawChangelog(state)
  ui.endOutline(rgbm(0, 0, 0, 0.92), 1)
end

function UI.settings(state, config, Config, Utils, dt)
  local colors = theme(config)
  ui.setNextWindowSizeConstraints(vec2(380, 340), vec2(520, 760))
  ui.beginOutline()
  ui.pushFont(ui.Font.Title)
  ui.text('Flying Start Settings')
  ui.popFont()
  ui.separator()

  sectionTitle('Launch', colors.color)
  local speed, speedChanged = ui.slider('Launch speed', config.launch_speed_percent, 50, 100, '%.0f%%')
  if speedChanged then config.launch_speed_percent = math.floor(speed / 5 + 0.5) * 5 end

  if ui.checkbox('Max throttle exit', config.full_throttle_exit) then config.full_throttle_exit = not config.full_throttle_exit end
  ui.pushFont(ui.Font.Small)
  ui.textWrapped('When enabled, Flying Start holds 100% throttle briefly after GO instead of the default mild assist.')
  ui.popFont()

  ui.text('Countdown duration (seconds)')
  local countdownStr = ui.inputText('##countdown', tostring(math.floor(config.countdown_duration)), 10)
  if countdownStr ~= tostring(math.floor(config.countdown_duration)) then
    local val = tonumber(countdownStr) or config.countdown_duration
    config.countdown_duration = Config.clamp(val, config.min_countdown_duration, config.max_countdown_duration)
  end
  ui.sameLine(0, 8)
  ui.text(string.format('(0 - 999 s)'))

  sectionTitle('Position', colors.color)
  ui.text('Distance before finish (meters)')
  local distanceStr = ui.inputText('##distance', tostring(math.floor(config.distance_before_finish)), 10)
  if distanceStr ~= tostring(math.floor(config.distance_before_finish)) then
    local val = tonumber(distanceStr) or config.distance_before_finish
    config.distance_before_finish = Config.clamp(val, config.min_distance_before_finish, config.max_distance_before_finish)
  end
  ui.sameLine(0, 8)
  ui.text(string.format('(%.0f - %.0f m)', config.min_distance_before_finish, config.max_distance_before_finish))

  local fallback, fallbackChanged = ui.slider('Fallback Vmax', config.fallback_max_speed_kmh, config.min_fallback_max_speed_kmh, config.max_fallback_max_speed_kmh, '%.0f km/h')
  if fallbackChanged then config.fallback_max_speed_kmh = math.floor(fallback + 0.5) end

  ui.text('Surface offset (millimeters)')
  local offsetStr = ui.inputText('##offset', tostring(math.floor(config.surface_offset_m * 1000)), 10)
  if offsetStr ~= tostring(math.floor(config.surface_offset_m * 1000)) then
    local val = (tonumber(offsetStr) or (config.surface_offset_m * 1000)) / 1000
    config.surface_offset_m = Config.clamp(val, config.min_surface_offset_m, config.max_surface_offset_m)
  end
  ui.sameLine(0, 8)
  ui.text(string.format('(%.0f - %.0f mm)', config.min_surface_offset_m * 1000, config.max_surface_offset_m * 1000))

  sectionTitle('Theme', colors.color)
  for i, choice in ipairs(colorChoices) do
    if i > 1 then ui.sameLine(0, 6) end
    local active = config.accent_color == i
    if active then ui.pushStyleColor(ui.StyleColor.Button, choice.button) end
    if ui.button(choice.name, vec2(72, 28)) then config.accent_color = i end
    if active then ui.popStyleColor() end
  end

  sectionTitle('Tools', colors.color)
  if ui.checkbox('Show diagnostics', config.debug_panel) then config.debug_panel = not config.debug_panel end

  ui.separator()
  if themedButton('Save', vec2(120, 32), colors, false) then Config.save(config) end
  ui.sameLine(0, 8)
  if ui.button('Reset', vec2(120, 32)) then Config.reset(config) end

  ui.endOutline(rgbm(0, 0, 0, 0.72), 1)
end

return UI
