--------------
-- Services --
--------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

-------------
-- Folders --
-------------
local CurrentMap = Workspace.MapObjects:WaitForChild("CurrentMap")
local Maps       = ReplicatedStorage:WaitForChild("Maps")

----------
-- Maps --
----------
local udo_arctic     = Maps:WaitForChild("udo_arctic")
local udo_beach      = Maps:WaitForChild("udo_beach")
local udo_citysquare = Maps:WaitForChild("udo_citysquare")
local udo_crash      = Maps:WaitForChild("udo_crash")
local udo_deserttown = Maps:WaitForChild("udo_deserttown")
local udo_facility   = Maps:WaitForChild("udo_facility")
local udo_forest     = Maps:WaitForChild("udo_forest")
local mapTable = {
	["udo_arctic"] = udo_arctic,
	["udo_beach"] = udo_beach,
	["udo_citysquare"] = udo_citysquare,
	["udo_crash"] = udo_crash,
	["udo_deserttown"] = udo_deserttown,
	["udo_facility"] = udo_facility,
	["udo_forest"] = udo_forest
}

-------------------
-- Server Events --
-------------------
local LoadedMap = ReplicatedStorage.ServerValues:WaitForChild("LoadedMap")

-------------------
-- Server Values --
-------------------
local CurrentMap1 = ReplicatedStorage.ServerValues:WaitForChild("CurrentMap1")
local CurrentMap2 = ReplicatedStorage.ServerValues:WaitForChild("CurrentMap2")
local CurrentMap3 = ReplicatedStorage.ServerValues:WaitForChild("CurrentMap3")


-----------------------
-- Map Randomization --
-----------------------
local currentMapNum = 1

-------------------
-- Functionality --
-------------------
local mapCopy = udo_forest:Clone()
for i, v in ipairs(mapCopy:GetChildren()) do
	v.Parent = CurrentMap
end

local meta = {
	__index = function(_, i) return i end
}

local function SetMapNumbers(n, i, j)
	local result = {}
	local temp   = setmetatable({}, meta)
	local index = -1
	local randomNumberBase = Random.new(tick())
	for k = 1, n do
		-- Swap first element in range with randomly selected element in range.
		index = randomNumberBase:NextInteger(i, j)
		local v = temp[index]
		temp[index] = temp[i]
		result[k] = v
		i = i + 1
	end
	return result
end

local numMaps = 0
for i, v in pairs(mapTable) do
	numMaps = numMaps + 1
end

LoadedMap:GetPropertyChangedSignal("Value"):Connect(function()
	print("Loading map ", LoadedMap.Value)
	local t = tick()
	while (tick() - t) < 1 do
		game:GetService("RunService").Heartbeat:Wait()
	end
	CurrentMap:ClearAllChildren()
	mapCopy = mapTable[LoadedMap.Value]:Clone()
	for i, v in ipairs(mapCopy:GetChildren()) do
		v.Parent = CurrentMap
		local t = tick()
		while (tick() - t) < 0.1 do
			game:GetService("RunService").Heartbeat:Wait()
		end
	end
	
	local newNums = SetMapNumbers(3, 1, numMaps)
	local iterator = 1
	for i, v in pairs(mapTable) do
		if newNums[1] == iterator then
			CurrentMap1.Value = v.Name
		end

		if newNums[2] == iterator then
			CurrentMap2.Value = v.Name
		end

		if newNums[3] == iterator then
			CurrentMap3.Value = v.Name
		end
		iterator = iterator + 1
	end
end)

local newNums = SetMapNumbers(3, 1, numMaps)
local iterator = 1
for i, v in pairs(mapTable) do
	if newNums[1] == iterator then
		CurrentMap1.Value = v.Name
	end

	if newNums[2] == iterator then
		CurrentMap2.Value = v.Name
	end

	if newNums[3] == iterator then
		CurrentMap3.Value = v.Name
	end
	iterator = iterator + 1
end