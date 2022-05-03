----------------------------
--  POLI SaveData System  --
--         	v0.5          --
----------------------------

------------------
-- Return Table --
------------------
local DataSavingModule = {}


--------------
-- Services --
--------------
local DataStoreService  = game:GetService("DataStoreService")
local playerData        = DataStoreService:GetDataStore("PlayerData")
local ServerStorage     = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------
-- Session Data Table --
------------------------
local sessionData = require(ReplicatedStorage.Modules:WaitForChild("SessionData"))

-----------------------
-- Control Variables --
-----------------------
local AUTOSAVE_INTERVAL = 120

-------------------------------
-- Add Playerdata to Session --
-------------------------------
local function setupPlayerData(player)
	print("Getting ", player.Name ,"'s data...")
	local playerUserId = "user_" .. player.UserId
	local success, data = pcall(function()
		return playerData:GetAsync(playerUserId)
	end)
	if success then
		if data then
		-- Data exists for this player
			local newData = {
				ID = playerUserId,
				Cash = data.Cash,
				Level = data.Level,
				Points = data.Points,
				Kills = data.Kills,
				Experience = data.Experience,
				PrimaryWeapon = data.PrimaryWeapon,
				SecondaryWeapon = data.SecondaryWeapon,
				AA12 = data.AA12,
				AK47 = data.AK47,
				BarLMG = data.BarLMG,
				Barrett50 = data.Barrett50,
				Deagle = data.Deagle,
				DoubleBarrel = data.DoubleBarrel,
				Famas = data.Famas,
				Kar98 = data.Kar98,
				M24 = data.M24,
				M249 = data.M249,
				M4A1 = data.M4A1,
				MP40 = data.MP40,
				RPD = data.RPD,
				Spas12 = data.Spas12,
				Uzi = data.Uzi,
				PlasmaRifle = data.PlasmaRifle,
				Tommygun = data.Tommygun,
				M1911 = data.M1911,
				MG42 = data.MG42,
				P90 = data.P90,
				SCARH = data.SCARH,
				Minigun = data.Minigun,
				RPG = data.RPG,
				G36 = data.G36,
				M110 = data.M110,
				PhotonBlaster = data.PhotonBlaster,
				Pride = data.Pride,
				Glory = data.Glory,
				GaussRifle = data.GuassRifle,
				Electrobeam = data.Electrobeam,
				Option1 = data.Option1,
				Option2 = data.Option2,
				Option3 = data.Option3,
				Option4 = data.Option4,
				Option5 = data.Option5			
			}
			table.insert(sessionData, newData)
			
		else
			-- Data store is working, but no current data for this player
			print("No data found, generating default!")
			local newData = {
				ID = playerUserId,
				Cash = 0, 
				Level = 1,
				Points = math.floor(math.pow(1, 1.5)) * 100,
				Kills = 0,
				Experience = 0, 
				PrimaryWeapon = "Tommygun", 
				SecondaryWeapon = "M1911", 
				AA12 = false,
				AK47 = false,
				BarLMG = false,
				Barrett50 = false,
				Deagle = false,
				DoubleBarrel = false,
				Famas = false,
				Kar98 = false,
				M24 = false,
				M249 = false,
				M4A1 = false,
				MP40 = false,
				RPD = false,
				Spas12 = false,
				Uzi = false,
				PlasmaRifle = false,
				Tommygun = true,
				M1911 = true,
				MG42 = false,
				P90 = false,
				SCARH = false,
				Minigun = false,
				RPG = false,
				G36 = false,
				M110 = false,
				PhotonBlaster = false,
				Pride = false,
				Glory = false,
				GaussRifle = false,
				Electrobeam = false,
				Option1 = false,
				Option2 = false,
				Option3 = false,
				Option4 = false,
				Option5 = false
			}
			playerData:SetAsync(playerUserId, newData)
			table.insert(sessionData, newData)
		end
	else
		warn("Cannot access data store for user, attempting to set default!")
	end
end

----------------------
-- Save Player Data --
----------------------
DataSavingModule.savePlayerData = function(playerUserId)
	print("Saving ",playerUserId,"'s data...")
	local tries = 0	
	local success
	repeat
		tries = tries + 1
		success = pcall(function()
		local iterator = 0
			for i, object in ipairs(sessionData) do
				iterator = i
				if object.ID == playerUserId then
				break
				end
			end
			
			--playerData:RemoveAsync(playerUserId)
			
			playerData:UpdateAsync(playerUserId, function(oldValue)
				return sessionData[iterator]
			end)
		end)
	if not success then wait(2.5) end
	until tries == 7 or success
	if not success then
		warn("Cannot save data for user!")
	else
		print("Succesfully saved user data for ",playerUserId,"!")
	end
end

-------------------------
-- Save on Player Exit --
-------------------------
local function saveOnExit(player)
	local playerUserId = "user_" .. player.UserId
	DataSavingModule.savePlayerData(playerUserId)
end

----------------------------
-- Periodically Save Data --
----------------------------
local function autoSave()
	while true do
		for i, object in ipairs(sessionData) do
			DataSavingModule.savePlayerData(sessionData[i].ID)
			local t = tick()
			while (tick() - t) < 1 do
				game:GetService("RunService").Heartbeat:Wait()
			end
		end	
		
		local t = tick()
		while (tick() - t) < AUTOSAVE_INTERVAL do
			game:GetService("RunService").Heartbeat:Wait()
		end
	end
end

--------------
-- Autosave --
--------------
spawn(autoSave)

--------------------
-- Connect Events --
--------------------
game.Players.PlayerAdded:Connect(setupPlayerData)
game.Players.PlayerRemoving:Connect(saveOnExit)

return DataSavingModule