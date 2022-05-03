---------------------------------------
--          POLI Sprint System       --
--     Designed for Zombie Rush      --
---------------------------------------
--			  Version 1.0            --
-- 		Date Created : 1/17/2021     --
---------------------------------------

-----------
-- Yield --
-----------
repeat wait() until game.Players.LocalPlayer.Character

-------------------------
-- Service Declaration --
-------------------------
local replicatedStorage    = game:GetService("ReplicatedStorage")
local CollectionService    = game:GetService("CollectionService")
local runService           = game:GetService("RunService")
local contextActionService = game:GetService("ContextActionService")
local userInputService     = game:GetService("UserInputService")
local player               = game:GetService("Players").LocalPlayer
local humanoid             = nil

---------------
-- Variables --
---------------
local primaryGUI      = nil
local mobileGUI       = nil
local stamina         = nil
local weaponType      = nil
local newCharacter    = nil
local humanoid        = nil
local currentSP       = nil
local normalWalkspeed = nil
local sprintButton    = nil

-----------------
-- Connections --
-----------------
local weaponTypeConnection   = nil
local renderStepConnection   = nil
local onDeathConnection      = nil
local sprintButtonBeginConnection = nil
local sprintButtonEndConnection   = nil


---------------------
-- Logic Variables --
---------------------
local sprinting     = false
local recharging    = false

---------------
-- Functions --
---------------
function OnShift(actionName, inputState)
	if inputState == Enum.UserInputState.Begin and not CollectionService:HasTag(newCharacter, "Downed") and recharging == false then
		sprinting = true
		humanoid.WalkSpeed = normalWalkspeed * 2.2
	end

	if inputState == Enum.UserInputState.End and recharging == false then
		sprinting = false
		humanoid.WalkSpeed = normalWalkspeed
	end
end

local function onPlayerSpawn()
	local t = tick()
	while (tick() - t) < 0.2 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	primaryGUI = player.PlayerGui:WaitForChild("PrimaryGUI")
	mobileGUI  = player.PlayerGui:FindFirstChild("MobileControlGUI")
	
	if mobileGUI then
		stamina    = primaryGUI.Stamina
		weaponType = primaryGUI.WeaponType
		humanoid   = newCharacter:WaitForChild("Humanoid")
		sprintButton    = mobileGUI:WaitForChild("SprintButton")
		normalWalkspeed = humanoid.WalkSpeed
		recharging      = false
		stamina.Value   = 100
		
		sprintButtonBeginConnection = sprintButton.InputBegan:Connect(function()
			if recharging == false then
				sprinting = true
				humanoid.WalkSpeed = normalWalkspeed * 2.2
			end
		end)
		
		sprintButtonEndConnection = sprintButton.InputEnded:Connect(function()
			if recharging == false then
				sprinting = false
				humanoid.WalkSpeed = normalWalkspeed
			end
		end)
		
		weaponTypeConnection = weaponType.Changed:Connect(function()
			print("This shouldn't be firing.")
		end)
		
		renderStepConnection = runService.RenderStepped:Connect(function()
			if stamina.Value > 0 and sprinting == true then
				if newCharacter:FindFirstChild("HumanoidRootPart") then
					if stamina ~= nil and recharging == false and newCharacter.HumanoidRootPart.Velocity.Z ~= 0 or newCharacter.HumanoidRootPart.Velocity.X ~= 0 then
						stamina.Value -= 0.33
						if stamina.Value <= 0 then
							sprinting = false
							humanoid.WalkSpeed = normalWalkspeed
						end
					end
				end
			elseif stamina.Value <= 99.9 and sprinting == false then
				recharging = true
				humanoid.WalkSpeed = normalWalkspeed
				stamina.Value += 0.75
			else
				recharging = false
			end
		end)

		onDeathConnection = humanoid.Died:Connect(function()
			onDeathConnection:Disconnect()
			weaponTypeConnection:Disconnect()
			renderStepConnection:Disconnect()
			sprintButtonBeginConnection:Disconnect()
			sprintButtonEndConnection:Disconnect()
		end)
	else
		stamina    = primaryGUI.Stamina
		weaponType = primaryGUI.WeaponType
		humanoid   = newCharacter:WaitForChild("Humanoid")
		normalWalkspeed = humanoid.WalkSpeed
		contextActionService:BindActionAtPriority("Sprint", OnShift, true, 300,Enum.KeyCode.LeftShift)
		recharging = false
		stamina.Value = 100

		weaponTypeConnection = weaponType.Changed:Connect(function()
			print("This shouldn't be firing.")
		end)

		renderStepConnection = runService.RenderStepped:Connect(function()
			if stamina.Value > 0 and sprinting == true then
				if newCharacter:FindFirstChild("HumanoidRootPart") then
					if stamina ~= nil and recharging == false and newCharacter.HumanoidRootPart.Velocity.Z ~= 0 or newCharacter.HumanoidRootPart.Velocity.X ~= 0 then
						stamina.Value -= 0.33
						if stamina.Value <= 0 then
							sprinting = false
							humanoid.WalkSpeed = normalWalkspeed
						end
					end
				end
			elseif stamina.Value <= 99.9 and sprinting == false then
				recharging = true
				humanoid.WalkSpeed = normalWalkspeed
				stamina.Value += 0.75
			else
				recharging = false
			end
		end)

		onDeathConnection = humanoid.Died:Connect(function()
			onDeathConnection:Disconnect()
			weaponTypeConnection:Disconnect()
			renderStepConnection:Disconnect()
			contextActionService:UnbindAction("Sprint")
		end)
	end
end

--------------------
-- Function Calls --
--------------------
newCharacter = player.Character
onPlayerSpawn()

----------------------------
-- Player Clear / Refresh --
----------------------------
player.CharacterAdded:Connect(function(character) -- Detects player respawn and refreshes variables.
	newCharacter = character
	onPlayerSpawn()
end)

