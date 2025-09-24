--[[
	Survival System for Dark Souls Integration
	
	Manages:
	- Health regeneration/damage
	- Hunger depletion and effects
	- Thirst depletion and effects  
	- Stamina management
	- Real-time stat updates to inventory GUI
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Survival System Class
local SurvivalSystem = {
	isActive = false,
	character = nil,
	humanoid = nil,
	
	-- Current stats
	stats = {
		health = 100,
		maxHealth = 100,
		hunger = 100,
		maxHunger = 100,
		thirst = 100,  
		maxThirst = 100,
		stamina = 100,
		maxStamina = 100
	},
	
	-- Depletion rates (per second)
	depletionRates = {
		hunger = 0.5,
		thirst = 0.8,
		staminaRegen = 2.0,
		healthRegen = 0.2
	},
	
	-- Effects thresholds
	thresholds = {
		lowHunger = 25,
		lowThirst = 20,
		criticalHealth = 30
	},
	
	-- Connections
	connections = {},
	
	-- Integration with inventory GUI
	inventoryGUI = nil
}

function SurvivalSystem:Initialize()
	print("Survival System: Initializing...")
	
	-- Wait for character
	if player.Character then
		self:SetupCharacter(player.Character)
	end
	
	player.CharacterAdded:Connect(function(character)
		self:SetupCharacter(character)
	end)
	
	player.CharacterRemoving:Connect(function()
		self:Cleanup()
	end)
	
	-- Start survival loop
	self:StartSurvivalLoop()
	
	self.isActive = true
	print("Survival System: Initialized successfully")
end

function SurvivalSystem:SetupCharacter(character)
	self.character = character
	self.humanoid = character:WaitForChild("Humanoid")
	
	-- Reset stats for new character
	self:ResetStats()
	
	-- Connect to humanoid health changes
	self.connections.healthChanged = self.humanoid.HealthChanged:Connect(function(health)
		self.stats.health = health
		self:UpdateInventoryGUI()
	end)
	
	print("Survival System: Character setup complete")
end

function SurvivalSystem:ResetStats()
	self.stats = {
		health = self.humanoid and self.humanoid.Health or 100,
		maxHealth = self.humanoid and self.humanoid.MaxHealth or 100,
		hunger = 100,
		maxHunger = 100,
		thirst = 100,
		maxThirst = 100,
		stamina = 100,
		maxStamina = 100
	}
end

function SurvivalSystem:StartSurvivalLoop()
	-- Main survival update loop
	self.connections.survivalLoop = RunService.Heartbeat:Connect(function(deltaTime)
		if not self.isActive or not self.character then return end
		
		self:UpdateHunger(deltaTime)
		self:UpdateThirst(deltaTime)
		self:UpdateStamina(deltaTime)
		self:UpdateHealth(deltaTime)
		self:ApplyEffects()
		self:UpdateInventoryGUI()
	end)
end

function SurvivalSystem:UpdateHunger(deltaTime)
	-- Decrease hunger over time
	self.stats.hunger = math.max(0, self.stats.hunger - (self.depletionRates.hunger * deltaTime))
	
	-- Apply hunger effects
	if self.stats.hunger <= 0 then
		-- Starving - health decreases
		self:DamagePlayer(0.5 * deltaTime, "starvation")
	elseif self.stats.hunger <= self.thresholds.lowHunger then
		-- Low hunger - reduced stamina regen
		self.depletionRates.staminaRegen = 1.0
	else
		-- Normal hunger - normal stamina regen
		self.depletionRates.staminaRegen = 2.0
	end
end

function SurvivalSystem:UpdateThirst(deltaTime)
	-- Decrease thirst over time
	self.stats.thirst = math.max(0, self.stats.thirst - (self.depletionRates.thirst * deltaTime))
	
	-- Apply thirst effects
	if self.stats.thirst <= 0 then
		-- Dehydrated - health decreases faster
		self:DamagePlayer(1.0 * deltaTime, "dehydration")
	elseif self.stats.thirst <= self.thresholds.lowThirst then
		-- Low thirst - reduced movement speed (would integrate with camera system)
		-- This could be implemented by notifying the camera system
	end
end

function SurvivalSystem:UpdateStamina(deltaTime)
	-- Regenerate stamina when not sprinting/fighting
	if self.stats.stamina < self.stats.maxStamina then
		self.stats.stamina = math.min(self.stats.maxStamina, 
			self.stats.stamina + (self.depletionRates.staminaRegen * deltaTime))
	end
end

function SurvivalSystem:UpdateHealth(deltaTime)
	-- Health regeneration when well-fed and hydrated
	if self.stats.hunger > 50 and self.stats.thirst > 50 and 
		self.stats.health < self.stats.maxHealth then
		
		local newHealth = math.min(self.stats.maxHealth,
			self.stats.health + (self.depletionRates.healthRegen * deltaTime))
		
		if self.humanoid then
			self.humanoid.Health = newHealth
		end
		self.stats.health = newHealth
	end
end

function SurvivalSystem:ApplyEffects()
	-- Apply visual/gameplay effects based on survival stats
	if not self.humanoid then return end
	
	-- Critical health effects
	if self.stats.health <= self.thresholds.criticalHealth then
		-- Could add screen effects, breathing sounds, etc.
	end
	
	-- Low stamina effects
	if self.stats.stamina <= 20 then
		-- Could reduce movement speed, prevent sprinting
	end
end

function SurvivalSystem:DamagePlayer(damage, reason)
	if self.humanoid and self.humanoid.Health > 0 then
		self.humanoid.Health = math.max(0, self.humanoid.Health - damage)
		print("Survival System: Player took", damage, "damage from", reason)
	end
end

function SurvivalSystem:ConsumeStamina(amount)
	-- Called by other systems (weapon, camera) to consume stamina
	self.stats.stamina = math.max(0, self.stats.stamina - amount)
	return self.stats.stamina
end

function SurvivalSystem:RestoreHunger(amount)
	-- Called when player eats food
	self.stats.hunger = math.min(self.stats.maxHunger, self.stats.hunger + amount)
	print("Survival System: Hunger restored by", amount)
end

function SurvivalSystem:RestoreThirst(amount)
	-- Called when player drinks
	self.stats.thirst = math.min(self.stats.maxThirst, self.stats.thirst + amount)
	print("Survival System: Thirst restored by", amount)
end

function SurvivalSystem:RestoreHealth(amount)
	-- Called when player uses healing items
	if self.humanoid then
		local newHealth = math.min(self.stats.maxHealth, self.stats.health + amount)
		self.humanoid.Health = newHealth
		self.stats.health = newHealth
		print("Survival System: Health restored by", amount)
	end
end

function SurvivalSystem:GetStats()
	-- Return current stats for other systems
	return {
		health = self.stats.health,
		maxHealth = self.stats.maxHealth,
		hunger = self.stats.hunger,
		maxHunger = self.stats.maxHunger,
		thirst = self.stats.thirst,
		maxThirst = self.stats.maxThirst,
		stamina = self.stats.stamina,
		maxStamina = self.stats.maxStamina
	}
end

function SurvivalSystem:IntegrateWithInventoryGUI(inventoryGUI)
	-- Integrate with inventory GUI for real-time stat display
	self.inventoryGUI = inventoryGUI
	print("Survival System: Integrated with inventory GUI")
end

function SurvivalSystem:UpdateInventoryGUI()
	-- Update inventory GUI with current stats
	if self.inventoryGUI and self.inventoryGUI.UpdateSurvivalStats then
		self.inventoryGUI:UpdateSurvivalStats(
			self.stats.health,
			self.stats.hunger, 
			self.stats.thirst,
			self.stats.stamina
		)
	end
end

function SurvivalSystem:Cleanup()
	self.isActive = false
	
	-- Disconnect all connections
	for _, connection in pairs(self.connections) do
		if connection then
			connection:Disconnect()
		end
	end
	self.connections = {}
	
	print("Survival System: Cleaned up")
end

-- Auto-initialize
SurvivalSystem:Initialize()

return SurvivalSystem