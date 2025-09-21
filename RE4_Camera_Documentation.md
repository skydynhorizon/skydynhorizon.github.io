# Resident Evil 4 Remake Camera System for Roblox R6 Models

This LUAU script provides a Resident Evil 4 Remake-style third-person camera and movement system specifically designed for R6 character models in Roblox.

## Features

### Camera System
- **Over-the-shoulder perspective**: Classic RE4-style camera positioning
- **Smooth camera transitions**: Fluid movement between normal and aiming modes
- **Mouse sensitivity controls**: Responsive camera rotation with configurable sensitivity
- **Vertical angle clamping**: Prevents camera from rotating too far up or down

### Movement System
- **Walking mode**: Standard movement speed for exploration
- **Running mode**: Faster movement with Left Shift key
- **Aiming mode**: Slower, more precise movement when aiming
- **Character rotation**: Character faces movement direction or camera direction when aiming

### Controls
- **Mouse**: Look around and rotate camera
- **WASD**: Move character
- **Left Shift**: Hold to run (when not aiming)
- **Right Mouse Button**: Hold to aim

## Installation

1. **Copy the script**: Copy the contents of `RE4CameraSystem.luau`
2. **Place in StarterPlayerScripts**: 
   - In Roblox Studio, navigate to StarterPlayer > StarterPlayerScripts
   - Create a new LocalScript
   - Paste the camera system code
   - Rename the script to "RE4CameraSystem"

3. **Test in-game**: The system will automatically initialize when a player spawns

## Configuration

The script includes a CONFIG table at the top that allows you to customize various aspects:

```lua
local CONFIG = {
    -- Camera settings
    CAMERA_OFFSET = Vector3.new(1.5, 2, 5), -- Over-the-shoulder offset
    AIM_OFFSET = Vector3.new(0.5, 1.5, 2), -- Aiming camera offset
    CAMERA_SENSITIVITY = 0.003,
    CAMERA_SMOOTHING = 0.15,
    
    -- Movement settings
    WALK_SPEED = 6,
    RUN_SPEED = 12,
    AIM_SPEED = 3,
    
    -- Animation settings
    TWEEN_TIME = 0.3,
    EASE_STYLE = Enum.EasingStyle.Quart,
    EASE_DIRECTION = Enum.EasingDirection.Out,
}
```

### Customization Options

- **CAMERA_OFFSET**: Adjust the over-the-shoulder camera position
- **AIM_OFFSET**: Change the camera position when aiming
- **CAMERA_SENSITIVITY**: Control mouse look sensitivity
- **CAMERA_SMOOTHING**: Adjust camera movement smoothness (0-1)
- **WALK_SPEED/RUN_SPEED/AIM_SPEED**: Set movement speeds for different modes
- **TWEEN_TIME**: Duration of smooth transitions between states

## R6 Model Compatibility

This script is specifically designed for R6 character models. It includes:
- R6 rig type detection
- Proper HumanoidRootPart handling
- R6-specific positioning calculations

## Technical Details

### Camera Behavior
1. **Normal Mode**: Camera positioned over the right shoulder
2. **Aiming Mode**: Camera moves closer and centers slightly
3. **Smooth Transitions**: All camera movements use interpolation for smooth gameplay

### Movement Behavior
1. **Character Facing**: Character faces movement direction during normal movement
2. **Aiming Alignment**: When aiming, character aligns with camera direction
3. **Speed Transitions**: Movement speed changes smoothly between modes

### Performance
- Uses RunService.Heartbeat for smooth 60fps camera updates
- Efficient CFrame calculations
- Proper cleanup when character is removed

## Troubleshooting

### Common Issues

1. **Script not working**: Ensure it's placed in StarterPlayerScripts as a LocalScript
2. **R15 compatibility**: This script is designed only for R6 models
3. **Camera not moving**: Check that mouse lock is not enabled in your game
4. **Jerky movement**: Adjust CAMERA_SMOOTHING value (higher = smoother but slower)

### Console Messages
The script provides helpful console output:
- "RE4 Camera System: Initialized for R6 character" - Successful setup
- "RE4 Camera System: This script is designed for R6 models only!" - R15 model detected
- "RE4 Camera System: Aiming/Normal mode" - State change confirmations

## Advanced Usage

### Extending the System
The camera system is modular and can be extended with additional features:
- Weapon handling
- Different camera modes
- Custom animations
- Sound effects integration

### Integration with Other Scripts
The system returns a module table that can be accessed by other scripts if needed:
```lua
local RE4Camera = require(script.RE4CameraSystem)
-- Access system state or methods as needed
```

## Credits

Inspired by the camera system from Resident Evil 4 Remake, adapted for Roblox R6 character models.