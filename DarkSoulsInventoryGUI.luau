--[[
	Dark Souls Inventory GUI System
	
	Features:
	- Dark Souls aesthetic and color scheme
	- Proper equipment label and slot alignment
	- Weapon slots positioned on RIGHT side of hotbar
	- Real-time survival stats integration (health, hunger, thirst, stamina)
	- Integration with existing camera and weapon systems
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Dark Souls Color Scheme
local COLORS = {
	BACKGROUND = Color3.fromRGB(20, 20, 25),
	FRAME_BORDER = Color3.fromRGB(80, 60, 40),
	TEXT_PRIMARY = Color3.fromRGB(220, 200, 150),
	TEXT_SECONDARY = Color3.fromRGB(180, 160, 120),
	SLOT_EMPTY = Color3.fromRGB(40, 35, 30),
	SLOT_FILLED = Color3.fromRGB(60, 50, 40),
	HOTBAR_BG = Color3.fromRGB(15, 15, 20),
	STAT_HEALTH = Color3.fromRGB(180, 40, 40),
	STAT_STAMINA = Color3.fromRGB(40, 120, 40),
	STAT_HUNGER = Color3.fromRGB(160, 80, 20),
	STAT_THIRST = Color3.fromRGB(40, 100, 160)
}

-- GUI Configuration
local CONFIG = {
	INVENTORY_SIZE = UDim2.new(0, 800, 0, 600),
	HOTBAR_SIZE = UDim2.new(0, 600, 0, 80),
	SLOT_SIZE = UDim2.new(0, 50, 0, 50),
	WEAPON_SLOT_SIZE = UDim2.new(0, 60, 0, 60),
	ANIMATION_TIME = 0.3,
	STAT_UPDATE_RATE = 0.1
}

-- Dark Souls Inventory GUI Class
local DarkSoulsInventoryGUI = {
	isActive = false,
	isInventoryOpen = false,
	
	-- GUI Elements
	screenGui = nil,
	inventoryFrame = nil,
	hotbarFrame = nil,
	weaponFrame = nil,
	statsFrame = nil,
	equipmentFrame = nil,
	
	-- Survival Stats
	currentStats = {
		health = 100,
		maxHealth = 100,
		hunger = 100,
		maxHunger = 100,
		thirst = 100,
		maxThirst = 100,
		stamina = 100,
		maxStamina = 100
	},
	
	-- Equipment Slots
	equipmentSlots = {},
	weaponSlots = {},
	
	-- Connections
	connections = {},
	
	-- Integration with other systems
	cameraSystem = nil,
	weaponSystem = nil
}

function DarkSoulsInventoryGUI:Initialize()
	print("Dark Souls Inventory GUI: Initializing...")
	
	-- Create main ScreenGui
	self:CreateScreenGui()
	
	-- Create inventory components
	self:CreateHotbar()
	self:CreateInventoryPanel()
	self:CreateStatsPanel()
	
	-- Setup input handling
	self:SetupInput()
	
	-- Start stat updates
	self:StartStatUpdates()
	
	self.isActive = true
	print("Dark Souls Inventory GUI: Initialized successfully")
end

function DarkSoulsInventoryGUI:CreateScreenGui()
	-- Remove existing GUI if present
	local existingGui = playerGui:FindFirstChild("DarkSoulsInventoryGUI")
	if existingGui then
		existingGui:Destroy()
	end
	
	-- Create new ScreenGui
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "DarkSoulsInventoryGUI"
	self.screenGui.ResetOnSpawn = false
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.Parent = playerGui
end

function DarkSoulsInventoryGUI:CreateHotbar()
	-- Main hotbar frame
	self.hotbarFrame = Instance.new("Frame")
	self.hotbarFrame.Name = "HotbarFrame"
	self.hotbarFrame.Size = CONFIG.HOTBAR_SIZE
	self.hotbarFrame.Position = UDim2.new(0.5, -300, 1, -100)
	self.hotbarFrame.BackgroundColor3 = COLORS.HOTBAR_BG
	self.hotbarFrame.BorderColor3 = COLORS.FRAME_BORDER
	self.hotbarFrame.BorderSizePixel = 2
	self.hotbarFrame.Parent = self.screenGui
	
	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = self.hotbarFrame
	
	-- Create main inventory slots (left side)
	self:CreateInventorySlots()
	
	-- Create weapon slots (RIGHT side) - This addresses the problem statement
	self:CreateWeaponSlots()
	
	-- Add hotbar labels
	self:CreateHotbarLabels()
end

function DarkSoulsInventoryGUI:CreateInventorySlots()
	-- Create inventory slots on the LEFT side of hotbar
	for i = 1, 8 do
		local slot = Instance.new("Frame")
		slot.Name = "InventorySlot" .. i
		slot.Size = CONFIG.SLOT_SIZE
		slot.Position = UDim2.new(0, 10 + (i-1) * 55, 0.5, -25)
		slot.BackgroundColor3 = COLORS.SLOT_EMPTY
		slot.BorderColor3 = COLORS.FRAME_BORDER
		slot.BorderSizePixel = 1
		slot.Parent = self.hotbarFrame
		
		-- Add corner rounding
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = slot
		
		-- Add slot number label
		local label = Instance.new("TextLabel")
		label.Name = "SlotNumber"
		label.Size = UDim2.new(0, 15, 0, 15)
		label.Position = UDim2.new(0, -8, 0, -8)
		label.BackgroundColor3 = COLORS.BACKGROUND
		label.BorderColor3 = COLORS.FRAME_BORDER
		label.BorderSizePixel = 1
		label.Text = tostring(i)
		label.TextColor3 = COLORS.TEXT_SECONDARY
		label.TextScaled = true
		label.Font = Enum.Font.SourceSansBold
		label.Parent = slot
		
		-- Add corner to label
		local labelCorner = Instance.new("UICorner")
		labelCorner.CornerRadius = UDim.new(0, 2)
		labelCorner.Parent = label
	end
end

function DarkSoulsInventoryGUI:CreateWeaponSlots()
	-- Create weapons frame on the RIGHT side of hotbar (addresses problem statement)
	self.weaponFrame = Instance.new("Frame")
	self.weaponFrame.Name = "WeaponFrame"
	self.weaponFrame.Size = UDim2.new(0, 140, 1, 0)
	self.weaponFrame.Position = UDim2.new(1, -150, 0, 0) -- RIGHT side positioning
	self.weaponFrame.BackgroundTransparency = 1
	self.weaponFrame.Parent = self.hotbarFrame
	
	-- Create E and R weapon slots on RIGHT side
	local weaponKeys = {"E", "R"}
	for i, key in ipairs(weaponKeys) do
		local slot = Instance.new("Frame")
		slot.Name = "WeaponSlot" .. key
		slot.Size = CONFIG.WEAPON_SLOT_SIZE
		slot.Position = UDim2.new(0, (i-1) * 65, 0.5, -30)
		slot.BackgroundColor3 = COLORS.SLOT_EMPTY
		slot.BorderColor3 = COLORS.FRAME_BORDER
		slot.BorderSizePixel = 2
		slot.Parent = self.weaponFrame
		
		-- Add corner rounding
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = slot
		
		-- Add weapon key label
		local label = Instance.new("TextLabel")
		label.Name = "WeaponKey"
		label.Size = UDim2.new(0, 20, 0, 20)
		label.Position = UDim2.new(0, -10, 0, -10)
		label.BackgroundColor3 = COLORS.BACKGROUND
		label.BorderColor3 = COLORS.FRAME_BORDER
		label.BorderSizePixel = 1
		label.Text = key
		label.TextColor3 = COLORS.TEXT_PRIMARY
		label.TextScaled = true
		label.Font = Enum.Font.SourceSansBold
		label.Parent = slot
		
		-- Add corner to label
		local labelCorner = Instance.new("UICorner")
		labelCorner.CornerRadius = UDim.new(0, 3)
		labelCorner.Parent = label
		
		-- Store weapon slot reference
		self.weaponSlots[key] = slot
	end
end

function DarkSoulsInventoryGUI:CreateHotbarLabels()
	-- Equipment label (properly aligned)
	local equipLabel = Instance.new("TextLabel")
	equipLabel.Name = "EquipmentLabel"
	equipLabel.Size = UDim2.new(0, 150, 0, 20)
	equipLabel.Position = UDim2.new(0, 10, 0, -25)
	equipLabel.BackgroundTransparency = 1
	equipLabel.Text = "EQUIPMENT"
	equipLabel.TextColor3 = COLORS.TEXT_PRIMARY
	equipLabel.TextScaled = true
	equipLabel.Font = Enum.Font.SourceSansBold
	equipLabel.TextXAlignment = Enum.TextXAlignment.Left
	equipLabel.Parent = self.hotbarFrame
	
	-- Weapons label (properly aligned on RIGHT side)
	local weaponLabel = Instance.new("TextLabel")
	weaponLabel.Name = "WeaponsLabel"
	weaponLabel.Size = UDim2.new(0, 100, 0, 20)
	weaponLabel.Position = UDim2.new(1, -150, 0, -25)
	weaponLabel.BackgroundTransparency = 1
	weaponLabel.Text = "WEAPONS"
	weaponLabel.TextColor3 = COLORS.TEXT_PRIMARY
	weaponLabel.TextScaled = true
	weaponLabel.Font = Enum.Font.SourceSansBold
	weaponLabel.TextXAlignment = Enum.TextXAlignment.Left
	weaponLabel.Parent = self.hotbarFrame
end

function DarkSoulsInventoryGUI:CreateInventoryPanel()
	-- Main inventory panel (hidden by default)
	self.inventoryFrame = Instance.new("Frame")
	self.inventoryFrame.Name = "InventoryPanel"
	self.inventoryFrame.Size = CONFIG.INVENTORY_SIZE
	self.inventoryFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
	self.inventoryFrame.BackgroundColor3 = COLORS.BACKGROUND
	self.inventoryFrame.BorderColor3 = COLORS.FRAME_BORDER
	self.inventoryFrame.BorderSizePixel = 3
	self.inventoryFrame.Visible = false
	self.inventoryFrame.Parent = self.screenGui
	
	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = self.inventoryFrame
	
	-- Add title
	local title = Instance.new("TextLabel")
	title.Name = "InventoryTitle"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "INVENTORY"
	title.TextColor3 = COLORS.TEXT_PRIMARY
	title.TextScaled = true
	title.Font = Enum.Font.SourceSansBold
	title.Parent = self.inventoryFrame
	
	-- Create equipment frame within inventory
	self:CreateEquipmentFrame()
end

function DarkSoulsInventoryGUI:CreateEquipmentFrame()
	self.equipmentFrame = Instance.new("Frame")
	self.equipmentFrame.Name = "EquipmentFrame"
	self.equipmentFrame.Size = UDim2.new(0.4, 0, 0.8, 0)
	self.equipmentFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
	self.equipmentFrame.BackgroundColor3 = COLORS.SLOT_EMPTY
	self.equipmentFrame.BorderColor3 = COLORS.FRAME_BORDER
	self.equipmentFrame.BorderSizePixel = 2
	self.equipmentFrame.Parent = self.inventoryFrame
	
	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = self.equipmentFrame
	
	-- Equipment slots with proper alignment
	local equipmentTypes = {
		{name = "Helmet", pos = UDim2.new(0.5, -25, 0.1, 0)},
		{name = "Armor", pos = UDim2.new(0.5, -25, 0.3, 0)},
		{name = "Gauntlets", pos = UDim2.new(0.2, -25, 0.5, 0)},
		{name = "Leggings", pos = UDim2.new(0.5, -25, 0.7, 0)},
		{name = "Boots", pos = UDim2.new(0.8, -25, 0.5, 0)}
	}
	
	for _, equip in ipairs(equipmentTypes) do
		local slot = Instance.new("Frame")
		slot.Name = equip.name .. "Slot"
		slot.Size = CONFIG.SLOT_SIZE
		slot.Position = equip.pos
		slot.BackgroundColor3 = COLORS.SLOT_EMPTY
		slot.BorderColor3 = COLORS.FRAME_BORDER
		slot.BorderSizePixel = 1
		slot.Parent = self.equipmentFrame
		
		-- Add corner rounding
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = slot
		
		-- Add equipment label (properly aligned)
		local label = Instance.new("TextLabel")
		label.Name = "EquipmentLabel"
		label.Size = UDim2.new(0, 80, 0, 15)
		label.Position = UDim2.new(0, -90, 0.5, -7)
		label.BackgroundTransparency = 1
		label.Text = equip.name
		label.TextColor3 = COLORS.TEXT_SECONDARY
		label.TextScaled = true
		label.Font = Enum.Font.SourceSans
		label.TextXAlignment = Enum.TextXAlignment.Right
		label.Parent = slot
		
		-- Store equipment slot reference
		self.equipmentSlots[equip.name] = slot
	end
end

function DarkSoulsInventoryGUI:CreateStatsPanel()
	-- Survival stats panel (for real-time stat display)
	self.statsFrame = Instance.new("Frame")
	self.statsFrame.Name = "StatsPanel"
	self.statsFrame.Size = UDim2.new(0, 200, 0, 120)
	self.statsFrame.Position = UDim2.new(0, 10, 0, 10)
	self.statsFrame.BackgroundColor3 = COLORS.BACKGROUND
	self.statsFrame.BorderColor3 = COLORS.FRAME_BORDER
	self.statsFrame.BorderSizePixel = 2
	self.statsFrame.Parent = self.screenGui
	
	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = self.statsFrame
	
	-- Create stat bars
	local stats = {
		{name = "Health", color = COLORS.STAT_HEALTH, pos = 0},
		{name = "Stamina", color = COLORS.STAT_STAMINA, pos = 1},
		{name = "Hunger", color = COLORS.STAT_HUNGER, pos = 2},
		{name = "Thirst", color = COLORS.STAT_THIRST, pos = 3}
	}
	
	for _, stat in ipairs(stats) do
		local yPos = 0.1 + (stat.pos * 0.2)
		
		-- Stat label
		local label = Instance.new("TextLabel")
		label.Name = stat.name .. "Label"
		label.Size = UDim2.new(0.4, 0, 0.15, 0)
		label.Position = UDim2.new(0.05, 0, yPos, 0)
		label.BackgroundTransparency = 1
		label.Text = stat.name
		label.TextColor3 = COLORS.TEXT_SECONDARY
		label.TextScaled = true
		label.Font = Enum.Font.SourceSans
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = self.statsFrame
		
		-- Stat bar background
		local barBg = Instance.new("Frame")
		barBg.Name = stat.name .. "BarBg"
		barBg.Size = UDim2.new(0.5, 0, 0.12, 0)
		barBg.Position = UDim2.new(0.45, 0, yPos + 0.015, 0)
		barBg.BackgroundColor3 = COLORS.SLOT_EMPTY
		barBg.BorderSizePixel = 0
		barBg.Parent = self.statsFrame
		
		-- Stat bar
		local bar = Instance.new("Frame")
		bar.Name = stat.name .. "Bar"
		bar.Size = UDim2.new(1, 0, 1, 0)
		bar.Position = UDim2.new(0, 0, 0, 0)
		bar.BackgroundColor3 = stat.color
		bar.BorderSizePixel = 0
		bar.Parent = barBg
		
		-- Add rounded corners to bars
		local bgCorner = Instance.new("UICorner")
		bgCorner.CornerRadius = UDim.new(0, 3)
		bgCorner.Parent = barBg
		
		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(0, 3)
		barCorner.Parent = bar
	end
end

function DarkSoulsInventoryGUI:SetupInput()
	-- Setup input for inventory toggle
	self.connections.inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not self.isActive then return end
		
		if input.KeyCode == Enum.KeyCode.Tab then
			self:ToggleInventory()
		end
	end)
end

function DarkSoulsInventoryGUI:ToggleInventory()
	self.isInventoryOpen = not self.isInventoryOpen
	
	-- Animate inventory panel
	local targetPosition = self.isInventoryOpen and 
		UDim2.new(0.5, -400, 0.5, -300) or 
		UDim2.new(0.5, -400, -1, -300)
	
	self.inventoryFrame.Visible = true
	
	local tween = TweenService:Create(
		self.inventoryFrame,
		TweenInfo.new(CONFIG.ANIMATION_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{Position = targetPosition}
	)
	
	tween:Play()
	
	if not self.isInventoryOpen then
		tween.Completed:Connect(function()
			self.inventoryFrame.Visible = false
		end)
	end
	
	-- Notify camera system about inventory state
	if self.cameraSystem and self.cameraSystem.ToggleInventory then
		self.cameraSystem:ToggleInventory()
	end
	
	print("Dark Souls Inventory GUI: Inventory", self.isInventoryOpen and "opened" or "closed")
end

function DarkSoulsInventoryGUI:StartStatUpdates()
	-- Start real-time stat updates
	self.connections.statUpdater = RunService.Heartbeat:Connect(function()
		self:UpdateStats()
	end)
end

function DarkSoulsInventoryGUI:UpdateStats()
	-- Update survival stats in real-time
	-- This would integrate with actual survival system
	local stats = {"Health", "Stamina", "Hunger", "Thirst"}
	
	for _, statName in ipairs(stats) do
		local bar = self.statsFrame:FindFirstChild(statName .. "Bar")
		if bar then
			local current = self.currentStats[statName:lower()]
			local max = self.currentStats["max" .. statName]
			local percentage = current / max
			
			-- Animate stat bar
			local tween = TweenService:Create(
				bar,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = UDim2.new(percentage, 0, 1, 0)}
			)
			tween:Play()
		end
	end
end

function DarkSoulsInventoryGUI:IntegrateWithCameraSystem(cameraSystem)
	self.cameraSystem = cameraSystem
	print("Dark Souls Inventory GUI: Integrated with camera system")
end

function DarkSoulsInventoryGUI:IntegrateWithWeaponSystem(weaponSystem)
	self.weaponSystem = weaponSystem
	print("Dark Souls Inventory GUI: Integrated with weapon system")
end

function DarkSoulsInventoryGUI:UpdateSurvivalStats(health, hunger, thirst, stamina)
	-- Update survival stats from external system
	self.currentStats.health = health or self.currentStats.health
	self.currentStats.hunger = hunger or self.currentStats.hunger
	self.currentStats.thirst = thirst or self.currentStats.thirst
	self.currentStats.stamina = stamina or self.currentStats.stamina
end

function DarkSoulsInventoryGUI:Cleanup()
	self.isActive = false
	
	-- Disconnect all connections
	for _, connection in pairs(self.connections) do
		if connection then
			connection:Disconnect()
		end
	end
	self.connections = {}
	
	-- Remove GUI
	if self.screenGui then
		self.screenGui:Destroy()
	end
	
	print("Dark Souls Inventory GUI: Cleaned up")
end

-- Auto-initialize
DarkSoulsInventoryGUI:Initialize()

return DarkSoulsInventoryGUI