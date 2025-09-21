# RE4 Camera System - Setup and Usage Guide

## 🎯 Quick Setup (Choose One)

### Option 1: Basic RE4 Camera System
**Best for**: Simple third-person camera with RE4 feel

1. Copy `RE4CameraSystem.luau` content
2. In Roblox Studio: StarterPlayer → StarterPlayerScripts → Create LocalScript
3. Paste the code and rename script to "RE4CameraSystem"
4. Test in-game!

### Option 2: Advanced RE4 Camera System  
**Best for**: Full-featured camera with multiple modes

1. Copy `AdvancedRE4Camera.luau` content
2. In Roblox Studio: StarterPlayer → StarterPlayerScripts → Create LocalScript
3. Paste the code and rename script to "AdvancedRE4Camera"
4. Test in-game!

## 🎮 Controls Reference

### Basic System Controls
- **Mouse Movement**: Look around
- **WASD**: Move character
- **Left Shift**: Hold to run
- **Right Mouse Button**: Hold to aim

### Advanced System Controls
- **Mouse Movement**: Look around
- **WASD**: Move character  
- **Left Shift**: Hold to run
- **Left Ctrl**: Hold to crouch
- **Right Mouse Button**: Hold to aim
- **Tab**: Toggle inventory mode

### Weapon System Controls (if using example)
- **1/2/3**: Switch weapons (Pistol/Rifle/Shotgun)
- **Left Mouse**: Fire weapon
- **R**: Reload weapon

## 🔧 Installation Steps

### Step 1: Prepare Your Game
1. Open Roblox Studio
2. Create a new place or open existing
3. Ensure you're using R6 character models:
   - Game Settings → Avatar → Avatar Type → R6

### Step 2: Install Camera System
1. Navigate to StarterPlayer in Explorer
2. If StarterPlayerScripts doesn't exist, create it:
   - Right-click StarterPlayer → Insert Object → Folder
   - Rename to "StarterPlayerScripts"
3. Right-click StarterPlayerScripts → Insert Object → LocalScript
4. Delete default code and paste your chosen camera system
5. Rename the LocalScript to match the system (e.g., "RE4CameraSystem")

### Step 3: Optional - Add Weapon System
1. Create another LocalScript in StarterPlayerScripts
2. Paste `WeaponSystemExample.luau` content
3. Rename to "WeaponSystem"

### Step 4: Optional - Add Test Suite
1. Navigate to ServerScriptService
2. Right-click → Insert Object → Script (Server Script)
3. Paste `CameraTestSuite.luau` content
4. Rename to "CameraTestSuite"

## ⚙️ Customization Guide

### Camera Positioning
```lua
-- Adjust over-the-shoulder offset
CAMERA_OFFSET = Vector3.new(1.5, 2, 5) -- X=right/left, Y=up/down, Z=forward/back

-- Adjust aiming camera position  
AIM_OFFSET = Vector3.new(0.5, 1.5, 2) -- Closer and more centered
```

### Movement Speeds
```lua
WALK_SPEED = 6,    -- Normal walking
RUN_SPEED = 12,    -- Running speed
AIM_SPEED = 3,     -- Slower aiming movement
```

### Camera Behavior
```lua
CAMERA_SENSITIVITY = 0.003,  -- Mouse look sensitivity
CAMERA_SMOOTHING = 0.15,     -- Higher = smoother (0-1)
```

## 🐛 Troubleshooting

### Camera Not Working
- **Check Script Location**: Must be in StarterPlayerScripts as LocalScript
- **Check Character Type**: Must be R6, not R15
- **Check Console**: Look for error messages in Output window

### Movement Feels Wrong
- **Adjust Sensitivity**: Lower CAMERA_SENSITIVITY value
- **Adjust Smoothing**: Higher CAMERA_SMOOTHING for smoother movement
- **Check FPS**: Ensure game is running at stable framerate

### Camera Too Close/Far
- **Modify Offsets**: Adjust CAMERA_OFFSET Z value (distance)
- **Change Height**: Adjust CAMERA_OFFSET Y value
- **Side Position**: Adjust CAMERA_OFFSET X value

## 🎯 Game Integration Tips

### For Existing Games
1. Backup your current camera scripts
2. Test the RE4 system in a separate place first
3. Gradually integrate features you need
4. Customize settings to match your game's feel

### Performance Optimization
- The systems are already optimized for 60fps
- If you need better performance, increase UPDATE_RATE in advanced system
- Remove weapon sway if not needed: `WEAPON_SWAY.ENABLED = false`

### Multiplayer Considerations
- Camera system is client-side only (LocalScript)
- Weapon system example is basic - implement server validation for real weapons
- Character movement is automatically replicated by Roblox

## 📚 Advanced Usage

### Extending the System
```lua
-- Access the camera system from other scripts
local RE4Camera = require(script.Parent.RE4CameraSystem)

-- Check current state
if RE4Camera.isAiming then
    -- Do something when player is aiming
end
```

### Custom Weapon Integration
1. Study the `WeaponSystemExample.luau` structure
2. Replace the basic shooting with your weapon system
3. Keep the camera mode switching logic
4. Integrate with your damage/combat systems

### GUI Integration
- Add ammo counters using ScreenGui
- Create crosshairs that change when aiming
- Add camera mode indicators
- Implement settings menu for sensitivity

## 🎬 Final Notes

This camera system recreates the iconic RE4 over-the-shoulder perspective while working within Roblox's constraints. The modular design allows you to pick and choose features based on your game's needs.

For support or questions, refer to the documentation files or test the system with the included test suite!