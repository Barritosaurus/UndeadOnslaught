--------------
-- Services --
--------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------
-- Events --
------------
local RequestAll = ReplicatedStorage.ServerEvents:WaitForChild("RequestAll")

-------------
-- Storage --
-------------
local MobileGUIStorage   = ReplicatedStorage.GUIStorage:WaitForChild("MobileGUI")
local ComputerGUIStorage = ReplicatedStorage.GUIStorage:WaitForChild("ComputerGUI")
local MobileWeapons      = ReplicatedStorage:WaitForChild("MobileWeapons")
local ComputerWeapons    = ReplicatedStorage:WaitForChild("ComputerWeapons")

---------------
-- Functions --
---------------
RequestAll.OnServerInvoke = function(player, systemType)
	if systemType == "Mobile" then
		for _, guiObject in ipairs(MobileGUIStorage:GetChildren()) do
			local guiMember = guiObject:Clone()
			guiMember.Parent = player.PlayerGui
		end
		
		local t = tick()
		while (tick() - t) < 0.2 do
			game:GetService("RunService").Heartbeat:Wait()
		end

		
		for _, weapon in ipairs(MobileWeapons:GetChildren()) do
			local guiMember = weapon:Clone()
			guiMember.Parent = player.Backpack
		end
		
	else
		for _, guiObject in ipairs(ComputerGUIStorage:GetChildren()) do
			local guiMember = guiObject:Clone()
			guiMember.Parent = player.PlayerGui
		end
		
		local t = tick()
		while (tick() - t) < 0.2 do
			game:GetService("RunService").Heartbeat:Wait()
		end

		
		for _, weapon in ipairs(ComputerWeapons:GetChildren()) do
			local guiMember = weapon:Clone()
			guiMember.Parent = player.Backpack
		end
	end
end