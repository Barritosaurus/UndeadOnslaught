----------------------
-- POLI ShopHandler --
----------------------

--------------
-- Services --
--------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-------------
-- Modules --
-------------
local ItemList = require(ReplicatedStorage.Modules:WaitForChild("ItemCost"))
local PremList = require(ReplicatedStorage.Modules:WaitForChild("PremiumCost"))
local SessionData = require(ReplicatedStorage.Modules:WaitForChild("SessionData"))
local DataSavingModule = require(ReplicatedStorage.Modules:WaitForChild("DataSavingModule"))

------------
-- Values --
------------
local DiffBonus = ReplicatedStorage.ServerValues:WaitForChild("DiffBonus")

----------------------
-- Remote Functions --
----------------------
local ReturnLevel = ReplicatedStorage.ServerEvents:WaitForChild("ReturnLevel")

------------
-- Config --
------------
local constA = 10
local constB = -100
local constC = 111

----------------------
-- Remote Functions --
----------------------
local AddExp = ReplicatedStorage.ServerEvents:WaitForChild("AddExp")
AddExp.Event:Connect(function(firingPlayer, expRecieved)
	local actualPlayer = nil

	for i, object in ipairs(Players:GetChildren()) do
		if object.Name == firingPlayer then
			actualPlayer = object
			local playerUserId = "user_"..actualPlayer.UserId
			local playerGUI = actualPlayer.PlayerGui:WaitForChild("PrimaryGUI")
			local expValue = playerGUI:WaitForChild("EXP")
			local playerLevel = playerGUI:WaitForChild("Level")
			local savedExp = nil
			local serverExp = nil

			for i, object in ipairs(SessionData) do
				if object.ID == playerUserId then
					savedExp = object.Points
					object.Points = math.floor(savedExp + (expRecieved * DiffBonus.Value))
					expValue.Value = math.floor(savedExp + (expRecieved * DiffBonus.Value))
					
					if object.Points > (math.floor(math.pow(playerLevel.Value + 1, 1.5)) * 100) then
						object.Level = object.Level + 1
						playerLevel.Value = object.Level
					end
					
					--math.floor(0.04641588 * (object.Points ^ 0.667)) Super messy, but this will actually give us the correct level based upon the total exp.
					-- Old EXP Method
					--object.Level = math.floor(object.Level * 100 * 1.25) Increase A to to increase level gap gain. Decrease B to increase initial gap size. constA * math.log(savedExp + constC ) + constB 
					break
				end
			end
			break
		end
	end
end)

ReturnLevel.OnServerInvoke = function(player)
	local currentLevel = nil
	local playerUserId = "user_"..player.UserId

	-- This loop finds the player in the SessionData dictionary, the iterator will be the index location of the player data.
	for i, object in ipairs(SessionData) do
		if object.ID == playerUserId then
			currentLevel = object.Level
			break
		end
	end
	return currentLevel
end