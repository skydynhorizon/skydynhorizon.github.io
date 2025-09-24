--[[
	Dark Souls Integration System
	
	Integrates:
	- Dark Souls Inventory GUI
	- Advanced RE4 Camera System  
	- Weapon System
	- Survival System
	
	Ensures proper communication between all systems
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local player = Players.LocalPlayer

-- Integration System
local DarkSoulsIntegration = {
	isActive = false,
	
	-- System references
	inventoryGUI = nil,
	cameraSystem = nil,
	weaponSystem = nil,
	survivalSystem = nil,
	
	-- Integration settings
	settings = {
		enableInventoryIntegration = true,
		enableSurvivalIntegration = true,
		enableWeaponIntegration = true,
		enableCameraIntegration = true
	}
}

function DarkSoulsIntegration:Initialize()
	print("Dark Souls Integration: Initializing system integration...")
	
	-- Wait a moment for other systems to load
	wait(1)
	
	-- Load and integrate systems
	self:LoadSystems()
	self:IntegrateSystems()
	
	self.isActive = true
	print("Dark Souls Integration: All systems integrated successfully")
end

function DarkSoulsIntegration:LoadSystems()
	-- Load Dark Souls Inventory GUI
	local success, result = pcall(function()
		return require(script.Parent.DarkSoulsInventoryGUI)
	end)
	
	if success then
		self.inventoryGUI = result
		print("Dark Souls Integration: Inventory GUI loaded")
	else
		warn("Dark Souls Integration: Failed to load Inventory GUI:", result)
	end
	
	-- Load Survival System
	success, result = pcall(function()
		return require(script.Parent.SurvivalSystem)
	end)
	
	if success then
		self.survivalSystem = result
		print("Dark Souls Integration: Survival System loaded")
	else
		warn("Dark Souls Integration: Failed to load Survival System:", result)
	end
	
	-- Try to load existing camera system
	success, result = pcall(function()
		return require(script.Parent.AdvancedRE4Camera)
	end)
	
	if success then
		self.cameraSystem = result
		print("Dark Souls Integration: Camera System loaded")
	else
		-- Try alternative camera system
		success, result = pcall(function()
			return require(script.Parent.RE4CameraSystem)
		end)
		
		if success then
			self.cameraSystem = result
			print("Dark Souls Integration: Basic Camera System loaded")
		else
			warn("Dark Souls Integration: No camera system found")
		end
	end
	
	-- Try to load weapon system
	success, result = pcall(function()
		return require(script.Parent.WeaponSystemExample)
	end)
	
	if success then
		self.weaponSystem = result
		print("Dark Souls Integration: Weapon System loaded")
	else
		warn("Dark Souls Integration: Weapon System not found")
	end
end

function DarkSoulsIntegration:IntegrateSystems()
	-- Integrate Inventory GUI with Camera System
	if self.inventoryGUI and self.cameraSystem and self.settings.enableCameraIntegration then
		self.inventoryGUI:IntegrateWithCameraSystem(self.cameraSystem)
		
		-- Override camera system's inventory toggle to use our GUI
		if self.cameraSystem.ToggleInventory then
			local originalToggle = self.cameraSystem.ToggleInventory
			self.cameraSystem.ToggleInventory = function(cameraSystem)
				-- Call our inventory GUI toggle instead
				if self.inventoryGUI and self.inventoryGUI.ToggleInventory then
					self.inventoryGUI:ToggleInventory()
				end
				-- Still update camera system state
				originalToggle(cameraSystem)
			end
		end
	end
	
	-- Integrate Inventory GUI with Weapon System
	if self.inventoryGUI and self.weaponSystem and self.settings.enableWeaponIntegration then
		self.inventoryGUI:IntegrateWithWeaponSystem(self.weaponSystem)
		
		-- Add weapon display updates
		if self.weaponSystem.EquipWeapon then
			local originalEquip = self.weaponSystem.EquipWeapon
			self.weaponSystem.EquipWeapon = function(weaponSystem, weaponType)
				-- Call original function
				originalEquip(weaponSystem, weaponType)
				
				-- Update inventory GUI weapon display
				if self.inventoryGUI then
					self:UpdateWeaponDisplay(weaponType)
				end
			end
		end
	end
	
	-- Integrate Survival System with Inventory GUI
	if self.survivalSystem and self.inventoryGUI and self.settings.enableSurvivalIntegration then
		self.survivalSystem:IntegrateWithInventoryGUI(self.inventoryGUI)
	end
	
	-- Integrate Survival System with Weapon System (stamina consumption)
	if self.survivalSystem and self.weaponSystem then
		if self.weaponSystem.FireWeapon then
			local originalFire = self.weaponSystem.FireWeapon
			self.weaponSystem.FireWeapon = function(weaponSystem)
				-- Consume stamina when firing
				if self.survivalSystem then
					local stamina = self.survivalSystem:ConsumeStamina(5)
					if stamina < 10 then
						print("Too tired to fire weapon effectively!")
						return -- Prevent firing when too tired
					end
				end
				
				-- Call original function
				originalFire(weaponSystem)
			end
		end
	end
	
	-- Integrate Survival System with Camera System (movement effects)
	if self.survivalSystem and self.cameraSystem then
		-- Could add effects like slower movement when hungry/thirsty
		-- This would require modifications to the camera system's movement speed calculations
	end
end

function DarkSoulsIntegration:UpdateWeaponDisplay(weaponType)
	-- Update weapon slots in inventory GUI
	if not self.inventoryGUI or not self.inventoryGUI.weaponSlots then return end
	
	-- Clear previous weapon indicators
	for key, slot in pairs(self.inventoryGUI.weaponSlots) do
		slot.BackgroundColor3 = Color3.fromRGB(40, 35, 30) -- SLOT_EMPTY color
	end
	
	-- Highlight current weapon slot
	-- This is a simplified example - would need to map weapon types to slots
	local weaponSlotMapping = {
		PISTOL = "E",
		RIFLE = "R",
		SHOTGUN = "R"
	}
	
	local slotKey = weaponSlotMapping[weaponType]
	if slotKey and self.inventoryGUI.weaponSlots[slotKey] then
		self.inventoryGUI.weaponSlots[slotKey].BackgroundColor3 = Color3.fromRGB(60, 50, 40) -- SLOT_FILLED color
	end
end

function DarkSoulsIntegration:GetSystemStatus()
	-- Return status of all integrated systems
	return {
		inventoryGUI = self.inventoryGUI ~= nil,
		cameraSystem = self.cameraSystem ~= nil,
		weaponSystem = self.weaponSystem ~= nil,
		survivalSystem = self.survivalSystem ~= nil,
		isActive = self.isActive
	}
end

function DarkSoulsIntegration:EnableSystem(systemName, enabled)
	-- Enable/disable specific system integrations
	if self.settings["enable" .. systemName .. "Integration"] ~= nil then
		self.settings["enable" .. systemName .. "Integration"] = enabled
		print("Dark Souls Integration:", systemName, "integration", enabled and "enabled" or "disabled")
		
		-- Re-integrate systems if necessary
		if enabled then
			self:IntegrateSystems()
		end
	else
		warn("Dark Souls Integration: Unknown system:", systemName)
	end
end

function DarkSoulsIntegration:Cleanup()
	self.isActive = false
	
	-- Cleanup individual systems
	if self.inventoryGUI and self.inventoryGUI.Cleanup then
		self.inventoryGUI:Cleanup()
	end
	
	if self.survivalSystem and self.survivalSystem.Cleanup then
		self.survivalSystem:Cleanup()
	end
	
	print("Dark Souls Integration: Cleaned up")
end

-- Auto-initialize
DarkSoulsIntegration:Initialize()

return DarkSoulsIntegration