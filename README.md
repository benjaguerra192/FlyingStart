# Flying Start v1.5

## 🚀 Overview

**Flying Start** is a powerful Custom Shaders Patch (CSP) Lua application for Assetto Corsa that revolutionizes practice sessions. Instead of starting from standstill, Flying Start positions your car near the start/finish line and launches it at a configurable speed percentage, allowing you to jump directly into racing at your desired pace.

Perfect for:
- 🏁 Quick practice laps without the warm-up grind
- 📈 Testing setup changes at consistent speeds
- 🎯 Focusing on specific corners and techniques
- ⚡ Maximizing track time during limited sessions
- 🔧 Gear tuning and physics testing

## ✨ Features

### Core Launch System
- **Smart positioning**: Automatically places your car before the finish line using CSP track spline data
- **Configurable speed**: Launch at 50%, 60%, 70%, 80%, 90%, or 100% of estimated maximum speed
- **Customizable countdown**: Set any countdown duration from 0-999 seconds (instant launch to extended warm-up)
- **Gear selection**: Automatically engages the correct gear based on launch speed and car setup
- **Smooth velocity application**: Uses physics APIs to apply realistic forward velocity

### Extensible Configuration
- **Text-based input fields**: Type any value directly (not limited to presets)
- **All parameters adjustable**:
  - Launch speed: 50-100% (in 5% increments for quick buttons, any value via slider)
  - Countdown duration: 0-999 seconds
  - Distance before finish: 1-200 meters
  - Fallback max speed: 50-500 km/h
  - Surface offset: 0-1000mm
- **Min/max bounds**: All ranges are easily customizable in `config.lua`
- **Persistent storage**: Settings save automatically between sessions

### Professional UI
- **Main window**: Large countdown display, speed buttons, quick countdown adjuster
- **Settings window**: Full configuration panel with detailed input fields and ranges
- **Diagnostics panel**: Real-time API availability checks and launch data
- **Changelog viewer**: Built-in version history and patch notes
- **Responsive design**: Windows scale to fit your preferences

### Dual Launch Methods
1. **Direct positioning** (preferred): Uses `physics.setCarPosition` for immediate placement
2. **Car state fallback**: Saves and loads car state for compatibility with older CSP builds

### Advanced Physics
- **Tangent-based direction**: Correctly calculates forward direction from track spline
- **Rotation correction**: Proper car orientation using matrix transformations
- **Velocity vector**: Accurate velocity applied in the correct direction (not reversed)
- **Auto-gear engagement**: Selects appropriate gear before launch

## 📋 Requirements

- **Assetto Corsa** (base game)
- **Content Manager** (for easy installation)
- **Custom Shaders Patch (CSP)** - Recent build with:
  - Lua apps enabled
  - Track spline support (`ac.trackProgressToWorldCoordinate` or `ac.trackCoordinateToWorld`)
  - Preferred: Physics APIs (`physics.setCarPosition`, `physics.setCarVelocity`)

## 🔧 Installation

### Method 1: Content Manager (Recommended)

1. Download `FlyingStart.rar` from releases
2. Drag and drop into Content Manager
3. Click "Install"
4. Enable the app in Content Manager's Lua apps section

### Method 2: Manual Installation

1. Extract the repository contents
2. Copy the `apps/lua/FlyingStart` folder to your Assetto Corsa installation:
   - **Standard**: `C:\Program Files\Steam\steamapps\common\assettocorsa\apps\lua\`
   - **Custom location**: `[Your AC folder]\apps\lua\`
3. Enable in Content Manager's Lua apps section

### Method 3: GitHub Clone

```bash
cd [Your AC folder]/apps/lua/
git clone https://github.com/benjaguerra192/FlyingStart.git
```

Then enable in Content Manager.

## 🎮 How to Use

### Basic Workflow

1. **Start a Practice/Hotlap session**
   - Must be offline single-car mode for full functionality
   - Online/multiplayer modes may have limited features

2. **Open Flying Start**
   - Find it in Content Manager's Lua apps list
   - The main window will appear with "Ready" status

3. **Configure your launch** (optional)
   - Adjust launch speed using buttons (50%-100%) or slider
   - Set countdown duration in the text field (0-999 seconds)
   - Visit Settings for more options (distance, surface offset, etc.)

4. **Press "Start Flying Lap"**
   - Car will position at the chosen location
   - Countdown begins
   - At GO: car launches at configured speed
   - You're ready to race!

5. **Advanced tweaking** (in Settings)
   - **Distance before finish**: How far from start/finish line (1-200m)
   - **Fallback Vmax**: Estimated max speed if car data unavailable (50-500 km/h)
   - **Surface offset**: Track height adjustment (0-1000mm)
   - **Diagnostics**: Check API availability and launch data

### Configuration Window

The settings window provides detailed control over all parameters:

```
Launch speed         [======●====] 70%
Countdown duration   [_5_] (0 - 999 s)
Distance before finish [_10_] (1 - 200 m)
Fallback Vmax        [======●====] 300 km/h
Surface offset       [_180_] (0 - 1000 mm)
☑ Show diagnostics
[Save] [Reset]
```

Each field includes:
- Visual range indicators
- Direct text input (type any valid value)
- Automatic bounds checking
- Real-time saving to profile

## 🛠️ Customization

### Modifying Configuration Limits

Edit `apps/lua/FlyingStart/src/config.lua` to change parameter ranges:

```lua
local defaults = {
  launch_speed_percent = 70,           -- Default: 70%
  countdown_duration = 3,              -- Default: 3 seconds
  distance_before_finish = 10,         -- Default: 10 meters
  fallback_max_speed_kmh = 300,        -- Default: 300 km/h
  surface_offset_m = 0.18,             -- Default: 0.18 meters
  
  -- Configurable ranges:
  min_countdown_duration = 0,          -- Minimum countdown
  max_countdown_duration = 999,        -- Maximum countdown
  min_distance_before_finish = 1,      -- Minimum distance from finish
  max_distance_before_finish = 200,    -- Maximum distance
  min_fallback_max_speed_kmh = 50,     -- Minimum fallback speed
  max_fallback_max_speed_kmh = 500,    -- Maximum fallback speed
  min_surface_offset_m = 0,            -- Minimum surface offset
  max_surface_offset_m = 1             -- Maximum surface offset (in meters)
}
```

### Adding New Parameters

To extend Flying Start with custom parameters:

1. Add to `config.lua` defaults
2. Update `Config.load()` and `Config.save()` functions
3. Add UI elements in `ui.lua` settings panel
4. Use the feature in `physics.lua` or `launch.lua`

Example:
```lua
-- config.lua
local defaults = {
  my_custom_param = 42,
  min_my_custom_param = 0,
  max_my_custom_param = 100
}

-- ui.lua (in settings function)
ui.text('My Custom Parameter')
local customStr = ui.inputText('##custom', tostring(config.my_custom_param), 10)
if customStr ~= tostring(config.my_custom_param) then
  local val = tonumber(customStr) or config.my_custom_param
  config.my_custom_param = Config.clamp(val, config.min_my_custom_param, config.max_my_custom_param)
end
```

## 📊 Diagnostics Panel

When enabled, shows real-time system information:

```
Diagnostics
Version check: v1.5 / 2026-06-06-direction-and-gears
✅ Reset allowed: true
✅ Set position: true
✅ Spline: true
✅ State load: true
✅ Velocity: true
✅ Gear: true
Last: 0.98765 / 210 km/h / gear 3
Spline source: trackProgressToWorldCoordinate
Vmax source: fallback
Gear source: drivetrain.ini 7000 rpm
Gear max km/h: 1:85 / 2:145 / 3:210 / 4:280
```

**Indicators:**
- ✅ Green = API available and working
- ❌ Red = API unavailable
- ⚠️ Gray = Optional feature

## 🔍 Troubleshooting

### "Car reset/state loading is not allowed"
**Problem**: Launch failed with this error message

**Solution**: 
- Flying Start requires **single-car offline modes** (Practice, Hotlap)
- Cannot use in: multiplayer, time attack, or locked server modes
- Try switching to offline Practice mode

### Car appears rotated or backwards
**Problem**: Car orientation is incorrect at launch

**Solution**:
- Ensure you're using a recent CSP build with track spline support
- Update to latest CSP version
- Check diagnostics panel (Spline: should be green)

### "Unable to compute launch position"
**Problem**: App can't find a valid track point

**Solution**:
- Some modded tracks lack spline data
- Use a standard track first to test
- Check diagnostics for available spline APIs

### Settings not saving
**Problem**: Your configuration resets after restarting

**Solution**:
- Click "Save" button in settings window
- Ensure Lua app storage is writable
- Check CSP logs for permission errors

### Velocity not applied (car stays stopped)
**Problem**: Car launches but immediately stops

**Solution**:
- This is normal in some CSP builds
- App applies velocity twice with 50ms delay (workaround)
- Update CSP for better physics API support
- Check diagnostics for "Velocity: true"

### "CSP did not provide spline world coordinates"
**Problem**: Track spline data unavailable

**Solution**:
- Modded or custom track without spline data
- Load a standard track (Monza, Spa, etc.) for testing
- Some modded tracks need CSP cache update: restart CSP

## 📝 Changelog

### Version 1.5 - Direction and Gears Build

- ✅ **Fixed car direction**: Car now correctly faces forward (tangent calculation corrected)
- ✅ **Fixed launch velocity**: Car moves forward instead of backward
- ✅ **Automatic gear selection**: Reads car physics files (drivetrain.ini, engine.ini) for proper gear choice
- ✅ **Configurable countdown**: 0-999 seconds via text input
- ✅ **100% power option**: Added 100% launch speed option
- ✅ **Enhanced UI**: Quick countdown adjuster in main window
- ✅ **Extensible config**: All parameters have configurable min/max ranges

### Version 1.4 - Position Then Countdown Build

- Start button now teleports car first
- Countdown begins only after positioning succeeds
- GO applies velocity from positioned location
- Main window closes 2 seconds after launch
- Window reopens on session restart

### Version 1.3 - Direct Position Build

- Added `physics.setCarPosition` as primary launch method
- Fallback to `saveCarStateAsync`/`loadCarState` if needed
- Reapplies velocity with CSP timeout helpers
- Diagnostics show position API availability

### Version 1.2 - No Car Physics Read Build

- Stopped reading runtime car physics fields
- Uses fallback speed only (eliminates "Preparing" freeze)
- Added detailed launch phase logging
- Pre-flight checks for reset/state loading support

### Version 1.1 - Preparing Watchdog Build

- In-app version and build ID display
- Built-in changelog viewer
- Lazy-loads car state APIs only when launching
- 6-second timeout for car state operations
- Improved error reporting

### Version 1.0 - Initial Release

- Basic CSP spline-based flying start
- Configurable launch speed and countdown
- Car state teleport with velocity injection
- Settings window with Lua app diagnostics

## 🎯 Tips & Tricks

### For Track Testing
```
Countdown: 0 seconds (instant launch)
Speed: 100% (full power)
Distance: 50m (middle of straight)
→ Perfect for high-speed braking tests
```

### For Baseline Setup
```
Countdown: 5 seconds (short warm-up)
Speed: 70% (realistic racing pace)
Distance: 10m (before finish)
→ Consistent baseline for comparing setups
```

### For Wet Weather Practice
```
Countdown: 10 seconds (extended warm-up)
Speed: 50-60% (reduced power)
Distance: 5m (tight positioning)
→ Safe speed for wet track exploration
```

### For AI Testing
```
Countdown: 3 seconds (standard)
Speed: 90-100% (race pace)
Distance: 25m (allows AI to see you)
→ Good for multi-car testing
```

## 🐛 Known Limitations

1. **Requires offline single-car mode**: Won't work in multiplayer or race servers
2. **Modded tracks**: May lack track spline data (use standard tracks)
3. **Old CSP builds**: Limited physics API support (app uses fallback methods)
4. **UI scale**: Very high or low UI scales may cause layout issues (fixable with window resizing)
5. **Network lag**: Not applicable (offline only)

## 🤝 Contributing

Want to improve Flying Start? Contributions welcome!

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/my-feature`
3. **Make your changes** to the Lua files
4. **Test thoroughly** in Assetto Corsa
5. **Commit with clear messages**: `git commit -m "Add my feature"`
6. **Push and create a Pull Request**

### Development Guidelines

- Follow existing code style (Lua conventions)
- Update `Changelog.md` with your changes
- Test on multiple cars and tracks if applicable
- Add comments for complex logic
- Keep configuration extensible (use `config.lua` pattern)

## 📄 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

Free to use, modify, and distribute with attribution.

## 🙏 Credits

**Flying Start v1.5** is developed and maintained by the Assetto Corsa modding community.

Special thanks to:
- Custom Shaders Patch team (for Lua app framework)
- Assetto Corsa community (for feedback and testing)
- Codex (original concept)

## 📞 Support

### Getting Help

1. **Check diagnostics panel** in-app (enables in settings)
2. **Read troubleshooting section** above
3. **Check CSP logs**: `%APPDATA%\Assettocorsa\CSP\CSP.log`
4. **Report issues** on GitHub with:
   - CSP build version
   - Car and track used
   - Steps to reproduce
   - Diagnostics output

### CSP Logs Location

- **Windows**: `C:\Users\[YourName]\AppData\Local\Assettocorsa\CSP\CSP.log`
- Look for lines starting with `[FlyingStart]`

## 🔗 Links

- **GitHub**: https://github.com/benjaguerra192/FlyingStart
- **Issues**: https://github.com/benjaguerra192/FlyingStart/issues
- **Releases**: https://github.com/benjaguerra192/FlyingStart/releases
- **CSP Documentation**: https://github.com/gro-ove/acc-lua-reference

## 📮 Version Info

- **Current Version**: 1.5
- **Build**: 2026-06-06-direction-and-gears
- **Last Updated**: June 6, 2026
- **Status**: Active Development

---

**Enjoy your flying starts! 🏁🚀**

Made with ❤️ for the Assetto Corsa community.