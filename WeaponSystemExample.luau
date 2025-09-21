--[[
	Example Integration: RE4 Camera with Basic Weapon System
	
	This script demonstrates how to integrate the RE4 camera system
	with a basic weapon handling system for R6 models.
	
	Place this in StarterPlayerScripts alongside the camera system.
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Simple Weapon System Integration
local WeaponSystem = {
	isActive = false,
	character = nil,
	humanoid = nil,
	
	-- Weapon state
	currentWeapon = nil,
	isAiming = false,
	isFiring = false,
	
	-- Weapon types configuration
	WEAPONS = {
		PISTOL = {
			name = "Red9 Pistol",
			damage = 25,
			fireRate = 0.5,
			range = 100,
			ammoCapacity = 8,
			reloadTime = 2.0,
		},
		RIFLE = {
			name = "TMP Rifle",
			damage = 15,
			fireRate = 0.1,
			range = 150,
			ammoCapacity = 30,
			reloadTime = 2.5,
		},
		SHOTGUN = {
			name = "W-870 Shotgun",
			damage = 60,
			fireRate = 1.2,
			range = 50,
			ammoCapacity = 4,
			reloadTime = 3.0,
		}
	},
	
	-- Current weapon stats
	currentAmmo = 0,
	maxAmmo = 0,
	lastFireTime = 0,
	
	connections = {},
}

function WeaponSystem:Initialize()
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
end

function WeaponSystem:SetupCharacter(character)
	self.character = character
	self.humanoid = character:WaitForChild("Humanoid")
	
	-- Setup input
	self:SetupInput()
	
	-- Equip default weapon
	self:EquipWeapon("PISTOL")
	
	self.isActive = true
	print("Weapon System: Initialized for", character.Name)
end

function WeaponSystem:SetupInput()
	-- Clear existing connections
	for _, connection in pairs(self.connections) do
		if connection then
			connection:Disconnect()
		end
	end
	self.connections = {}
	
	-- Weapon switching
	self.connections.inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not self.isActive then return end
		
		if input.KeyCode == Enum.KeyCode.One then
			self:EquipWeapon("PISTOL")
		elseif input.KeyCode == Enum.KeyCode.Two then
			self:EquipWeapon("RIFLE")
		elseif input.KeyCode == Enum.KeyCode.Three then
			self:EquipWeapon("SHOTGUN")
		elseif input.KeyCode == Enum.KeyCode.R then
			self:Reload()
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:StartFiring()
		end
	end)
	
	self.connections.inputEnded = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed or not self.isActive then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:StopFiring()
		end
	end)
end

function WeaponSystem:EquipWeapon(weaponType)
	if not self.WEAPONS[weaponType] then
		warn("Unknown weapon type:", weaponType)
		return
	end
	
	self.currentWeapon = weaponType
	local weapon = self.WEAPONS[weaponType]
	
	self.maxAmmo = weapon.ammoCapacity
	self.currentAmmo = weapon.ammoCapacity
	
	print("Weapon System: Equipped", weapon.name)
	self:UpdateAmmoDisplay()
end

function WeaponSystem:StartFiring()
	if not self.currentWeapon then return end
	
	self.isFiring = true
	self:FireWeapon()
end

function WeaponSystem:StopFiring()
	self.isFiring = false
end

function WeaponSystem:FireWeapon()
	if not self.currentWeapon or not self.isActive then return end
	
	local weapon = self.WEAPONS[self.currentWeapon]
	local currentTime = tick()
	
	-- Check fire rate
	if currentTime - self.lastFireTime < weapon.fireRate then
		return
	end
	
	-- Check ammo
	if self.currentAmmo <= 0 then
		print("Weapon System: Out of ammo! Press R to reload.")
		return
	end
	
	-- Fire the weapon
	self:PerformShot(weapon)
	self.currentAmmo = self.currentAmmo - 1
	self.lastFireTime = currentTime
	
	self:UpdateAmmoDisplay()
	
	-- Continue firing if still holding button (for automatic weapons)
	if self.isFiring and weapon.fireRate < 0.5 then
		wait(weapon.fireRate)
		if self.isFiring then
			self:FireWeapon()
		end
	end
end

function WeaponSystem:PerformShot(weapon)
	-- Basic shooting mechanics
	print("Weapon System: BANG! Fired", weapon.name, "- Damage:", weapon.damage)
	
	-- Here you would typically:
	-- 1. Cast a ray from camera center
	-- 2. Check for hit targets
	-- 3. Apply damage
	-- 4. Create muzzle flash effect
	-- 5. Play sound effects
	
	-- Simple raycast example
	local camera = workspace.CurrentCamera
	local ray = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * weapon.range)
	
	if ray then
		local hitPart = ray.Instance
		local hitPosition = ray.Position
		
		print("Weapon System: Hit", hitPart.Name, "at distance", (camera.CFrame.Position - hitPosition).Magnitude)
		
		-- Check if we hit a humanoid
		local humanoid = hitPart.Parent:FindFirstChild("Humanoid")
		if humanoid and humanoid.Parent ~= self.character then
			print("Weapon System: Hit target for", weapon.damage, "damage!")
			-- Apply damage logic here
		end
	end
end

function WeaponSystem:Reload()
	if not self.currentWeapon or self.currentAmmo == self.maxAmmo then
		return
	end
	
	local weapon = self.WEAPONS[self.currentWeapon]
	print("Weapon System: Reloading", weapon.name, "...")
	
	-- Disable firing during reload
	local wasActive = self.isActive
	self.isActive = false
	
	-- Reload animation time
	wait(weapon.reloadTime)
	
	-- Restore ammo
	self.currentAmmo = self.maxAmmo
	self.isActive = wasActive
	
	print("Weapon System: Reload complete!")
	self:UpdateAmmoDisplay()
end

function WeaponSystem:UpdateAmmoDisplay()
	if not self.currentWeapon then return end
	
	local weapon = self.WEAPONS[self.currentWeapon]
	print("Weapon System:", weapon.name, "- Ammo:", self.currentAmmo .. "/" .. self.maxAmmo)
	
	-- Here you would update a GUI element showing ammo count
	-- Example: AmmoDisplay.Text = self.currentAmmo .. "/" .. self.maxAmmo
end

function WeaponSystem:Cleanup()
	self.isActive = false
	
	-- Disconnect connections
	for _, connection in pairs(self.connections) do
		if connection then
			connection:Disconnect()
		end
	end
	self.connections = {}
	
	print("Weapon System: Cleaned up")
end

-- Auto-initialize
WeaponSystem:Initialize()

return WeaponSystem