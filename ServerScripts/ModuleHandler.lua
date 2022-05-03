------------------------------------
-- POLI ModuleHandler + Functions --
------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataSavingModule  = require(ReplicatedStorage.Modules.DataSavingModule)
local SessionData       = require(ReplicatedStorage.Modules:WaitForChild("SessionData"))
local GetUserData       = ReplicatedStorage.ServerEvents:WaitForChild("GetUserData")
local SetWeapon         = ReplicatedStorage.ServerEvents:WaitForChild("SetWeapon")
local SetOption         = ReplicatedStorage.ServerEvents:WaitForChild("SetOption")


-- Returns player data --
GetUserData.OnServerInvoke = function(player)
	local iterator = 0
	for i, object in ipairs(SessionData) do
		iterator = i
		if object.ID == "user_"..player.UserId then
			break
		end
	end
	
	return SessionData[iterator]
end

-- Sets players saved primary / secondary weapons --
SetWeapon.OnServerEvent:Connect(function(player, itemName, position)
	
	local iterator = 0
	for i, object in ipairs(SessionData) do
		iterator = i
		if object.ID == "user_"..player.UserId then
			break
		end
	end
	
	if position == "primary" then
		SessionData[iterator].PrimaryWeapon = itemName
	end
	
	if position == "secondary" then
		SessionData[iterator].SecondaryWeapon = itemName
	end
	
	SessionData[iterator][itemName] = true
end)

-- Sets player saved options --
SetOption.OnServerEvent:Connect(function(player, OptionNum, state)
	local iterator = 0
	for i, object in ipairs(SessionData) do
		iterator = i
		if object.ID == "user_"..player.UserId then
			break
		end
	end
	
	
	if OptionNum == 1 then
		SessionData[iterator].Option1 = state
	elseif OptionNum == 2 then
		SessionData[iterator].Option2 = state
	elseif OptionNum == 3 then
		SessionData[iterator].Option3 = state
	elseif OptionNum == 4 then
		SessionData[iterator].Option4 = state
	else
		SessionData[iterator].Option5 = state
	end
end)