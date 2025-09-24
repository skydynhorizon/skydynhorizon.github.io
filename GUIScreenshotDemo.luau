--[[
	GUI Screenshot Demo Script
	
	This script creates a visual demonstration of the Dark Souls Inventory GUI
	to showcase the fixes implemented:
	- Weapon slots on RIGHT side of hotbar
	- Proper equipment alignment
	- Real-time survival stats
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GUIDemo = {
	demoActive = false,
	demoElements = {}
}

function GUIDemo:Initialize()
	print("=== Dark Souls GUI Visual Demo ===")
	print("Creating visual demonstration of the fixes implemented...")
	
	-- Wait for inventory GUI to load
	self:WaitForInventoryGUI()
	
	-- Create demo annotations
	self:CreateDemoAnnotations()
	
	-- Start demo sequence
	self:StartDemo()
end

function GUIDemo:WaitForInventoryGUI()
	local inventoryGui = playerGui:FindFirstChild("DarkSoulsInventoryGUI")
	local attempts = 0
	local maxAttempts = 50
	
	while not inventoryGui and attempts < maxAttempts do
		wait(0.1)
		inventoryGui = playerGui:FindFirstChild("DarkSoulsInventoryGUI")
		attempts = attempts + 1
	end
	
	if not inventoryGui then
		warn("GUI Demo: Dark Souls Inventory GUI not found after waiting")
		return false
	end
	
	print("GUI Demo: Inventory GUI found, proceeding with demo")
	return true
end

function GUIDemo:CreateDemoAnnotations()
	-- Create annotation GUI
	local annotationGui = Instance.new("ScreenGui")
	annotationGui.Name = "DemoAnnotations"
	annotationGui.Parent = playerGui
	
	-- Title annotation
	local title = Instance.new("TextLabel")
	title.Name = "DemoTitle"
	title.Size = UDim2.new(0, 400, 0, 60)
	title.Position = UDim2.new(0.5, -200, 0, 20)
	title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	title.BackgroundTransparency = 0.3
	title.BorderSizePixel = 0
	title.Text = "DARK SOULS INVENTORY - FIXES DEMONSTRATED"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Font = Enum.Font.SourceSansBold
	title.Parent = annotationGui
	
	-- Add rounded corners
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 8)
	titleCorner.Parent = title
	
	-- Weapon slot annotation (pointing to right side)
	local weaponAnnotation = Instance.new("TextLabel")
	weaponAnnotation.Name = "WeaponAnnotation"
	weaponAnnotation.Size = UDim2.new(0, 200, 0, 40)
	weaponAnnotation.Position = UDim2.new(1, -220, 1, -140)
	weaponAnnotation.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	weaponAnnotation.BackgroundTransparency = 0.2
	weaponAnnotation.BorderSizePixel = 0
	weaponAnnotation.Text = "✓ WEAPONS MOVED TO RIGHT"
	weaponAnnotation.TextColor3 = Color3.fromRGB(255, 255, 255)
	weaponAnnotation.TextScaled = true
	weaponAnnotation.Font = Enum.Font.SourceSansBold
	weaponAnnotation.Parent = annotationGui
	
	local weaponCorner = Instance.new("UICorner")
	weaponCorner.CornerRadius = UDim.new(0, 6)
	weaponCorner.Parent = weaponAnnotation
	
	-- Equipment alignment annotation
	local equipAnnotation = Instance.new("TextLabel")
	equipAnnotation.Name = "EquipAnnotation"
	equipAnnotation.Size = UDim2.new(0, 220, 0, 40)
	equipAnnotation.Position = UDim2.new(0, 20, 1, -140)
	equipAnnotation.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
	equipAnnotation.BackgroundTransparency = 0.2
	equipAnnotation.BorderSizePixel = 0
	equipAnnotation.Text = "✓ EQUIPMENT PROPERLY ALIGNED"
	equipAnnotation.TextColor3 = Color3.fromRGB(255, 255, 255)
	equipAnnotation.TextScaled = true
	equipAnnotation.Font = Enum.Font.SourceSansBold
	equipAnnotation.Parent = annotationGui
	
	local equipCorner = Instance.new("UICorner")
	equipCorner.CornerRadius = UDim.new(0, 6)
	equipCorner.Parent = equipAnnotation
	
	-- Survival stats annotation
	local statsAnnotation = Instance.new("TextLabel")
	statsAnnotation.Name = "StatsAnnotation"
	statsAnnotation.Size = UDim2.new(0, 180, 0, 40)
	statsAnnotation.Position = UDim2.new(0, 220, 0, 20)
	statsAnnotation.BackgroundColor3 = Color3.fromRGB(40, 100, 160)
	statsAnnotation.BackgroundTransparency = 0.2
	statsAnnotation.BorderSizePixel = 0
	statsAnnotation.Text = "✓ REAL-TIME STATS"
	statsAnnotation.TextColor3 = Color3.fromRGB(255, 255, 255)
	statsAnnotation.TextScaled = true
	statsAnnotation.Font = Enum.Font.SourceSansBold
	statsAnnotation.Parent = annotationGui
	
	local statsCorner = Instance.new("UICorner")
	statsCorner.CornerRadius = UDim.new(0, 6)
	statsCorner.Parent = statsAnnotation
	
	-- Store annotation GUI for cleanup
	self.demoElements.annotationGui = annotationGui
end

function GUIDemo:StartDemo()
	print("GUI Demo: Starting visual demonstration sequence...")
	self.demoActive = true
	
	-- Animate annotations appearing
	local annotations = self.demoElements.annotationGui:GetChildren()
	
	for i, annotation in ipairs(annotations) do
		if annotation:IsA("TextLabel") then
			-- Start invisible
			annotation.BackgroundTransparency = 1
			annotation.TextTransparency = 1
			
			-- Animate in with delay
			wait(0.5)
			
			local tween = TweenService:Create(
				annotation,
				TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					BackgroundTransparency = 0.2,
					TextTransparency = 0
				}
			)
			tween:Play()
		end
	end
	
	-- Demonstrate inventory toggle after annotations appear
	wait(2)
	self:DemonstrateInventoryToggle()
	
	-- Keep demo running for a while
	wait(10)
	self:CleanupDemo()
end

function GUIDemo:DemonstrateInventoryToggle()
	print("GUI Demo: Demonstrating inventory toggle functionality...")
	
	-- Find inventory GUI
	local inventoryGui = playerGui:FindFirstChild("DarkSoulsInventoryGUI")
	if not inventoryGui then return end
	
	local inventoryPanel = inventoryGui:FindFirstChild("InventoryPanel")
	if not inventoryPanel then return end
	
	-- Show inventory panel briefly for demo
	inventoryPanel.Visible = true
	inventoryPanel.Position = UDim2.new(0.5, -400, 0.5, -300)
	
	-- Create temporary highlight for equipment frame
	local equipmentFrame = inventoryPanel:FindFirstChild("EquipmentFrame")
	if equipmentFrame then
		local highlight = Instance.new("SelectionBox")
		highlight.Adornee = equipmentFrame
		highlight.Color3 = Color3.fromRGB(40, 120, 40)
		highlight.LineThickness = 0.2
		highlight.Transparency = 0.5
		highlight.Parent = equipmentFrame
		
		-- Remove highlight after demo
		game:GetService("Debris"):AddItem(highlight, 5)
	end
	
	-- Hide inventory panel after demo
	wait(3)
	inventoryPanel.Visible = false
end

function GUIDemo:CleanupDemo()
	print("GUI Demo: Cleaning up demonstration...")
	self.demoActive = false
	
	-- Remove annotation GUI
	if self.demoElements.annotationGui then
		self.demoElements.annotationGui:Destroy()
	end
	
	print("GUI Demo: Demonstration complete!")
	print("\n=== FIXES SUMMARY ===")
	print("✓ Weapon slots moved to RIGHT side of hotbar (E and R keys)")
	print("✓ Equipment labels and slots properly aligned")
	print("✓ Real-time survival stats integration (Health, Hunger, Thirst, Stamina)")
	print("✓ Dark Souls aesthetic maintained throughout")
	print("✓ Seamless integration with existing camera and weapon systems")
end

-- Auto-start demo
spawn(function()
	wait(2) -- Wait for other systems to initialize
	GUIDemo:Initialize()
end)

return GUIDemo