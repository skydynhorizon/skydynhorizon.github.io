# Resident Evil 4 Remake Camera System for Roblox R6

A comprehensive LUAU script collection that recreates the Resident Evil 4 Remake camera and movement feel for R6 character models in Roblox.

## 🎮 Features

### Core Camera System (`RE4CameraSystem.luau`)
- **Over-the-shoulder third-person camera** with smooth transitions
- **Dynamic camera positioning** that adapts to player actions
- **Mouse look controls** with configurable sensitivity
- **Aiming mode** with closer camera positioning
- **Smooth interpolation** for all camera movements

### Advanced Camera System (`AdvancedRE4Camera.luau`)
- **Multiple camera modes**: Normal, Aim, and Inventory
- **Dynamic FOV adjustments** for different gameplay states
- **Weapon sway simulation** for realistic feel
- **Enhanced movement system** with walking, running, crouching
- **Performance optimizations** for smooth 60fps operation

### Weapon System Integration (`WeaponSystemExample.luau`)
- **Basic weapon handling** with multiple weapon types
- **Ammo management** and reload mechanics
- **Raycast shooting** with hit detection
- **Weapon switching** (1/2/3 keys for different weapons)

## 🚀 Quick Start

1. **Choose your camera system**:
   - Use `RE4CameraSystem.luau` for basic RE4-style camera
   - Use `AdvancedRE4Camera.luau` for full-featured experience

2. **Installation**:
   - Copy the chosen script to `StarterPlayer > StarterPlayerScripts`
   - Create a new LocalScript and paste the code
   - The system auto-initializes when players spawn

3. **Controls**:
   - **Mouse**: Look around
   - **WASD**: Move character
   - **Left Shift**: Run (hold)
   - **Right Mouse**: Aim (hold)
   - **Left Ctrl**: Crouch (Advanced system only)
   - **Tab**: Inventory mode (Advanced system only)

## 📁 Files

- `RE4CameraSystem.luau` - Core camera and movement system
- `AdvancedRE4Camera.luau` - Enhanced system with additional features
- `WeaponSystemExample.luau` - Example weapon integration
- `RE4_Camera_Documentation.md` - Detailed documentation and customization guide

## ⚙️ Customization

The camera systems include extensive configuration options:

```lua
local CONFIG = {
    CAMERA_OFFSET = Vector3.new(1.5, 2, 5), -- Camera position
    CAMERA_SENSITIVITY = 0.003,              -- Mouse sensitivity
    WALK_SPEED = 6,                          -- Movement speeds
    RUN_SPEED = 12,
    AIM_SPEED = 3,
}
```

## 🎯 R6 Model Support

This system is specifically designed for R6 character models and includes:
- R6 rig type detection and validation
- Proper HumanoidRootPart handling
- R6-specific positioning calculations

## 📖 Documentation

See `RE4_Camera_Documentation.md` for:
- Detailed installation instructions
- Configuration options
- Troubleshooting guide
- Advanced usage examples

## 🛠️ Technical Details

- **Performance**: Optimized for 60fps with efficient update loops
- **Compatibility**: R6 models only (includes automatic detection)
- **Framework**: Uses Roblox services (RunService, UserInputService, TweenService)
- **Modularity**: Clean, extensible code structure

## 🎬 Inspired By

This camera system recreates the feel of Resident Evil 4 Remake's third-person camera, adapted specifically for Roblox gameplay mechanics and R6 character constraints.