---@diagnostic disable: undefined-global, undefined-field, lowercase-global

local appRoot = ac.dirname()

local Utils = dofile(appRoot .. '/src/utils.lua')
local Config = dofile(appRoot .. '/src/config.lua')
local Track = dofile(appRoot .. '/src/track.lua')
local Physics = dofile(appRoot .. '/src/physics.lua')
local Launch = dofile(appRoot .. '/src/launch.lua')
local UI = dofile(appRoot .. '/src/ui.lua')
local Version = dofile(appRoot .. '/src/version.lua')

local config = Config.load()
local state = Launch.createState(config)
Version.writeToState(state)

Utils.log('App loaded: ' .. Version.label)
Track.inspectAPIs(state)
Physics.inspectAPIs(state)

if ac.onSessionStart then
  ac.onSessionStart(function()
    Launch.resetForSession(state, Utils)
    if ac.setWindowOpen then ac.setWindowOpen('main', true) end
  end)
end

function script.update(dt)
  state.sim = ac.getSim()
  state.car = ac.getCar(0)
  Launch.update(state, dt, Track, Physics, Utils)
  if Launch.shouldHideWindow(state) then
    Launch.markWindowHidden(state)
    if ac.setWindowOpen then ac.setWindowOpen('main', false) end
  end
end

function windowMain(dt)
  UI.main(state, config, Launch, Track, Physics, Utils, dt or 0)
end

function windowSettings(dt)
  UI.settings(state, config, Config, Utils, dt or 0)
end

function script.destroy()
  Config.save(config)
  Utils.log('App unloaded')
end