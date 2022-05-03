---------------------------------------
--    POLI Top-Down Weapon System    --
-- More info in WeaponHandler Script --
---------------------------------------
--			  Version 5.0            --
-- 		Date Created : 1/5/2021      --
---------------------------------------

--[[
The POLI top-down shooter weapon system is designed to make the process of creating weapons fast and modular, feel
free to use this system as you please, its quite simple and all of the control variables can be found in the config
modulescript found in the test weapon.
]]--

--------------
-- Services --
--------------
local replicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Debris            = game:GetService("Debris")

------------
-- Events --
------------
local gunEvent    = replicatedStorage.POLISystems.Weapons:WaitForChild("GunEvent")
local onHitEvent  = replicatedStorage.POLISystems.Weapons:WaitForChild("OnHitEvent")
local impactEvent = replicatedStorage.ServerEvents:WaitForChild("ImpactEvent")
local addCash     = replicatedStorage.ServerEvents:WaitForChild("AddCash")
local addExp      = replicatedStorage.ServerEvents:WaitForChild("AddExp")

------------
-- Sounds --
------------
local hitSound1 = replicatedStorage.Sounds:WaitForChild("HitSound1")
local hitSound2 = replicatedStorage.Sounds:WaitForChild("HitSound2")
local hitSound3 = replicatedStorage.Sounds:WaitForChild("HitSound3")
local killSound = replicatedStorage.Sounds:WaitForChild("KillSound")
local hitSoundDictionary = {
	[1] = hitSound1,
	[2] = hitSound2,
	[3] = hitSound3
}

---------------
-- Functions --
---------------
gunEvent.OnServerEvent:Connect(function(player, startPos, endPos, FireSound, weaponType, penetration, penValue, bulletSpeed, spread, damage, numShots, emitter, DEBUG)
	local firingPlayer = player.Name
	local playerPos    = player.character.HumanoidRootPart.Position
	FireSound:Play()
	
	coroutine.wrap(function()
		gunEvent:FireAllClients(startPos, endPos, firingPlayer, playerPos, weaponType, penetration, penValue, bulletSpeed, spread, damage, numShots, emitter)
	end)()
end)

onHitEvent.OnServerEvent:Connect(function(player, objectHit, human, hitPos, playerPos, firingPlayer, damage, cashMultiplier, humanHit)
	if humanHit then
		coroutine.wrap(function()
			impactEvent:FireAllClients(player.Name, playerPos, objectHit, hitPos, "Blood", damage)
		end)()

		local randomNumberBase = Random.new(tick())
		local index            = math.random(1, 3)
		local newSound         = hitSoundDictionary[index]:Clone()
		newSound.Name          = "OnHitSound"
		local soundTarget      = objectHit.Parent:FindFirstChild("HumanoidRootPart")
		
		if soundTarget and #{soundTarget:GetChildren()} < 4 then
			newSound.Parent  = soundTarget
			newSound:Play()
			Debris:AddItem(newSound, 0.5)
		end

		if CollectionService:HasTag(human.Parent, "Golden") then
			coroutine.wrap(function()
				addCash:Fire(player.Name, 15, cashMultiplier)
			end)()
		else
			coroutine.wrap(function()
				addCash:Fire(player.Name, 5, cashMultiplier)
			end)()
		end

		if (human.Health - damage) < 1 and not CollectionService:HasTag(human.Parent, "Dead") then
			if CollectionService:HasTag(human.Parent, "Golden") then
				coroutine.wrap(function()
					CollectionService:AddTag(human.Parent, "Dead")
					addCash:Fire(player.Name, 300, cashMultiplier)
					addExp:Fire(player.Name, 30)


				end)()
			else
				coroutine.wrap(function()
					CollectionService:AddTag(human.Parent, "Dead")
					addCash:Fire(player.Name, 100, cashMultiplier)
					addExp:Fire(player.Name, 10)
				end)()
			end
		end
		human:TakeDamage(damage)
	else
		if objectHit ~= nil and objectHit.Parent ~= nil and objectHit.Parent.Parent ~= nil and objectHit.Parent.Parent.Parent then
			if objectHit.Parent.Parent.Parent.Name ~= firingPlayer then
				coroutine.wrap(function()
					impactEvent:FireAllClients(player.Name, playerPos, objectHit, hitPos, "Dust", damage)
				end)()
			end
		else
			coroutine.wrap(function()
				impactEvent:FireAllClients(player.Name, playerPos, objectHit, hitPos, "Dust", damage)
			end)()
		end
	end
end)

----------------
-- Animations --
----------------
local IdleAnimation
local FireAnimation
local ReloadAnimation

replicatedStorage.POLISystems.Weapons.OnPreloadAnimations.OnServerEvent:Connect(function(player, idleAnimation, fireAnimation, reloadAnimation)
	IdleAnimation   = game.Workspace[player.Name].Humanoid:LoadAnimation(idleAnimation)
	FireAnimation   = game.Workspace[player.Name].Humanoid:LoadAnimation(fireAnimation)
	ReloadAnimation = game.Workspace[player.Name].Humanoid:LoadAnimation(reloadAnimation)
end)

replicatedStorage.POLISystems.Weapons.OnEquip.OnServerEvent:Connect(function(player)
	-- Idle
	IdleAnimation:Play()
	FireAnimation:Stop()
	ReloadAnimation:Stop()
end)

-- Shoot
replicatedStorage.POLISystems.Weapons.OnShoot.OnServerEvent:Connect(function(player)
	IdleAnimation:Stop()
	FireAnimation:Play()
	IdleAnimation:Play()
end)

-- Reload
replicatedStorage.POLISystems.Weapons.OnReload.OnServerEvent:Connect(function(player)
	IdleAnimation:Stop()
	ReloadAnimation:Play()
	IdleAnimation:Play()
end)

-- Unequip Animations
replicatedStorage.POLISystems.Weapons.OnUnEquip.OnServerEvent:Connect(function(player)
	IdleAnimation:Stop()
    IdleAnimation:Destroy()
	FireAnimation:Stop()
    FireAnimation:Destroy()
	ReloadAnimation:Stop()
	ReloadAnimation:Destroy()
	IdleAnimation = ""
	FireAnimation = ""
	ReloadAnimation = ""
end)