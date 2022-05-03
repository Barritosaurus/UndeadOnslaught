--------------
-- Services --
--------------
local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

---------------------------
-- Variables / Instances --
---------------------------
local RoundChange       = ReplicatedStorage.ServerEvents:WaitForChild("RoundChange")
local RoundMusic        = ReplicatedStorage.Music:WaitForChild("RoundMusic")
local IntermissionMusic = ReplicatedStorage.Music:WaitForChild("IntermissionMusic")

-------------------
-- Current Round --
-------------------
local InRound = ReplicatedStorage.ServerValues:WaitForChild("InRound")

--------------------------
-- Refreshing Variables --
--------------------------
local Muted                  = nil
local roundStoredTime        = 0.0
local intermissionStoredTime = 0.0
local roundMusic             = nil
local intermissionMusic      = nil
local Settings               = nil
local ShopGUI                = nil
local roundState             = 0

-----------------
-- Connections --
-----------------
local optionConnection      = nil
local roundChangeConnection = nil
local onDeathConnection     = nil

-------------------
-- Functionality --
-------------------

local function onPlayerSpawn()
	repeat wait() until player.Character
	local character = player.Character
	local humanoid  = character:WaitForChild("Humanoid")
	-- Refresh Music and Position --
	ShopGUI            = player.PlayerGui:WaitForChild("ShopGUI", math.huge)
	Settings          = ShopGUI:WaitForChild("SettingsMenu")
	roundMusic        = RoundMusic:Clone()
	intermissionMusic = IntermissionMusic:Clone()
	roundMusic.Parent        = player
	intermissionMusic.Parent = player
	roundMusic.Volume        = 0
	intermissionMusic.Volume = 0
	roundMusic.TimePosition        = roundStoredTime
	intermissionMusic.TimePosition = intermissionStoredTime
	roundStoredTime        = 0.0
	intermissionStoredTime = 0.0
	
	local t = tick()
	while (tick() - t) < 0.2 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	Muted = Settings:WaitForChild("Option1Button").State
	
	-- Initial Mute Check --
	if Muted.Value == true then
		roundMusic.Volume = 0
		intermissionMusic.Volume = 0
	else
		if InRound.Value == false then
			intermissionMusic.Volume = 0.15
		else
			roundMusic.Volume = 0.15
		end
	end
	
	roundMusic:Play()
	intermissionMusic:Play()
	
	-- Connection to Mute Button --
	optionConnection = Muted:GetPropertyChangedSignal("Value"):Connect(function() -- Music Control
		if Muted.Value == true then
			roundMusic.Volume = 0
			intermissionMusic.Volume = 0
		else
			if roundState == 0 then
				intermissionMusic.Volume = 0.15
			else
				roundMusic.Volume = 0.15
			end
		end
	end)
	
	-- Change Music Based on Round --
	roundChangeConnection = RoundChange.onClientEvent:Connect(function(roundNumber)
		if roundNumber == 0 and Muted.Value == false then
			coroutine.wrap(function()
				for i = 0, 50 do
					roundMusic.Volume = roundMusic.Volume - 0.0020
					local t = tick()
					while (tick() - t) < 0.1 do
						game:GetService("RunService").RenderStepped:Wait()
					end
					if Muted.Value == true then
						roundMusic.Volume        = 0
						intermissionMusic.Volume = 0
						break
					end
				end
			end)()
			coroutine.wrap(function()
				for i = 0, 50 do
					intermissionMusic.Volume = intermissionMusic.Volume + 0.0010
					local t = tick()
					while (tick() - t) < 0.1 do
						game:GetService("RunService").RenderStepped:Wait()
					end
					if Muted.Value == true then
						roundMusic.Volume        = 0
						intermissionMusic.Volume = 0
						break
					end
				end
			end)()

			intermissionMusic.TimePosition = 0
			intermissionMusic:Play()
			local t = tick()
			while (tick() - t) < 1 do
				game:GetService("RunService").RenderStepped:Wait()
			end
			roundState = 0
			roundMusic:Stop()

		elseif roundNumber == 1 or roundMusic.Playing == false and Muted.Value == false then
			coroutine.wrap(function()
				for i = 0, 50 do
					intermissionMusic.Volume = intermissionMusic.Volume - 0.0020
					local t = tick()
					while (tick() - t) < 0.1 do
						game:GetService("RunService").RenderStepped:Wait()
					end
					if Muted.Value == true then
						roundMusic.Volume        = 0
						intermissionMusic.Volume = 0
						break
					end
				end
			end)()
			coroutine.wrap(function()
				for i = 0, 50 do
					roundMusic.Volume = roundMusic.Volume + 0.0010
					local t = tick()
					while (tick() - t) < 0.1 do
						game:GetService("RunService").RenderStepped:Wait()
					end
					if Muted.Value == true then
						roundMusic.Volume        = 0
						intermissionMusic.Volume = 0
						break
					end
				end
			end)()
			roundMusic.TimePosition = 0
			roundMusic:Play()
			local t = tick()
			while (tick() - t) < 1 do
				game:GetService("RunService").RenderStepped:Wait()
			end
			roundState = 1
			intermissionMusic:Stop()
		end
	end)
	
	onDeathConnection = humanoid.Died:Connect(function()
		onDeathConnection:Disconnect()
		optionConnection:Disconnect()
		roundChangeConnection:Disconnect()
	end)
end

--------------------
-- Function Calls --
--------------------
onPlayerSpawn()

-----------------------------
--    Connect Functions    --
-----------------------------
player.CharacterAdded:Connect(function() -- Detects player respawn and refreshes variables.
	roundStoredTime        = roundMusic.TimePosition
	intermissionStoredTime = intermissionMusic.TimePosition
	roundMusic:Destroy()
	intermissionMusic:Destroy()
	onPlayerSpawn()
end)