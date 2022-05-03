--------------
-- Services -- 
--------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

-------------------
-- Server Events --
-------------------
local SendDifficulty  = ReplicatedStorage.ServerEvents:WaitForChild("SendDifficulty")
local SendMap         = ReplicatedStorage.ServerEvents:WaitForChild("SendMap")
local VoteChangeEvent = ReplicatedStorage.ServerEvents:WaitForChild("VoteChangeEvent")

----------------
-- Vote Table --
----------------
local playerDifficultyVotes = {}
local playerMapVotes        = {}

-------------------
-- Server Values --
-------------------
local InRound     = ReplicatedStorage.ServerValues.InRound
local RoundStatus = ReplicatedStorage.ServerValues.RoundStatus
local CurrDiff    = ReplicatedStorage.ServerValues.CurrDiff
local votesEasy   = ReplicatedStorage.ServerValues.DifVoteEasy
local votesNormal = ReplicatedStorage.ServerValues.DifVoteNormal
local votesHard   = ReplicatedStorage.ServerValues.DifVoteHard
local map1Votes   = ReplicatedStorage.ServerValues.Map1Votes
local map2Votes   = ReplicatedStorage.ServerValues.Map2Votes
local map3Votes   = ReplicatedStorage.ServerValues.Map3Votes
local loadedMap   = ReplicatedStorage.ServerValues.LoadedMap
local currentMap1 = ReplicatedStorage.ServerValues.CurrentMap1
local currentMap2 = ReplicatedStorage.ServerValues.CurrentMap2
local currentMap3 = ReplicatedStorage.ServerValues.CurrentMap3

-----------------
-- Event Calls --
-----------------
local function changeDifficultyVote(player)
	if playerDifficultyVotes[player] == "easy" then
		votesEasy.Value = votesEasy.Value - 1
	elseif playerDifficultyVotes[player] == "normal" then
		votesNormal.Value = votesNormal.Value - 1
	else
		votesHard.Value = votesHard.Value - 1
	end
end

local function changeMapVote(player)
	if playerMapVotes[player] == "one" then
		map1Votes.Value = map1Votes.Value - 1
	elseif playerMapVotes[player] == "two" then
		map2Votes.Value = map2Votes.Value - 1
	else
		map3Votes.Value = map3Votes.Value - 1
	end
end

local function hasPlayerVoted(player, voteType)
	
	if voteType == "map" then
		if playerMapVotes[player] ~= nil then
			return true
		else
			return false
		end
	else
		if playerDifficultyVotes[player] ~= nil then
			return true
		else
			return false
		end
	end
end

InRound:GetPropertyChangedSignal("Value"):Connect(function()
	
	if votesHard.Value > votesNormal.Value then
		CurrDiff.Value = "hard"
	elseif votesNormal.Value > votesEasy.Value then
		CurrDiff.Value = "normal"
	else
		CurrDiff.Value = "easy"
	end
	
	
	if InRound.Value == false then
		if map3Votes.Value > map2Votes.Value then
			loadedMap.Value = currentMap3.Value
		elseif map2Votes.Value > map1Votes.Value then
			loadedMap.Value = currentMap2.Value
		else
			loadedMap.Value = currentMap1.Value
		end
		
		map1Votes.Value   = 0
		map2Votes.Value   = 0
		map3Votes.Value   = 0
		playerMapVotes    = {}
	end
	
	votesEasy.Value   = 0
	votesNormal.Value = 0
	votesHard.Value   = 0
	map1Votes.Value   = 0
	map2Votes.Value   = 0
	map3Votes.Value   = 0
	
	playerDifficultyVotes = {}
	playerMapVotes    = {}
end)

SendDifficulty.OnServerEvent:Connect(function(player, voteType)
	if voteType == "easy" then
		if hasPlayerVoted(player, "difficulty") == false then
			playerDifficultyVotes[player] = "easy"
			votesEasy.Value = votesEasy.Value + 1
		else
			changeDifficultyVote(player)
			playerDifficultyVotes[player] = "easy"
			votesEasy.Value = votesEasy.Value + 1
		end
	elseif voteType == "normal" then
		if hasPlayerVoted(player, "difficulty") == false then
			playerDifficultyVotes[player] = "normal"
			votesNormal.Value = votesNormal.Value + 1
		else
			changeDifficultyVote(player)
			playerDifficultyVotes[player] = "normal"
			votesNormal.Value = votesNormal.Value + 1
		end
	else
		if hasPlayerVoted(player, "difficulty") == false then
			playerDifficultyVotes[player] = "hard"
			votesHard.Value = votesHard.Value + 1
		else
			changeDifficultyVote(player)
			playerDifficultyVotes[player] = "hard"
			votesHard.Value = votesHard.Value + 1
		end
	end
end)

SendMap.OnServerEvent:Connect(function(player, voteType)
	if voteType == "one" then
		if hasPlayerVoted(player, "map") == false then
			playerMapVotes[player] = "one"
			map1Votes.Value = map1Votes.Value + 1
		else
			changeMapVote(player)
			playerMapVotes[player] = "one"
			map1Votes.Value = map1Votes.Value + 1
		end
	elseif voteType == "two" then
		if hasPlayerVoted(player, "map") == false then
			playerMapVotes[player] = "two"
			map2Votes.Value = map2Votes.Value + 1
		else
			changeMapVote(player)
			playerMapVotes[player] = "two"
			map2Votes.Value = map2Votes.Value + 1
		end
	else
		if hasPlayerVoted(player, "map") == false then
			playerMapVotes[player] = "three"
			map3Votes.Value = map3Votes.Value + 1
		else
			changeMapVote(player)
			playerMapVotes[player] = "three"
			map3Votes.Value = map3Votes.Value + 1
		end
	end 
end)