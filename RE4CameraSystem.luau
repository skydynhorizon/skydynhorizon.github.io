--[[
	Resident Evil 4 Remake Camera and Movement System for R6 Models
	
	Features:
	- Over-the-shoulder third-person camera
	- Smooth camera transitions
	- Walking/Running movement mechanics
	- Weapon aiming system with camera adjustments
	- R6 model compatibility
	
	Usage:
	1. Place this script in StarterPlayerScripts
	2. The system will automatically initialize when the player spawns
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Configuration
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

-- State variables
local RE4CameraSystem = {
	isActive = false,
	character = nil,
	humanoid = nil,
	rootPart = nil,
	
	-- Camera state
	currentCameraOffset = CONFIG.CAMERA_OFFSET,
	targetCameraOffset = CONFIG.CAMERA_OFFSET,
	cameraAngleX = 0,
	cameraAngleY = 0,
	
	-- Movement state
	isAiming = false,
	isRunning = false,
	
	-- Input state
	mouseDeltaX = 0,
	mouseDeltaY = 0,
	
	-- Connections
	connections = {},
}

function RE4CameraSystem:Initialize()
	-- Wait for character
	if player.Character then
		self:SetupCharacter(player.Character)
	end
	
	-- Connect character spawn events
	player.CharacterAdded:Connect(function(character)
		self:SetupCharacter(character)
	end)
	
	player.CharacterRemoving:Connect(function()
		self:Cleanup()
	end)
end

function RE4CameraSystem:SetupCharacter(character)
	self.character = character
	self.humanoid = character:WaitForChild("Humanoid")
	self.rootPart = character:WaitForChild("HumanoidRootPart")
	
	-- Ensure character is using R6
	if self.humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		warn("RE4 Camera System: This script is designed for R6 models only!")
		return
	end
	
	-- Set camera type
	camera.CameraType = Enum.CameraType.Scriptable
	
	-- Set initial movement speed
	self.humanoid.WalkSpeed = CONFIG.WALK_SPEED
	
	-- Setup input connections
	self:SetupInput()
	
	-- Start camera update loop
	self:StartCameraLoop()
	
	self.isActive = true
	print("RE4 Camera System: Initialized for R6 character")
end

function RE4CameraSystem:SetupInput()
	-- Mouse input for camera rotation
	self.connections.mouseMove = UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self.mouseDeltaX = input.Delta.X
			self.mouseDeltaY = input.Delta.Y
		end
	end)
	
	-- Keyboard input
	self.connections.inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.LeftShift then
			self:SetRunning(true)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			self:SetAiming(true)
		end
	end)
	
	self.connections.inputEnded = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.LeftShift then
			self:SetRunning(false)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			self:SetAiming(false)
		end
	end)
end

function RE4CameraSystem:SetRunning(running)
	self.isRunning = running
	
	if self.isAiming then
		return -- Can't run while aiming
	end
	
	local targetSpeed = running and CONFIG.RUN_SPEED or CONFIG.WALK_SPEED
	
	-- Smooth speed transition
	local speedTween = TweenService:Create(
		self.humanoid,
		TweenInfo.new(CONFIG.TWEEN_TIME, CONFIG.EASE_STYLE, CONFIG.EASE_DIRECTION),
		{WalkSpeed = targetSpeed}
	)
	speedTween:Play()
end

function RE4CameraSystem:SetAiming(aiming)
	self.isAiming = aiming
	
	-- Update camera offset
	self.targetCameraOffset = aiming and CONFIG.AIM_OFFSET or CONFIG.CAMERA_OFFSET
	
	-- Update movement speed
	local targetSpeed = aiming and CONFIG.AIM_SPEED or (self.isRunning and CONFIG.RUN_SPEED or CONFIG.WALK_SPEED)
	
	local speedTween = TweenService:Create(
		self.humanoid,
		TweenInfo.new(CONFIG.TWEEN_TIME, CONFIG.EASE_STYLE, CONFIG.EASE_DIRECTION),
		{WalkSpeed = targetSpeed}
	)
	speedTween:Play()
	
	print("RE4 Camera System: " .. (aiming and "Aiming" or "Normal") .. " mode")
end

function RE4CameraSystem:StartCameraLoop()
	if self.connections.cameraLoop then
		self.connections.cameraLoop:Disconnect()
	end
	
	self.connections.cameraLoop = RunService.Heartbeat:Connect(function()
		self:UpdateCamera()
	end)
end

function RE4CameraSystem:UpdateCamera()
	if not self.isActive or not self.rootPart then
		return
	end
	
	-- Update camera angles based on mouse input
	self.cameraAngleX = self.cameraAngleX - self.mouseDeltaY * CONFIG.CAMERA_SENSITIVITY
	self.cameraAngleY = self.cameraAngleY - self.mouseDeltaX * CONFIG.CAMERA_SENSITIVITY
	
	-- Clamp vertical angle
	self.cameraAngleX = math.clamp(self.cameraAngleX, math.rad(-80), math.rad(80))
	
	-- Reset mouse delta
	self.mouseDeltaX = 0
	self.mouseDeltaY = 0
	
	-- Smooth camera offset transition
	self.currentCameraOffset = self.currentCameraOffset:lerp(self.targetCameraOffset, CONFIG.CAMERA_SMOOTHING)
	
	-- Calculate camera position
	local rootPosition = self.rootPart.Position
	local rootCFrame = self.rootPart.CFrame
	
	-- Create rotation matrix for camera angles
	local rotationCFrame = CFrame.Angles(self.cameraAngleX, self.cameraAngleY, 0)
	
	-- Calculate camera position relative to character
	local relativeOffset = rotationCFrame:VectorToWorldSpace(self.currentCameraOffset)
	local cameraPosition = rootPosition + relativeOffset
	
	-- Calculate look-at position (slightly above character center)
	local lookAtOffset = Vector3.new(0, 1.5, 0)
	if self.isAiming then
		lookAtOffset = Vector3.new(0, 2, 0) -- Look slightly higher when aiming
	end
	local lookAtPosition = rootPosition + lookAtOffset
	
	-- Apply camera position and rotation
	camera.CFrame = CFrame.lookAt(cameraPosition, lookAtPosition)
	
	-- Update character rotation to face camera direction (only Y-axis)
	if self.humanoid.MoveDirection.Magnitude > 0 then
		local moveVector = self.humanoid.MoveDirection
		local targetLookDirection = Vector3.new(moveVector.X, 0, moveVector.Z).Unit
		
		if self.isAiming then
			-- When aiming, face the camera direction
			local cameraDirection = camera.CFrame.LookVector
			targetLookDirection = Vector3.new(cameraDirection.X, 0, cameraDirection.Z).Unit
		end
		
		local targetCFrame = CFrame.lookAt(rootPosition, rootPosition + targetLookDirection)
		self.rootPart.CFrame = self.rootPart.CFrame:lerp(targetCFrame, CONFIG.CAMERA_SMOOTHING)
	end
end

function RE4CameraSystem:Cleanup()
	self.isActive = false
	
	-- Disconnect all connections
	for _, connection in pairs(self.connections) do
		if connection then
			connection:Disconnect()
		end
	end
	self.connections = {}
	
	-- Reset camera
	camera.CameraType = Enum.CameraType.Custom
	
	print("RE4 Camera System: Cleaned up")
end

-- Auto-initialize
RE4CameraSystem:Initialize()

return RE4CameraSystem