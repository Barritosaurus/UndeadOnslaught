--------------
-- Services --
--------------
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

----------------------------
-- Enable Manual Spawning --
----------------------------
Players.CharacterAutoLoads = false

------------
-- Events --
------------
local SpawnEvent = ReplicatedStorage.ServerEvents:WaitForChild("SpawnEvent")
local LoadedMap  = ReplicatedStorage.ServerValues:WaitForChild("LoadedMap")

------------
-- Config --
------------
local respawnTime = 4 -- Seconds

---------------------
-- Logic Variables --
---------------------
local respawnPlayers = true

---------------
-- Functions --
---------------
local function initiateRespawn(player, char)
	if respawnPlayers == true then
		if char then
			char:Remove()
			player:LoadCharacter()
		end
	end
end

local function spawnAllPlayers()
	respawnPlayers = true
	local character = nil
	for i, v in pairs(Players:GetPlayers()) do
		character = v.Character
		initiateRespawn(v, character)
	end
end

mapChangeConnection = LoadedMap:GetPropertyChangedSignal("Value"):Connect(function()
	respawnPlayers = false
	local t = tick()
	while (tick() - t) < 3 do
		game:GetService("RunService").Heartbeat:Wait()
	end
	for i, player in pairs(Players:GetPlayers()) do
		coroutine.wrap(function()
			if player.Character then player.Character.Humanoid:TakeDamage(9999) end
		end)
	end
	local t = tick()
	while (tick() - t) < 1 do
		game:GetService("RunService").Heartbeat:Wait()
	end
	spawnAllPlayers()
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local newConnection
		newConnection = char.Humanoid.Died:Connect(function()
			newConnection:Disconnect()
			local t = tick()
			while (tick() - t) < respawnTime do
				game:GetService("RunService").Heartbeat:Wait()
			end
			initiateRespawn(player, char)
		end)
	end)
end)

---------------------
-- Spawn Character --
---------------------
SpawnEvent.OnServerEvent:Connect(function(player)
	player:LoadCharacter()
end)