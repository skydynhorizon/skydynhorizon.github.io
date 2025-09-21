--[[
	Advanced Resident Evil 4 Remake Camera System for R6 Models
	
	Enhanced Features:
	- Multiple camera modes (Normal, Aim, Inventory)
	- Weapon sway simulation
	- Dynamic FOV adjustments
	- Improved movement mechanics
	- Sound integration ready
	- Better performance optimization
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Enhanced Configuration
local CONFIG = {
	-- Camera settings
	CAMERA_MODES = {
		NORMAL = {
			offset = Vector3.new(1.5, 2, 5),
			fov = 70,
			sensitivity = 0.003,
		},
		AIM = {
			offset = Vector3.new(0.3, 1.8, 2),
			fov = 50,
			sensitivity = 0.002,
		},
		INVENTORY = {
			offset = Vector3.new(0, 3, 6),
			fov = 60,
			sensitivity = 0.001,
		}
	},
	
	-- Camera behavior
	CAMERA_SMOOTHING = 0.12,
	FOV_TRANSITION_SPEED = 0.08,
	VERTICAL_CLAMP = {math.rad(-75), math.rad(75)},
	
	-- Movement settings
	MOVEMENT_SPEEDS = {
		CROUCH = 3,
		WALK = 6,
		RUN = 12,
		AIM = 3,
		INVENTORY = 0,
	},
	
	-- Weapon sway
	WEAPON_SWAY = {
		ENABLED = true,
		AMPLITUDE = 0.02,
		FREQUENCY = 2,
		AIM_REDUCTION = 0.3,
	},
	
	-- Animation settings
	TWEEN_TIME = 0.25,
	EASE_STYLE = Enum.EasingStyle.Quart,
	EASE_DIRECTION = Enum.EasingDirection.Out,
	
	-- Performance
	UPDATE_RATE = 60, -- FPS target
}

-- Enhanced Camera System
local AdvancedRE4Camera = {
	-- Core state
	isActive = false,
	character = nil,
	humanoid = nil,
	rootPart = nil,
	head = nil,
	
	-- Camera state
	currentMode = "NORMAL",
	currentCameraOffset = Vector3.new(),
	targetCameraOffset = Vector3.new(),
	currentFOV = 70,
	targetFOV = 70,
	cameraAngleX = 0,
	cameraAngleY = 0,
	
	-- Movement state
	isAiming = false,
	isRunning = false,
	isCrouching = false,
	inInventory = false,
	
	-- Weapon sway
	swayTime = 0,
	swayOffset = Vector3.new(),
	
	-- Input state
	mouseDeltaX = 0,
	mouseDeltaY = 0,
	
	-- Performance tracking
	lastUpdate = 0,
	frameTime = 1/60,
	
	-- Connections
	connections = {},
	tweens = {},
}

function AdvancedRE4Camera:Initialize()
	print("Advanced RE4 Camera System: Starting initialization...")
	
	-- Wait for character
	if player.Character then
		self:SetupCharacter(player.Character)
	end
	
	-- Connect character events
	player.CharacterAdded:Connect(function(character)
		self:SetupCharacter(character)
	end)
	
	player.CharacterRemoving:Connect(function()
		self:Cleanup()
	end)
end

function AdvancedRE4Camera:SetupCharacter(character)
	self.character = character
	self.humanoid = character:WaitForChild("Humanoid")
	self.rootPart = character:WaitForChild("HumanoidRootPart")
	self.head = character:WaitForChild("Head")
	
	-- Verify R6 model
	if self.humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		warn("Advanced RE4 Camera: This system requires R6 models!")
		return
	end
	
	-- Initialize camera
	camera.CameraType = Enum.CameraType.Scriptable
	
	-- Set initial state
	self:SetCameraMode("NORMAL")
	self:SetMovementSpeed(CONFIG.MOVEMENT_SPEEDS.WALK)
	
	-- Setup systems
	self:SetupInput()
	self:StartCameraLoop()
	
	self.isActive = true
	print("Advanced RE4 Camera System: Successfully initialized for", character.Name)
end

function AdvancedRE4Camera:SetupInput()
	-- Clear existing connections
	for name, connection in pairs(self.connections) do
		if connection then
			connection:Disconnect()
		end
	end
	self.connections = {}
	
	-- Mouse movement
	self.connections.mouseMove = UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if gameProcessed or not self.isActive then return end
		
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local mode = CONFIG.CAMERA_MODES[self.currentMode]
			self.mouseDeltaX = input.Delta.X * mode.sensitivity
			self.mouseDeltaY = input.Delta.Y * mode.sensitivity
		end
	end)
	
	-- Input began
	self.connections.inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not self.isActive then return end
		
		if input.KeyCode == Enum.KeyCode.LeftShift then
			self:SetRunning(true)
		elseif input.KeyCode == Enum.KeyCode.LeftControl then
			self:SetCrouching(true)
		elseif input.KeyCode == Enum.KeyCode.Tab then
			self:ToggleInventory()
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			self:SetAiming(true)
		end
	end)
	
	-- Input ended
	self.connections.inputEnded = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed or not self.isActive then return end
		
		if input.KeyCode == Enum.KeyCode.LeftShift then
			self:SetRunning(false)
		elseif input.KeyCode == Enum.KeyCode.LeftControl then
			self:SetCrouching(false)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			self:SetAiming(false)
		end
	end)
end

function AdvancedRE4Camera:SetCameraMode(mode)
	if not CONFIG.CAMERA_MODES[mode] then
		warn("Invalid camera mode:", mode)
		return
	end
	
	self.currentMode = mode
	local modeConfig = CONFIG.CAMERA_MODES[mode]
	
	self.targetCameraOffset = modeConfig.offset
	self.targetFOV = modeConfig.fov
	
	print("Advanced RE4 Camera: Switched to", mode, "mode")
end

function AdvancedRE4Camera:SetRunning(running)
	if self.isAiming or self.isCrouching or self.inInventory then
		return
	end
	
	self.isRunning = running
	self:UpdateMovementSpeed()
end

function AdvancedRE4Camera:SetCrouching(crouching)
	if self.isRunning or self.inInventory then
		return
	end
	
	self.isCrouching = crouching
	self:UpdateMovementSpeed()
	
	-- Adjust camera height when crouching
	if crouching then
		self.targetCameraOffset = CONFIG.CAMERA_MODES[self.currentMode].offset - Vector3.new(0, 0.8, 0)
	else
		self.targetCameraOffset = CONFIG.CAMERA_MODES[self.currentMode].offset
	end
end

function AdvancedRE4Camera:SetAiming(aiming)
	if self.inInventory then
		return
	end
	
	self.isAiming = aiming
	self:SetCameraMode(aiming and "AIM" or "NORMAL")
	self:UpdateMovementSpeed()
end

function AdvancedRE4Camera:ToggleInventory()
	self.inInventory = not self.inInventory
	
	if self.inInventory then
		self:SetCameraMode("INVENTORY")
		self.isAiming = false
		self.isRunning = false
		self.isCrouching = false
	else
		self:SetCameraMode("NORMAL")
	end
	
	self:UpdateMovementSpeed()
end

function AdvancedRE4Camera:UpdateMovementSpeed()
	local targetSpeed
	
	if self.inInventory then
		targetSpeed = CONFIG.MOVEMENT_SPEEDS.INVENTORY
	elseif self.isAiming then
		targetSpeed = CONFIG.MOVEMENT_SPEEDS.AIM
	elseif self.isCrouching then
		targetSpeed = CONFIG.MOVEMENT_SPEEDS.CROUCH
	elseif self.isRunning then
		targetSpeed = CONFIG.MOVEMENT_SPEEDS.RUN
	else
		targetSpeed = CONFIG.MOVEMENT_SPEEDS.WALK
	end
	
	self:SetMovementSpeed(targetSpeed)
end

function AdvancedRE4Camera:SetMovementSpeed(speed)
	-- Clean up existing tween
	if self.tweens.speedTween then
		self.tweens.speedTween:Cancel()
	end
	
	self.tweens.speedTween = TweenService:Create(
		self.humanoid,
		TweenInfo.new(CONFIG.TWEEN_TIME, CONFIG.EASE_STYLE, CONFIG.EASE_DIRECTION),
		{WalkSpeed = speed}
	)
	self.tweens.speedTween:Play()
end

function AdvancedRE4Camera:UpdateWeaponSway(deltaTime)
	if not CONFIG.WEAPON_SWAY.ENABLED then
		self.swayOffset = Vector3.new()
		return
	end
	
	self.swayTime = self.swayTime + deltaTime
	
	local amplitude = CONFIG.WEAPON_SWAY.AMPLITUDE
	if self.isAiming then
		amplitude = amplitude * CONFIG.WEAPON_SWAY.AIM_REDUCTION
	end
	
	local frequency = CONFIG.WEAPON_SWAY.FREQUENCY
	local swayX = math.sin(self.swayTime * frequency) * amplitude
	local swayY = math.cos(self.swayTime * frequency * 0.7) * amplitude * 0.5
	
	self.swayOffset = Vector3.new(swayX, swayY, 0)
end

function AdvancedRE4Camera:StartCameraLoop()
	if self.connections.cameraLoop then
		self.connections.cameraLoop:Disconnect()
	end
	
	self.connections.cameraLoop = RunService.Heartbeat:Connect(function()
		local currentTime = tick()
		local deltaTime = currentTime - self.lastUpdate
		
		-- Limit update rate for performance
		if deltaTime >= self.frameTime then
			self:UpdateCamera(deltaTime)
			self.lastUpdate = currentTime
		end
	end)
end

function AdvancedRE4Camera:UpdateCamera(deltaTime)
	if not self.isActive or not self.rootPart then
		return
	end
	
	-- Update camera angles
	self.cameraAngleX = self.cameraAngleX - self.mouseDeltaY
	self.cameraAngleY = self.cameraAngleY - self.mouseDeltaX
	
	-- Clamp vertical angle
	self.cameraAngleX = math.clamp(self.cameraAngleX, CONFIG.VERTICAL_CLAMP[1], CONFIG.VERTICAL_CLAMP[2])
	
	-- Reset mouse delta
	self.mouseDeltaX = 0
	self.mouseDeltaY = 0
	
	-- Update weapon sway
	self:UpdateWeaponSway(deltaTime)
	
	-- Smooth camera transitions
	self.currentCameraOffset = self.currentCameraOffset:lerp(self.targetCameraOffset, CONFIG.CAMERA_SMOOTHING)
	self.currentFOV = self.currentFOV + (self.targetFOV - self.currentFOV) * CONFIG.FOV_TRANSITION_SPEED
	
	-- Calculate camera position
	local rootPosition = self.rootPart.Position
	local rotationCFrame = CFrame.Angles(self.cameraAngleX, self.cameraAngleY, 0)
	
	-- Apply weapon sway to camera offset
	local swayedOffset = self.currentCameraOffset + self.swayOffset
	local relativeOffset = rotationCFrame:VectorToWorldSpace(swayedOffset)
	local cameraPosition = rootPosition + relativeOffset
	
	-- Calculate look-at position
	local lookAtHeight = self.isCrouching and 1.2 or 1.8
	if self.isAiming then
		lookAtHeight = lookAtHeight + 0.2
	end
	local lookAtPosition = rootPosition + Vector3.new(0, lookAtHeight, 0)
	
	-- Apply camera transform
	camera.CFrame = CFrame.lookAt(cameraPosition, lookAtPosition)
	camera.FieldOfView = self.currentFOV
	
	-- Update character rotation
	self:UpdateCharacterRotation()
end

function AdvancedRE4Camera:UpdateCharacterRotation()
	if not self.humanoid or not self.rootPart then return end
	
	local moveVector = self.humanoid.MoveDirection
	
	if moveVector.Magnitude > 0.1 then
		local targetDirection
		
		if self.isAiming then
			-- Face camera direction when aiming
			local cameraDirection = camera.CFrame.LookVector
			targetDirection = Vector3.new(cameraDirection.X, 0, cameraDirection.Z).Unit
		else
			-- Face movement direction
			targetDirection = Vector3.new(moveVector.X, 0, moveVector.Z).Unit
		end
		
		local targetCFrame = CFrame.lookAt(self.rootPart.Position, self.rootPart.Position + targetDirection)
		self.rootPart.CFrame = self.rootPart.CFrame:lerp(targetCFrame, CONFIG.CAMERA_SMOOTHING)
	end
end

function AdvancedRE4Camera:Cleanup()
	self.isActive = false
	
	-- Stop all tweens
	for _, tween in pairs(self.tweens) do
		if tween then
			tween:Cancel()
		end
	end
	self.tweens = {}
	
	-- Disconnect all connections
	for _, connection in pairs(self.connections) do
		if connection then
			connection:Disconnect()
		end
	end
	self.connections = {}
	
	-- Reset camera
	camera.CameraType = Enum.CameraType.Custom
	camera.FieldOfView = 70
	
	print("Advanced RE4 Camera System: Cleaned up successfully")
end

-- Initialize the system
AdvancedRE4Camera:Initialize()

return AdvancedRE4Camera