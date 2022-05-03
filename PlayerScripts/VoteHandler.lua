----------------------------------------
--          POLI Vote System          --
----------------------------------------
--			   Version 1.0            --
-- 	    Date Created : 1/17/2021      --
----------------------------------------

-----------
-- Yield --
-----------
repeat wait() until game.Players.LocalPlayer.Character

-------------------------
-- Service Declaration --
-------------------------
local replicatedStorage    = game:GetService("ReplicatedStorage")
local CollectionService    = game:GetService("CollectionService")
local TweenService         = game:GetService("TweenService")
local runService           = game:GetService("RunService")
local contextActionService = game:GetService("ContextActionService")
local userInputService     = game:GetService("UserInputService")
local player               = game:GetService("Players").LocalPlayer
local humanoid             = nil

---------------
-- Variables --
---------------
local PrimaryGUI   = nil
local shopGUI      = nil
local voteGUI      = nil
local mapvoteGUI   = nil
local easyVotes    = nil
local normalVotes  = nil
local hardVotes    = nil
local map1Votes    = nil
local map2Votes    = nil
local map3Votes    = nil
local newCharacter = nil
local humanoid     = nil

-----------------
-- Connections --
-----------------
local roundChangeConnection  = nil
local inRoundConnection      = nil
local onDeathConnection      = nil
local easyVotesConnection    = nil
local normalVotesConnection  = nil
local hardVotesConnection    = nil
local map1VotesConnection    = nil
local map2VotesConnection    = nil
local map3VotesConnection    = nil
local easyButtonConnection   = nil
local normalButtonConnection = nil
local hardButtonConnection   = nil
local map1ButtonConnection   = nil
local map2ButtonConnection   = nil
local map3ButtonConnection   = nil
local lockedConnection       = nil

---------------------
-- Logic Variables --
---------------------
local InRound           = replicatedStorage.ServerValues:WaitForChild("InRound")
local easyVotesServer   = replicatedStorage.ServerValues:WaitForChild("DifVoteEasy")
local normalVotesServer = replicatedStorage.ServerValues:WaitForChild("DifVoteNormal")
local hardVotesServer   = replicatedStorage.ServerValues:WaitForChild("DifVoteHard")
local map1VotesServer   = replicatedStorage.ServerValues:WaitForChild("Map1Votes")
local map2VotesServer   = replicatedStorage.ServerValues:WaitForChild("Map2Votes")
local map3VotesServer   = replicatedStorage.ServerValues:WaitForChild("Map3Votes")
local CurrentMap1       = replicatedStorage.ServerValues:WaitForChild("CurrentMap1")
local CurrentMap2       = replicatedStorage.ServerValues:WaitForChild("CurrentMap2")
local CurrentMap3       = replicatedStorage.ServerValues:WaitForChild("CurrentMap3")


------------
-- Events --
------------
local RoundChange = replicatedStorage.ServerEvents.RoundChange
local SendDifficulty  = replicatedStorage.ServerEvents:WaitForChild("SendDifficulty")
local SendMap         = replicatedStorage.ServerEvents:WaitForChild("SendMap")
local VoteChangeEvent = replicatedStorage.ServerEvents:WaitForChild("VoteChangeEvent")

---------------
-- Map Icons --
---------------
local mapTable = {
	["udo_arctic"] = {name = "Arctic", ID = 6890268502},
	["udo_beach"] = {name = "Beach", ID = 6890269915},
	["udo_citysquare"] = {name = "City Square", ID = 6890268807},
	["udo_crash"] = {name = "Crash", ID = 6890269681},
	["udo_deserttown"] = {name = "Desert", ID = 6899218295},
	["udo_facility"] = {name = "Facility", ID = 6890269401},
	["udo_forest"] = {name = "Forest", ID = 6890269095}
}

---------------
-- Functions --
---------------
local function onMapLoad()
	---------------
	-- Variables --
	---------------
	local loadingProgress = 0
	local loadingComplete = false

	------------------
	-- GUI Elements --
	------------------
	local LoadingScreen  = replicatedStorage.GUIStorage:WaitForChild("MapLoadingGUI")
	local LoadingGUI 	 = LoadingScreen:Clone()
	LoadingGUI.Parent    = player.PlayerGui
	local Background 	 = LoadingGUI.Background
	local LoadingCurrent = LoadingGUI.LoadingCurrent
	local LoadingEmpty   = LoadingGUI.LoadingEmpty
	local LogoClean      = LoadingGUI.LogoClean
	local LogoBloody     = LoadingGUI.LogoBloody
	local TipLabel       = LoadingGUI.TipLabel

	-----------------
	-- Intial Load --
	-----------------
	for loadingProgress = 1, 100 do
		if loadingComplete == true then
			LoadingCurrent.Size = UDim2.new(0.287, 0, 0.07, 0)
		else
			if LoadingCurrent then
				LoadingCurrent:TweenSize(UDim2.new(0.287 * (loadingProgress / 100), 0, 0.07, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			end
		end
		local t = tick()
		while (tick() - t) < 0.03 do
			game:GetService("RunService").RenderStepped:Wait()
		end
	end
	loadingComplete = true
	local backgroundTween = TweenService:Create(Background, TweenInfo.new(0.3), {ImageTransparency = 1})
	local loadingCurrentTween = TweenService:Create(LoadingCurrent, TweenInfo.new(1), {ImageTransparency = 1})
	local logoTween = TweenService:Create(LogoBloody, TweenInfo.new(1), {ImageTransparency = 1})
	local tipTween = TweenService:Create(TipLabel, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1})
	logoTween:Play()
	loadingCurrentTween:Play()
	tipTween:Play()
	backgroundTween:Play()
	LoadingEmpty.ImageTransparency = 1
	local t = tick()
	while (tick() - t) < 1.5 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	LoadingGUI:Destroy()
end

local function onPlayerSpawn()
	local t = tick()
	while (tick() - t) < 0.4 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	
	humanoid = newCharacter:WaitForChild("Humanoid")
	PrimaryGUI = player.PlayerGui:WaitForChild("PrimaryGUI")
	shopGUI = player.PlayerGui:WaitForChild("ShopGUI")
	voteGUI = player.PlayerGui:WaitForChild("VoteGUI")
	mapvoteGUI = player.PlayerGui:WaitForChild("MapVoteGUI")
	local easyButton   = voteGUI.VoteBackplate:WaitForChild("EasyButton")
	local normalButton = voteGUI.VoteBackplate:WaitForChild("NormalButton")
	local hardButton   = voteGUI.VoteBackplate:WaitForChild("HardButton")
	local map1Button   = mapvoteGUI.VoteBackplate:WaitForChild("Option1")
	local map2Button   = mapvoteGUI.VoteBackplate:WaitForChild("Option2")
	local map3Button   = mapvoteGUI.VoteBackplate:WaitForChild("Option3")
	local image1       = map1Button.ImageLabel
	local image2       = map2Button.ImageLabel
	local image3       = map3Button.ImageLabel
	local CancelSound  = PrimaryGUI:WaitForChild("CancelSound")
	local lockedIcon        = hardButton:WaitForChild("Locked")
	local requiredLevel     = lockedIcon:WaitForChild("LevelNum")
	local lockedLabel       = lockedIcon:WaitForChild("LevelLabel")
	local currentLevel      = PrimaryGUI:WaitForChild("Level")
	easyVotes   = easyButton:WaitForChild("CurrentVotes")
	normalVotes = normalButton:WaitForChild("CurrentVotes")
	hardVotes   = hardButton:WaitForChild("CurrentVotes")
	map1Votes = map1Button:WaitForChild("CurrentVotes")
	map2Votes = map2Button:WaitForChild("CurrentVotes")
	map3Votes = map3Button:WaitForChild("CurrentVotes")
	easyVotes.Text = "Votes : "..easyVotesServer.Value
	normalVotes.Text = "Votes : "..normalVotesServer.Value
	hardVotes.Text = "Votes : "..hardVotesServer.Value
	map1Votes.Text = map1VotesServer.Value
	map2Votes.Text = map2VotesServer.Value
	map3Votes.Text = map3VotesServer.Value
	map1Button.MapLabel.Text = mapTable[CurrentMap1.Value].name
	map2Button.MapLabel.Text = mapTable[CurrentMap2.Value].name
	map3Button.MapLabel.Text = mapTable[CurrentMap3.Value].name
	
	if InRound.Value == true then 	
		voteGUI.Enabled = false
	else
		voteGUI.Enabled = true
		for i,v in pairs(voteGUI:GetChildren()) do
			if v:IsA("ImageLabel") then
				TweenService:Create(v, TweenInfo.new(1), {BackgroundTransparency = 0.5}):Play()
			end

			if v:IsA("ImageButton") then
				TweenService:Create(v, TweenInfo.new(1), {BackgroundTransparency = 0.1, ImageTransparency = 0}):Play()
			end

			if v:IsA("TextLabel") then
				TweenService:Create(v, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66}):Play()
			end
		end

		for i,v in pairs(voteGUI.VoteBackplate:GetChildren()) do
			if v:IsA("ImageButton") then
				TweenService:Create(v, TweenInfo.new(1), {BackgroundTransparency = 0.1}):Play()
			end
		end

		for i,v in pairs(voteGUI.VoteBackplate.EasyButton:GetChildren()) do
			if v:IsA("ImageLabel") then
				TweenService:Create(v, TweenInfo.new(1), {ImageTransparency = 0}):Play()
			end

			if v:IsA("TextLabel") then
				TweenService:Create(v, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66}):Play()
			end
		end

		for i,v in pairs(voteGUI.VoteBackplate.HardButton:GetChildren()) do
			if v:IsA("ImageLabel") and v.Name ~= "Locked" then
				TweenService:Create(v, TweenInfo.new(1), {ImageTransparency = 0}):Play()
			end

			if v:IsA("TextLabel") then
				TweenService:Create(v, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66}):Play()
			end
		end

		for i,v in pairs(voteGUI.VoteBackplate.NormalButton:GetChildren()) do
			if v:IsA("ImageLabel") then
				TweenService:Create(v, TweenInfo.new(1), {ImageTransparency = 0}):Play()
			end

			if v:IsA("TextLabel") then
				TweenService:Create(v, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66}):Play()
			end
		end
	end
	
	inRoundConnection = InRound:GetPropertyChangedSignal("Value"):Connect(function()
		if InRound.Value == true then 	
			voteGUI.Enabled = false
		elseif mapvoteGUI then
			mapvoteGUI.Enabled = false
			onMapLoad()
			voteGUI.Enabled = true
			for i,v in pairs(voteGUI:GetChildren()) do
				if v:IsA("ImageLabel") then
					TweenService:Create(v, TweenInfo.new(1), {BackgroundTransparency = 0.5}):Play()
				end
				
				if v:IsA("ImageButton") then
					TweenService:Create(v, TweenInfo.new(1), {BackgroundTransparency = 0.1, ImageTransparency = 0}):Play()
				end

				if v:IsA("TextLabel") then
					TweenService:Create(v, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66}):Play()
				end
			end

			for i,v in pairs(voteGUI.VoteBackplate:GetChildren()) do
				if v:IsA("ImageButton") then
					TweenService:Create(v, TweenInfo.new(1), {BackgroundTransparency = 0.1}):Play()
				end
			end

			for i,v in pairs(voteGUI.VoteBackplate.EasyButton:GetChildren()) do
				if v:IsA("ImageLabel") then
					TweenService:Create(v, TweenInfo.new(1), {ImageTransparency = 0}):Play()
				end

				if v:IsA("TextLabel") then
					TweenService:Create(v, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66}):Play()
				end
			end

			for i,v in pairs(voteGUI.VoteBackplate.HardButton:GetChildren()) do
				if v:IsA("ImageLabel") then
					TweenService:Create(v, TweenInfo.new(1), {ImageTransparency = 0}):Play()
				end

				if v:IsA("TextLabel") then
					TweenService:Create(v, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66}):Play()
				end
			end

			for i,v in pairs(voteGUI.VoteBackplate.NormalButton:GetChildren()) do
				if v:IsA("ImageLabel") then
					TweenService:Create(v, TweenInfo.new(1), {ImageTransparency = 0}):Play()
				end

				if v:IsA("TextLabel") then
					TweenService:Create(v, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66}):Play()
				end
			end
		end
	end)
	
	roundChangeConnection = RoundChange.onClientEvent:Connect(function(roundNumber)
		image1.Image = "rbxassetid://"..mapTable[CurrentMap1.Value].ID
		image2.Image = "rbxassetid://"..mapTable[CurrentMap2.Value].ID
		image3.Image = "rbxassetid://"..mapTable[CurrentMap3.Value].ID
		if roundNumber == 11 then
			if mapvoteGUI then
				mapvoteGUI.Enabled = true

				for i,v in pairs(mapvoteGUI:GetChildren()) do
					if v:IsA("ImageLabel") then
						TweenService:Create(v, TweenInfo.new(1), {BackgroundTransparency = 0.5}):Play()
					end
					
					if v:IsA("ImageButton") then
						TweenService:Create(v, TweenInfo.new(1), {BackgroundTransparency = 0.1, ImageTransparency = 0}):Play()
					end

					if v:IsA("TextLabel") then
						TweenService:Create(v, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66}):Play()
					end
				end

				for i,v in pairs(mapvoteGUI.VoteBackplate:GetChildren()) do
					if v:IsA("ImageButton") then
						TweenService:Create(v, TweenInfo.new(1), {BackgroundTransparency = 0.4}):Play()
					end
				end

				for i,v in pairs(mapvoteGUI.VoteBackplate.Option1:GetChildren()) do
					if v:IsA("ImageLabel") then
						TweenService:Create(v, TweenInfo.new(1), {ImageTransparency = 0}):Play()
					end

					if v:IsA("TextLabel") then
						TweenService:Create(v, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66}):Play()
					end
				end

				for i,v in pairs(mapvoteGUI.VoteBackplate.Option2:GetChildren()) do
					if v:IsA("ImageLabel") then
						TweenService:Create(v, TweenInfo.new(1), {ImageTransparency = 0}):Play()
					end

					if v:IsA("TextLabel") then
						TweenService:Create(v, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66}):Play()
					end
				end

				for i,v in pairs(mapvoteGUI.VoteBackplate.Option3:GetChildren()) do
					if v:IsA("ImageLabel") then
						TweenService:Create(v, TweenInfo.new(1), {ImageTransparency = 0}):Play()
					end

					if v:IsA("TextLabel") then
						TweenService:Create(v, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66}):Play()
					end
				end
			end
		end
	end)
	
	local t = tick()
	while (tick() - t) < 0.5 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	
	easyButtonConnection = easyButton.MouseButton1Click:Connect(function()
		SendDifficulty:FireServer("easy")
	end)
	
	normalButtonConnection = normalButton.MouseButton1Click:Connect(function()
		SendDifficulty:FireServer("normal")
	end)
	
	if currentLevel.Value < requiredLevel.Value then -- If the item is not previously owned, example, by beta players; lock it for anyone below its level requirement.
		lockedIcon.ImageTransparency       = 0
		lockedIcon.BackgroundTransparency  = 0.6
		lockedLabel.TextTransparency       = 0
		lockedLabel.TextStrokeTransparency = 0.66
		lockedLabel.Text = "LVL "..requiredLevel.Value

		hardButtonConnection = hardButton.MouseButton1Click:Connect(function()
			CancelSound:Play()
		end)

		lockedConnection = currentLevel:GetPropertyChangedSignal("Value"):Connect(function(status)
			if currentLevel.Value >= requiredLevel.Value then -- If the player is not locked from the weapon anymore.
				lockedIcon.ImageTransparency       = 1
				lockedIcon.BackgroundTransparency  = 1
				lockedLabel.TextTransparency       = 1
				lockedLabel.TextStrokeTransparency = 1
				hardButtonConnection:Disconnect()
				lockedConnection:Disconnect()
				hardButtonConnection = hardButton.MouseButton1Click:Connect(function()
					SendDifficulty:FireServer("hard")
				end)
			else
				-- Nothing, player still is under the level requirement.
			end
		end)
	else
		lockedIcon.ImageTransparency       = 1
		lockedIcon.BackgroundTransparency  = 1
		lockedLabel.TextTransparency       = 1
		lockedLabel.TextStrokeTransparency = 1
		hardButtonConnection = hardButton.MouseButton1Click:Connect(function()
			SendDifficulty:FireServer("hard")
		end)
	end
	
	map1ButtonConnection = map1Button.MouseButton1Click:Connect(function()
		SendMap:FireServer("one")
	end)

	map2ButtonConnection = map2Button.MouseButton1Click:Connect(function()
		SendMap:FireServer("two")
	end)

 	map3ButtonConnection = map3Button.MouseButton1Click:Connect(function()
		SendMap:FireServer("three")
	end)
	
	easyVotesConnection = easyVotesServer:GetPropertyChangedSignal("Value"):Connect(function()
		easyVotes.Text = "Votes : "..easyVotesServer.Value
	end)
	
	normalVotesConnection = normalVotesServer:GetPropertyChangedSignal("Value"):Connect(function()
		normalVotes.Text = "Votes : "..normalVotesServer.Value
	end)
	
	hardVotesConnection = hardVotesServer:GetPropertyChangedSignal("Value"):Connect(function()
		hardVotes.Text = "Votes : "..hardVotesServer.Value
	end)
	
	map1VotesConnection = map1VotesServer:GetPropertyChangedSignal("Value"):Connect(function()
		map1Votes.Text = map1VotesServer.Value
	end)

	map2VotesConnection = map2VotesServer:GetPropertyChangedSignal("Value"):Connect(function()
		map2Votes.Text = map2VotesServer.Value
	end)

	map3VotesConnection = map3VotesServer:GetPropertyChangedSignal("Value"):Connect(function()
		map3Votes.Text = map3VotesServer.Value
	end)

	onDeathConnection = humanoid.Died:Connect(function()
		onDeathConnection:Disconnect()
		easyButtonConnection:Disconnect()
		normalButtonConnection:Disconnect()
		inRoundConnection:Disconnect()
		roundChangeConnection:Disconnect()
		hardButtonConnection:Disconnect()
		easyVotesConnection:Disconnect()
		normalVotesConnection:Disconnect()
		hardButtonConnection:Disconnect()
		mapvoteGUI = nil
		
	end)
end

--------------------
-- Function Calls --
--------------------
newCharacter = player.Character
onPlayerSpawn()

----------------------------
-- Player Clear / Refresh --
----------------------------
player.CharacterAdded:Connect(function(character) -- Detects player respawn and refreshes variables.
	newCharacter = character
	onPlayerSpawn(newCharacter)
end)

