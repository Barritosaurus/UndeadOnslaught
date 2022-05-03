---------------------------------------
--    POLI Top-Down Weapon System    --
-- More info in WeaponHandler Script --
---------------------------------------
--			  Version 5.0            --
-- 		Date Created : 1/5/2021      --
---------------------------------------

-------------------
-- Initial Yield --
-------------------
local t = tick()
while (tick() - t) < 2 do
	game:GetService("RunService").RenderStepped:Wait()
end

-------------------------
-- Service Declaration --
-------------------------
local replicatedStorage    = game:GetService("ReplicatedStorage")
local runService           = game:GetService("RunService")
local contextActionService = game:GetService("ContextActionService")
local CollectionService    = game:GetService("CollectionService")
local userInputService     = game:GetService("UserInputService")
local Debris               = game:GetService("Debris")
local player               = game:GetService("Players").LocalPlayer

----------------------------------
-- Primary Variable Declaration --
----------------------------------
local tool      = script.Parent
local handle    = tool:WaitForChild("Handle")
local center    = handle:WaitForChild("BulletEmitter")
local mouse     = player:GetMouse()
local config    = require(tool:WaitForChild("POLI Config"))
local ammo      = tool:WaitForChild("Ammo")
local character = player.Character
local humanoid  = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
mouse.TargetFilter = workspace["MapObjects"].CurrentMap.NoTarget

------------------------------------------------------------------------------------------
-- Control Variable Declaration (See POLI Config to adjust variables of current weapon) --
------------------------------------------------------------------------------------------
local weaponType  = config.weaponType
local fireType    = config.fireType
local damage      = config.damage
local penetration = config.penetration
local bulletSpeed = config.bulletSpeed
local penValue    = config.penValue
local numShots    = config.numShots
local spread      = config.spread
local fireRate    = config.fireRate
local coolDown    = config.coolDown
local maxAmmo     = config.maxAmmo
local reloadTime  = config.reloadTime
local numShots    = config.numShots
local DEBUG       = config.DEBUG

---------------
-- Resources --
---------------
local damageMarker   = replicatedStorage.ParticleStorage:WaitForChild("DamageNumber")
local bloodSplatter  = replicatedStorage.ParticleStorage:WaitForChild("BloodSplatter")
local normalImpacts  = replicatedStorage.ParticleStorage:WaitForChild("NormalImpact")
local normalFlash    = replicatedStorage.ParticleStorage:WaitForChild("NormalFlash")
local plasmaFlash    = replicatedStorage.ParticleStorage:WaitForChild("PlasmaFlash")
local shotgunFlash   = replicatedStorage.ParticleStorage:WaitForChild("ShotgunFlash")
local specialFlash   = replicatedStorage.ParticleStorage:WaitForChild("SpecialFlash")
local cashMultiplier = nil
local primaryGUI     = nil

------------
-- Events --
------------
local gunEvent    = replicatedStorage.POLISystems.Weapons:WaitForChild("GunEvent")
local onHitEvent  = replicatedStorage.POLISystems.Weapons:WaitForChild("OnHitEvent")
local impactEvent = replicatedStorage.ServerEvents:WaitForChild("ImpactEvent")
local addCash     = replicatedStorage.ServerEvents:WaitForChild("AddCash")
local LoadedMap   = replicatedStorage.ServerValues:WaitForChild("LoadedMap")


-----------------------
-- Sound Declaration --
-----------------------
local FireSound      = nil
local ReloadSound    = nil
local OutOfAmmoSound = nil

-------------------
-- GUI Variables --
-------------------
local currentGUI    = nil
local bulletCurrent = nil
local bulletMax     = nil
local reloadLabel   = nil
local bulletDivider = nil
local displayName   = nil

---------------------
-- Logic Variables --
---------------------
local shooting   = false
local waiting    = false
local equipped   = false
local reloading  = false

-----------------
-- Connections --
-----------------
local equipConnection   = nil
local unequipConnection = nil
local onDeathConnection = nil
local ammoConnection    = nil
local renderStepConnection = nil
local mapChangeConnection  = nil

------------------------------
-- Remote Event Declaration --
------------------------------
local OnEquip   = replicatedStorage.POLISystems.Weapons:WaitForChild("OnEquip")
local OnUnEquip = replicatedStorage.POLISystems.Weapons:WaitForChild("OnUnEquip")
local OnReload  = replicatedStorage.POLISystems.Weapons:WaitForChild("OnReload")
local OnShoot   = replicatedStorage.POLISystems.Weapons:WaitForChild("OnShoot")
local GunEvent  = replicatedStorage.POLISystems.Weapons:WaitForChild("GunEvent")
local OnPreloadAnimations = replicatedStorage.POLISystems.Weapons:WaitForChild("OnPreloadAnimations")

------------------------------------------------------------------
-- 						  GUI Functions 						--
-- Applies the new currentGUI to the player on spawn / respawn. --
------------------------------------------------------------------
function setGUI()
	bulletCurrent = currentGUI.AmmoCurrent
	bulletMax     = currentGUI.AmmoMax
	reloadLabel   = currentGUI.ReloadLabel
	bulletDivider = currentGUI.Divider
	displayName   = currentGUI.WeaponName
	bulletCurrent.Text = tool.Ammo.Value
	if ammo.Value < (maxAmmo / 4) then
		bulletCurrent.TextColor3 = Color3.fromRGB(255, 0, 0)
	else
		bulletCurrent.TextColor3 = Color3.fromRGB(255,255,255)
	end
	bulletMax.Text     = maxAmmo
	displayName.Text   = "Ammo"

	if DEBUG == true then
		print("GUI Equipped")
	end
end

---------------
-- Animation --
---------------
local _idleAnim
local _fireAnim
local _reloadAnim

function PreloadAnimations(idleAnimation, fireAnimation, reloadAnimation)
	while (tick() - t) < 0.1 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	character = player.Character
	humanoid  = character:WaitForChild("Humanoid")
	idleAnim   = character.Humanoid:LoadAnimation(idleAnimation)
	fireAnim   = character.Humanoid:LoadAnimation(fireAnimation)
	reloadAnim = character.Humanoid:LoadAnimation(reloadAnimation)
end

function EquipAnimation()
	-- Idle
	idleAnim:Play()
	fireAnim:Stop()
	reloadAnim:Stop()
end

function ShootAnimation()
	-- Shoot
	idleAnim:Stop()
	fireAnim:Play()
	idleAnim:Play()
end

function ReloadAnimation()
	-- Reload
	idleAnim:Stop()
	reloadAnim:Play()
	idleAnim:Play()
end

function UnequipAnimations()
	-- Unequip Animations
	if idleAnim ~= nil then
		idleAnim:Stop()
		fireAnim:Stop()
		reloadAnim:Stop()
		idleAnim:Destroy()
		fireAnim:Destroy()
		reloadAnim:Destroy()
	end
end

-----------------------------------------------------------------
-- 				 	Equip / Unequip Functions                  --
-- Refreshes variables / Clears variables on equip or unequip. --
-----------------------------------------------------------------
function WeaponEquipped()
	PreloadAnimations(tool.Animations:WaitForChild("Idle"), tool.Animations:WaitForChild("Fire"), tool.Animations:WaitForChild("Reload"))
	FireSound      = handle.FireSound
	ReloadSound    = handle.Reload
	OutOfAmmoSound = handle.OutOfAmmo
	EquipAnimation()
	currentGUI = player.PlayerGui.weaponGUI
	setGUI()
	bulletCurrent.Visible = true
	bulletMax.Visible     = true
	bulletDivider.Visible = true
	reloadLabel.Visible   = false
	equipped = true
	contextActionService:BindActionAtPriority("ShootGun", onClick, true, 200, Enum.UserInputType.MouseButton1, Enum.UserInputType.Gamepad1)
	contextActionService:BindActionAtPriority("ReloadButton", onReload, true, 200, Enum.KeyCode.R)
	primaryGUI  = player.PlayerGui:WaitForChild("PrimaryGUI")
	cashMultiplier = primaryGUI:WaitForChild("CashMultiplier")
	if DEBUG == true then
		print("Weapon Equipped")
	end
end

function WeaponUnequipped()
	if DEBUG == true then
		print("Weapon Unequipped")
	end
	
	UnequipAnimations()
	currentGUI    = nil
	bulletCurrent = nil
	bulletMax     = nil
	reloadLabel   = nil
	displayName   = nil
	bulletDivider = nil
	shooting  = false
	equipped  = false
	reloading = false
	contextActionService:UnbindAction("ShootGun")
	contextActionService:UnbindAction("Reload")
end

-----------------------------------------------------------------------------
-- 							Reload Functionality                           --
-- Simple reload sequence, this process stops if the weapon is unequipped. --
-----------------------------------------------------------------------------
function WeaponReload()
	if reloading == false and equipped == true then
		reloading = true
		shooting  = false
		bulletCurrent.Visible = false
		bulletMax.Visible     = false
		bulletDivider.Visible = false
		reloadLabel.Visible   = true
		local breaking = false
		
		ReloadAnimation()
		ReloadSound:Play()
		
		local t = tick()
		while (tick() - t) < reloadTime do
			game:GetService("RunService").RenderStepped:Wait()		
			if equipped == false then
				ReloadSound:Stop()
				reloading = false
				breaking = true
			end
		end
		
		if breaking == false then
			bulletCurrent.TextColor3 = Color3.fromRGB(255, 255, 255)
			ammo.Value = maxAmmo
			reloading  = false
			bulletCurrent.Visible = true
			bulletMax.Visible     = true
			bulletDivider.Visible = true
			reloadLabel.Visible   = false
		end
	end
end

--------------------------------------
-- Context Action Service Functions --
--------------------------------------
function onClick(actionName, inputState)
	if DEBUG == true then
		print("User Clicked")
	end
	
	if inputState == Enum.UserInputState.Begin then
		shooting = true
	end
	
	if inputState == Enum.UserInputState.End then
		shooting = false
	end
end

function onReload(actionName, inputState)
	if DEBUG == true then
		print("User pressed R (Reload)")
	end
	
	if inputState == Enum.UserInputState.Begin then
		WeaponReload()
	end
end

-------------------
-- On Hit System --
-------------------
function onHit(objectHit, hitPos, playerPos, firingPlayer, damage, cashMultiplier)
	local human = nil

	if objectHit ~= nil and objectHit.Parent ~= nil then
		human = objectHit.Parent:FindFirstChild("Humanoid")
	end

	if objectHit and objectHit.Parent and human ~= nil and objectHit.Parent.Name ~= firingPlayer and objectHit.Parent.Parent ~= firingPlayer then
		if human.Health > 0 then
			onHitEvent:FireServer(objectHit, human, hitPos, center.Position, player, damage, cashMultiplier, true)
		end
	elseif objectHit and objectHit.Parent and objectHit.Parent.Name ~= firingPlayer and not objectHit.Parent.Parent:IsA("Tool") and objectHit.Transparency < 0.8 then
		onHitEvent:FireServer(objectHit, human, hitPos, center.Position, player, damage, cashMultiplier, false)
	end
end

------------------------------------------------------------------------------------------------------------
-- 											  Firing Function 											  --
-- This area of the script decides how weapon a weapon behaves upon firing a shoot-request to the server, --
-- these trees are directly affected by config found in the weapon. They are labled respectively.         --
------------------------------------------------------------------------------------------------------------
function shoot()
	-- Prevents firing while out of ammo, also plays the 'clink' of being out of ammo. --
	
	if ammo.Value <= 0 then
		waiting = true
		local t = tick()
		while (tick() - t) < fireRate do
			game:GetService("RunService").RenderStepped:Wait()
		end
		OutOfAmmoSound:Play()
		waiting = false
		WeaponReload()
	-- Full Automatic Fire --
	elseif not waiting and fireType == "FullAuto" then
		ammo.Value -= 1
		if DEBUG == true then
			print("Calling Server")
		end
		waiting  = true
		coroutine.wrap(function()
			local x = math.random(-spread * 100, spread * 100) / 100
			local endPos  = Vector3.new(mouse.Hit.p.X, center.Position.Y, mouse.Hit.p.Z)
			local bullet  = replicatedStorage.BulletStorage:FindFirstChild("Special"):Clone()
			local flash   = specialFlash:Clone()
			bullet.Parent = game.Workspace.CurrentCamera
			bullet.CFrame = CFrame.new(center.Position, endPos) * CFrame.Angles(0, math.rad(x), 0)
			local currentPen = bullet.pen
			local bv = Instance.new("BodyVelocity", bullet)
			bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bv.Velocity = bullet.CFrame.LookVector * bulletSpeed

			if tool ~= nil then
				flash.Parent = handle.Emitter
				flash.Enabled = true
				Debris:AddItem(flash, 0.05)
			end


			local connection
			local destroyConnection

			destroyConnection = bullet.AncestryChanged:connect(function()
				if not bullet:IsDescendantOf(game) then
					connection:Disconnect()
					destroyConnection:Disconnect()
				end
			end)
			connection = game:GetService"RunService".Heartbeat:Connect(function()
				if penetration == true then
					local ray = Ray.new(bullet.Position, bullet.CFrame.LookVector * 4)
					local hitPart, hitPos = workspace:FindPartOnRay(ray)
					if hitPart and hitPart.Parent ~= workspace and hitPart.Parent ~= game.Workspace.CurrentCamera and hitPart.Parent.Name ~= player.Name and hitPart.Name ~= "Handle" and hitPart.Name ~= "NonTarget" and hitPart.Parent.Name ~= "Handle" and not CollectionService:HasTag(hitPart.Parent, "Player") then
						coroutine.wrap(function()
							onHit(hitPart, hitPos, center.Position, player, damage, cashMultiplier.Value)
						end)()
						currentPen.Value = currentPen.Value + 1
						if currentPen.Value >= penValue then
							bullet:Destroy()
						end
						if hitPart.Parent:FindFirstChild("Humanoid") == nil then
							bullet:Destroy()
						end
					end		
				else
					local ray = Ray.new(bullet.Position, bullet.CFrame.LookVector * 4)
					local hitPart, hitPos = workspace:FindPartOnRay(ray)

					if hitPart and hitPart.Parent ~= workspace and hitPart.Parent ~= game.Workspace.CurrentCamera and hitPart.Parent.Name ~= player.Name and hitPart.Name ~= "Handle" and hitPart.Name ~= "NonTarget" and hitPart.Parent.Name ~= "Handle" and not CollectionService:HasTag(hitPart.Parent, "Player") then
						coroutine.wrap(function()
							onHit(hitPart, hitPos, center.Position, player, damage, cashMultiplier.Value)
						end)()
						bullet:Destroy()
					end
				end
			end)

			Debris:AddItem(bullet, 1)
			GunEvent:FireServer(center.Position + (humanoidRootPart.Velocity / 12), mouse.Hit.p, FireSound, weaponType, penetration, penValue, bulletSpeed, spread, damage, numShots, handle.Emitter, DEBUG)
			ShootAnimation()
		end)()
		local t = tick()
		while (tick() - t) < fireRate do
			game:GetService("RunService").RenderStepped:Wait()
		end
		waiting = false
		
	-- Semi Automatic Fire --
	elseif not waiting and fireType == "SemiAuto" then
		ammo.Value -= 1
		if DEBUG == true then
			print("Calling Server")
		end
		waiting  = true
		coroutine.wrap(function()
			local x = math.random(-spread * 100, spread * 100) / 100
			local endPos  = Vector3.new(mouse.Hit.p.X, center.Position.Y, mouse.Hit.p.Z)
			local bullet  = replicatedStorage.BulletStorage:FindFirstChild("Special"):Clone()
			local flash   = specialFlash:Clone()
			bullet.Parent = game.Workspace.CurrentCamera
			bullet.CFrame = CFrame.new(center.Position, endPos) * CFrame.Angles(0, math.rad(x), 0)
			local currentPen = bullet.pen
			local bv = Instance.new("BodyVelocity", bullet)
			bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bv.Velocity = bullet.CFrame.LookVector * bulletSpeed

			if tool ~= nil then
				flash.Parent = handle.Emitter
				flash.Enabled = true
				Debris:AddItem(flash, 0.05)
			end


			local connection
			local destroyConnection

			destroyConnection = bullet.AncestryChanged:connect(function()
				if not bullet:IsDescendantOf(game) then
					connection:Disconnect()
					destroyConnection:Disconnect()
				end
			end)
			connection = game:GetService"RunService".Heartbeat:Connect(function()
				if penetration == true then
					local ray = Ray.new(bullet.Position, bullet.CFrame.LookVector * 4)
					local hitPart, hitPos = workspace:FindPartOnRay(ray)
					if hitPart and hitPart.Parent ~= workspace and hitPart.Parent ~= game.Workspace.CurrentCamera and hitPart.Parent.Name ~= player.Name and hitPart.Name ~= "Handle" and hitPart.Name ~= "NonTarget" and hitPart.Parent.Name ~= "Handle" and not CollectionService:HasTag(hitPart.Parent, "Player") then
						coroutine.wrap(function()
							onHit(hitPart, hitPos, center.Position, player, damage, cashMultiplier.Value)
						end)()
						currentPen.Value = currentPen.Value + 1
						if currentPen.Value >= penValue then
							bullet:Destroy()
						end
						if hitPart.Parent:FindFirstChild("Humanoid") == nil then
							bullet:Destroy()
						end
					end		
				else
					local ray = Ray.new(bullet.Position, bullet.CFrame.LookVector * 4)
					local hitPart, hitPos = workspace:FindPartOnRay(ray)

					if hitPart and hitPart.Parent ~= workspace and hitPart.Parent ~= game.Workspace.CurrentCamera and hitPart.Parent.Name ~= player.Name and hitPart.Name ~= "Handle" and hitPart.Name ~= "NonTarget" and hitPart.Parent.Name ~= "Handle" and not CollectionService:HasTag(hitPart.Parent, "Player") then
						coroutine.wrap(function()
							onHit(hitPart, hitPos, center.Position, player, damage, cashMultiplier.Value)
						end)()
						bullet:Destroy()
					end
				end
			end)

			Debris:AddItem(bullet, 1)
			GunEvent:FireServer(center.Position + (humanoidRootPart.Velocity / 12), mouse.Hit.p, FireSound, weaponType, penetration, penValue, bulletSpeed, spread, damage, numShots, handle.Emitter, DEBUG)
			ShootAnimation()
		end)()
		local t = tick()
		while (tick() - t) < coolDown do
			game:GetService("RunService").RenderStepped:Wait()
		end
		waiting  = false
		shooting = false
		
	-- Burst Fire --
	elseif not waiting and fireType == "Burst" then
		for i = 0, numShots do
			if ammo.Value > 0 and equipped == true then
				ammo.Value -= 1
				if DEBUG == true then
					print("Calling Server")
				end
				waiting  = true
				coroutine.wrap(function()
					local x = math.random(-spread * 100, spread * 100) / 100
					local endPos  = Vector3.new(mouse.Hit.p.X, center.Position.Y, mouse.Hit.p.Z)
					local bullet  = replicatedStorage.BulletStorage:FindFirstChild("Special"):Clone()
					local flash   = specialFlash:Clone()
					bullet.Parent = game.Workspace.CurrentCamera
					bullet.CFrame = CFrame.new(center.Position, endPos) * CFrame.Angles(0, math.rad(x), 0)
					local currentPen = bullet.pen
					local bv = Instance.new("BodyVelocity", bullet)
					bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					bv.Velocity = bullet.CFrame.LookVector * bulletSpeed

					if tool ~= nil then
						flash.Parent = handle.Emitter
						flash.Enabled = true
						Debris:AddItem(flash, 0.05)
					end


					local connection
					local destroyConnection

					destroyConnection = bullet.AncestryChanged:connect(function()
						if not bullet:IsDescendantOf(game) then
							connection:Disconnect()
							destroyConnection:Disconnect()
						end
					end)
					connection = game:GetService"RunService".Heartbeat:Connect(function()
						if penetration == true then
							local ray = Ray.new(bullet.Position, bullet.CFrame.LookVector * 4)
							local hitPart, hitPos = workspace:FindPartOnRay(ray)
							if hitPart and hitPart.Parent ~= workspace and hitPart.Parent ~= game.Workspace.CurrentCamera and hitPart.Parent.Name ~= player.Name and hitPart.Name ~= "Handle" and hitPart.Name ~= "NonTarget" and hitPart.Parent.Name ~= "Handle" and not CollectionService:HasTag(hitPart.Parent, "Player") then
								coroutine.wrap(function()
									onHit(hitPart, hitPos, center.Position, player, damage, cashMultiplier.Value)
								end)()
								currentPen.Value = currentPen.Value + 1
								if currentPen.Value >= penValue then
									bullet:Destroy()
								end
								if hitPart.Parent:FindFirstChild("Humanoid") == nil then
									bullet:Destroy()
								end
							end		
						else
							local ray = Ray.new(bullet.Position, bullet.CFrame.LookVector * 4)
							local hitPart, hitPos = workspace:FindPartOnRay(ray)

							if hitPart and hitPart.Parent ~= workspace and hitPart.Parent ~= game.Workspace.CurrentCamera and hitPart.Parent.Name ~= player.Name and hitPart.Name ~= "Handle" and hitPart.Name ~= "NonTarget" and hitPart.Parent.Name ~= "Handle" and not CollectionService:HasTag(hitPart.Parent, "Player") then
								coroutine.wrap(function()
									onHit(hitPart, hitPos, center.Position, player, damage, cashMultiplier.Value)
								end)()
								bullet:Destroy()
							end
						end
					end)

					Debris:AddItem(bullet, 1)
					GunEvent:FireServer(center.Position + (humanoidRootPart.Velocity / 12), mouse.Hit.p, FireSound, weaponType, penetration, penValue, bulletSpeed, spread, damage, numShots, handle.Emitter, DEBUG)
					ShootAnimation()
				end)()
				local q = tick()
				while (tick() - q) < 0.2 / numShots do
					game:GetService("RunService").RenderStepped:Wait()
				end
			elseif equipped == true then
				waiting = true
				OutOfAmmoSound:Play()
			end
		end
		
		local t = tick()
		while (tick() - t) < coolDown do
			game:GetService("RunService").RenderStepped:Wait()
		end
		waiting = false
		shooting = false
		
	-- Error Message --
	elseif not waiting then
		warn("Improper fireType indicated in weapon config, failed to shoot.")
	end
end

--------------------
-- Function Calls --
--------------------
equipConnection = tool.Equipped:Connect(WeaponEquipped)
unequipConnection = tool.Unequipped:Connect(WeaponUnequipped)
ammoConnection = ammo.Changed:Connect(function()
	bulletCurrent.Text = ammo.Value
	
	if ammo.Value < (maxAmmo / 4) then
		bulletCurrent.TextColor3 = Color3.fromRGB(255, 0, 0)
	end
end)

onDeathConnection = humanoid.Died:Connect(function()
	onDeathConnection:Disconnect()
	renderStepConnection:Disconnect()
	equipConnection:Disconnect()
	unequipConnection:Disconnect()
	ammoConnection:Disconnect()
end)

renderStepConnection = runService.RenderStepped:Connect(function()
	if shooting == true and equipped == true and reloading == false and humanoid ~= nil then
		shoot()
	end
end)

mapChangeConnection = LoadedMap:GetPropertyChangedSignal("Value"):Connect(function()
	UnequipAnimations()
	currentGUI    = nil
	bulletCurrent = nil
	bulletMax     = nil
	reloadLabel   = nil
	displayName   = nil
	bulletDivider = nil
	shooting  = false
	equipped  = false
	reloading = false
	contextActionService:UnbindAction("ShootGun")
	contextActionService:UnbindAction("Reload")
end)