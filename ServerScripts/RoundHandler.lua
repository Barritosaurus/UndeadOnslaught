--------------
-- Services -- 
--------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

-------------------
-- Server Events --
-------------------
local roundEnded  = ReplicatedStorage.ServerEvents:WaitForChild("RoundEnded")
local roundBegin  = ReplicatedStorage.ServerEvents:WaitForChild("RoundBegin")
local roundChange = ReplicatedStorage.ServerEvents:WaitForChild("RoundChange")

--------------------------------
-- Round Management Variables --
--------------------------------
local roundLength        = 20
local intermissionLength = 20
local roundMessage       = 0
local roundTime          = roundLength * 10

-------------------
-- NPC Variables -- 
-------------------
local currentSpawns 	   = {}
local currentConnections   = {}
local currentlySpawning    = false
local individualSpawnDelay = 0.66
local hordeSize 		   = 6
local zombieVariantA 	   = ReplicatedStorage.NPCs:FindFirstChild("ZombieVariantA"):Clone()
local zombieVariantB 	   = ReplicatedStorage.NPCs:FindFirstChild("ZombieVariantB"):Clone()
local zombieVariantC 	   = ReplicatedStorage.NPCs:FindFirstChild("ZombieVariantC"):Clone()
local zombieVariantGold    = ReplicatedStorage.NPCs:FindFirstChild("ZombieVariantGold"):Clone()
local zombieVariantTank    = ReplicatedStorage.NPCs:FindFirstChild("ZombieVariantTank"):Clone()
local zombieVariantShade   = ReplicatedStorage.NPCs:FindFirstChild("ZombieVariantShade"):Clone()
local zombieVariantShaman  = ReplicatedStorage.NPCs:FindFirstChild("ZombieVariantShaman"):Clone()
local zombieMage     	   = nil
local zombieBossA    	   = nil
local zombieBossB    	   = nil
local speedDifficulty      = 22
local trackingCapability   = 3
local damageDifficulty     = 25
local spawnChance          = 1

-------------------------
-- Spawn Randomization --
-------------------------
local rng   			 = Random.new()
local randX 			 = nil
local randY 			 = nil
local randZ 			 = nil
local randomizedPosition = nil

------------------
-- NPC Spawners --
------------------
local spawnerFolder = game.Workspace.MapObjects.CurrentMap:WaitForChild("Spawners")
local zombiesFolder = game.Workspace.MapObjects.CurrentMap.NoTarget:WaitForChild("Zombies")

-------------------
-- Server Values --
-------------------
local LoadedMap    = ReplicatedStorage.ServerValues:WaitForChild("LoadedMap")
local RoundStatus  = ReplicatedStorage.ServerValues.RoundStatus
local Status 	   = ReplicatedStorage.ServerValues.WorldStatus
local InRound      = ReplicatedStorage.ServerValues.InRound
local CurrDiff     = ReplicatedStorage.ServerValues.CurrDiff
local DiffBonus    = ReplicatedStorage.ServerValues.DiffBonus
local RoundTime    = ReplicatedStorage.ServerValues.RoundTime
local CurrentRound = 0 -- A number between 0 - 5, determines the difficulty of the game. 0 Being the intermission / eventual mapchange state.
local zombieGold = nil
local zombieTank = nil
local zombieShade = nil
local zombieShaman = nil

------------------
-- Config Table --
------------------
local difficultyConfig = {
	["hard"] = {
		Size   = 3,
		Bonus  = 2.5,
		Speed  = 28,
		Damage = 35
	},

	["normal"] = {
		Size   = 2,
		Bonus  = 1.5,
		Speed  = 24,
		Damage = 25
	},

	["easy"] = {
		Size   = 1,
		Bonus  = 1,
		Speed  = 20,
		Damage = 25
	}
}

---------------
-- Functions --
---------------

local function roundType()
	-- Manually adjust all Zombie stats based on difficulty, for some reason we cannot iterate through each individual zombie with a list; fix later!
	DiffBonus.Value = difficultyConfig[CurrDiff.Value].Bonus
	zombieVariantA.Humanoid.WalkSpeed = difficultyConfig[CurrDiff.Value].Speed
	zombieVariantA.Configuration.AttackDamage.Value = difficultyConfig[CurrDiff.Value].Damage
	zombieVariantA.Configuration.Movespeed.Value = difficultyConfig[CurrDiff.Value].Speed
	zombieVariantB.Humanoid.WalkSpeed = difficultyConfig[CurrDiff.Value].Speed
	zombieVariantB.Configuration.AttackDamage.Value = difficultyConfig[CurrDiff.Value].Damage
	zombieVariantB.Configuration.Movespeed.Value = difficultyConfig[CurrDiff.Value].Speed
	zombieVariantC.Humanoid.WalkSpeed = difficultyConfig[CurrDiff.Value].Speed
	zombieVariantC.Configuration.AttackDamage.Value = difficultyConfig[CurrDiff.Value].Damage
	zombieVariantC.Configuration.Movespeed.Value = difficultyConfig[CurrDiff.Value].Speed
	zombieVariantGold.Humanoid.WalkSpeed = difficultyConfig[CurrDiff.Value].Speed
	zombieVariantGold.Configuration.AttackDamage.Value = difficultyConfig[CurrDiff.Value].Damage
	zombieVariantGold.Configuration.Movespeed.Value = difficultyConfig[CurrDiff.Value].Speed
	zombieVariantTank.Humanoid.WalkSpeed = difficultyConfig[CurrDiff.Value].Speed
	zombieVariantTank.Configuration.AttackDamage.Value = difficultyConfig[CurrDiff.Value].Damage
	zombieVariantTank.Configuration.Movespeed.Value = difficultyConfig[CurrDiff.Value].Speed
	zombieVariantShade.Configuration.AttackDamage.Value = difficultyConfig[CurrDiff.Value].Damage
	zombieVariantShaman.Configuration.AttackDamage.Value = difficultyConfig[CurrDiff.Value].Damage
	zombieGold = nil
	zombieTank = nil
    zombieShade = nil
	zombieShaman = nil
	
	if CurrentRound > 8 then
		hordeSize = difficultyConfig[CurrDiff.Value].Size * 3
		zombieShaman = zombieVariantShaman:Clone()
	elseif CurrentRound > 6 then
		hordeSize = difficultyConfig[CurrDiff.Value].Size * 3
		zombieTank = zombieVariantTank:Clone()
	elseif CurrentRound > 4 then
		hordeSize = difficultyConfig[CurrDiff.Value].Size * 3
		zombieGold = zombieVariantGold:Clone()
		if CurrDiff.Value == "hard" then
			zombieShade = zombieVariantShade:Clone()
		end
	elseif CurrentRound > 2 then
		hordeSize = difficultyConfig[CurrDiff.Value].Size
	else -- Default round settings, something probably went wrong if this fires.
		hordeSize = difficultyConfig[CurrDiff.Value].Size
	end
end

local function getVariant()
	-- Coinflips for a random zombie variant, only involves base zombies.
	local currentVariant = math.random(1,7)
	if currentVariant == 1 then
		return zombieVariantA
	elseif currentVariant == 2 then
		return zombieVariantB
	elseif currentVariant == 3 then
		currentVariant = math.random(1, spawnChance * 2)
		if currentVariant == 1 and zombieGold ~= nil then
			return zombieVariantGold
		end
		return zombieVariantB
	elseif currentVariant == 4 then
		currentVariant = math.random(1, spawnChance)
		if currentVariant == 1 and zombieTank ~= nil then
			return zombieVariantTank
		end
		return zombieVariantC
	elseif currentVariant == 5 then
		if zombieShade ~= nil then
			return zombieVariantShade
		end
		return zombieVariantA
	elseif currentVariant == 6 then
		currentVariant = math.random(1, spawnChance * 4)
		if currentVariant == 1 and zombieShaman ~= nil then
			return zombieVariantShaman
		end
		return zombieVariantA
	else
		return zombieVariantC
	end
end

local function spawnHorde(spawner)
	local deathCount      = spawner.DeathCount
	local tempSize        = hordeSize
	local spawnerConnect  = nil
	local completeConnect = nil

	spawnerConnect = deathCount:GetPropertyChangedSignal("Value"):Connect(function()
		if deathCount.Value >= tempSize then
			spawnerConnect:Disconnect()
			completeConnect:Disconnect()
			deathCount.Value = 0
			spawnHorde(spawner)
		end
	end)
	
	completeConnect = InRound:GetPropertyChangedSignal("Value"):Connect(function()
		if InRound.Value == false then
			spawnerConnect:Disconnect()
			completeConnect:Disconnect()
		end
	end)
	
	table.insert(currentConnections, spawnerConnect)
	coroutine.wrap(function()
		for i = 1, hordeSize, 1 do
			local t = tick()
			while (tick() - t) < individualSpawnDelay do
				game:GetService("RunService").Heartbeat:Wait()
			end
			local spawnedClone = getVariant():Clone()
			local spawnedConnection  = nil
			local failsafeConnection = nil
			randX = rng:NextNumber(-10, 10)
			randY = rng:NextNumber(5, 10)
			randZ = rng:NextNumber(-10, 10)
			randomizedPosition = CFrame.new(randX, randY, randZ)
			spawnedClone.Parent = zombiesFolder
			spawnedClone.UpperTorso.CFrame = spawner.CFrame * randomizedPosition
			spawnedClone.Name = spawner.Name.."'s Zombie "..i
			
			table.insert(currentSpawns, spawnedClone)

			spawnedConnection = spawnedClone.Humanoid.Died:Connect(function()
				spawnedConnection:Disconnect()
				failsafeConnection:Disconnect()
				table.remove(currentSpawns, table.find(currentSpawns, spawnedClone.Name))
				deathCount.Value = deathCount.Value + 1
			end)
			
			failsafeConnection = InRound:GetPropertyChangedSignal("Value"):Connect(function()
				if InRound.Value == false then
					spawnedConnection:Disconnect()
					failsafeConnection:Disconnect()
				end
			end)
		end
	end)()
end

local function spawnHordes(initial, oldSpawner)
	spawnerFolder = game.Workspace.MapObjects.CurrentMap:WaitForChild("Spawners")
	zombiesFolder = game.Workspace.MapObjects.CurrentMap.NoTarget:WaitForChild("Zombies")
	-- Spawn a horde at a selected spawner, this can be fired mutliple times a round and should fire anytime all of the spawned members die.
	for j, spawner in pairs(spawnerFolder:GetChildren()) do
		spawnHorde(spawner)
	end
end

local function clearHordes()
	-- Cleans all hordes on the map, used at the end of the round.
	for i, currentConnection in pairs(currentConnections) do
		currentConnections[i]:Disconnect()
	end
	currentConnections = {}
	
	for i, currentObject in pairs(zombiesFolder:GetChildren()) do
		currentObject.Humanoid:TakeDamage(9999)
	end
	
	currentSpawns = {}
	
	for j, spawner in pairs(spawnerFolder:GetChildren()) do
		local deathCount = spawner.DeathCount
		deathCount.Value = 0
	end
end

local function endRound()
	-- Fires the client events that occur on round start, music, etc.
	clearHordes()
end

local function beginRound()
	-- Fires the client events that occur on round end, music, etc.
	if CurrentRound > 0 then
		spawnHordes(true)
	end
end

-----------------
-- AI Director --
-----------------
local function directAI()
	-- Directs the current spawning algorithm of the AI.
	
end

------------------------
-- Spawner Connection --
------------------------
local newMapConnection = LoadedMap:GetPropertyChangedSignal("Value"):Connect(function()
	clearHordes()
	local t = tick()
	while (tick() - t) < 2.5 do -- Just a small delay incase there is an lag or other delays.
		game:GetService("RunService").Heartbeat:Wait()
	end
	spawnerFolder = game.Workspace.MapObjects.CurrentMap:WaitForChild("Spawners")
	zombiesFolder = game.Workspace.MapObjects.CurrentMap.NoTarget:WaitForChild("Zombies")
end)

----------------
-- Timer Loop --
----------------
local function roundTimer()
	while wait() do
		if CurrentRound == 0 then
			clearHordes()
			RoundTime.Value = intermissionLength
			Status.Value = "Intermission"
			for i = intermissionLength, 1, -1 do
				local t = tick()
				while (tick() - t) < 1 do
					game:GetService("RunService").Heartbeat:Wait()
				end
				RoundTime.Value = RoundTime.Value - 1
			end
			RoundTime.Value = roundTime
			CurrentRound = 1
			InRound.Value = true
			roundType()
			coroutine.wrap(function()
				beginRound()
			end)()
		end
		
		Status.Value = "Round " .. CurrentRound
		for i = roundLength, 1, -1 do
			RoundStatus.Value = "active"
			local t = tick()
			while (tick() - t) < 1 do
				game:GetService("RunService").Heartbeat:Wait()
			end
			RoundTime.Value = RoundTime.Value - 1
		end
		
		Status.Value = "Map Vote"
		if CurrentRound + 1 > 10 then
			clearHordes()
			RoundStatus.Value = "inactive"
			roundMessage = CurrentRound
			roundChange:FireAllClients(roundMessage + 1)
			CurrentRound = 0
			RoundTime.Value = intermissionLength
			for i = roundLength, 1, -1 do
				local t = tick()
				while (tick() - t) < 1 do
					game:GetService("RunService").Heartbeat:Wait()
				end
				RoundTime.Value = RoundTime.Value - 1
			end
			InRound.Value = false
		else
			roundType()
			CurrentRound = CurrentRound + 1
			roundMessage = CurrentRound
			roundChange:FireAllClients(roundMessage)
		end
	end
end

local onJoinConnection
local onLoadConnection
onJoinConnection = Players.PlayerAdded:Connect(function(player)
	print("Player connected, adding initial roundstart connection.")
	onLoadConnection = player.CharacterAdded:Connect(function()
		onJoinConnection:Disconnect()
		onLoadConnection:Disconnect()
		print("First player joined, starting round system.")
		spawn(roundTimer)
	end)
end)