---------------------------------
-- Cleans the Players Backpack --
---------------------------------
local player = game:GetService("Players").LocalPlayer
local humanoid
local character

-----------------
-- Connections --
-----------------
local onDeathConnection = nil

local function onPlayerSpawn()
	repeat wait() until player.Character
	character = player.Character
	humanoid  = character:WaitForChild("Humanoid")
	onDeathConnection = humanoid.Died:Connect(function()
		onDeathConnection:Disconnect()
		for _, item in ipairs(player.Backpack:GetChildren()) do
			item:Destroy()
		end

		for _, item in ipairs(character:GetChildren()) do
			if item:IsA("Tool") then --replace objectvalue with what the value is.
				item:Destroy()
			end
		end
	end)
end

player.CharacterAdded:Connect(function(character)
	onPlayerSpawn()
end)