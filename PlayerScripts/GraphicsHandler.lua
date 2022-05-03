---------------------------------------
--          POLI GUI System          --
--     Designed for Zombie Rush      --
---------------------------------------
--			  Version 1.0            --
-- 		Date Created : 1/12/2021     --
---------------------------------------

-----------
-- Yield --
-----------
repeat wait() until game.Players.LocalPlayer.Character

-------------------------
-- Service Declaration --
-------------------------
local replicatedStorage    = game:GetService("ReplicatedStorage")
local TweenService         = game:GetService("TweenService")
local runService           = game:GetService("RunService")
local contextActionService = game:GetService("ContextActionService")
local userInputService     = game:GetService("UserInputService")
local GuiService           = game:GetService("GuiService")
local player               = game:GetService("Players").LocalPlayer
local newCharacter         = nil
local humanoid             = nil

----------------------
-- Server Variables --
----------------------
local InRound     = replicatedStorage.ServerValues.InRound
local WorldStatus = replicatedStorage.ServerValues.WorldStatus
local RoundChange = replicatedStorage.ServerEvents.RoundChange
local LoadedMap   = replicatedStorage.ServerValues.LoadedMap

-----------------
-- GUI Storage --
-----------------
local MobileGUIStorage   = replicatedStorage.GUIStorage:WaitForChild("MobileGUI")
local ComputerGUIStorage = replicatedStorage.GUIStorage:WaitForChild("ComputerGUI")

------------------------
-- Events / Functions --
------------------------
local ReturnCash  = replicatedStorage.ServerEvents:WaitForChild("ReturnCash")
local ReturnLevel = replicatedStorage.ServerEvents:WaitForChild("ReturnLevel")
local RequestAll  = replicatedStorage.ServerEvents:WaitForChild("RequestAll")
local RoundTime   = replicatedStorage.ServerValues:WaitForChild("RoundTime")

----------------------
-- Client Variables --
----------------------
local PrimaryGUI    = nil
local WeaponGUI     = nil
local HPCurrent     = nil
local HPOld         = nil
local SPCurrent     = nil
local HPValue       = nil
local CashValue     = nil
local Level         = nil
local hpMax         = nil
local Stamina       = nil
local RoundState    = nil
local RoundText     = nil
local TimerLabel    = nil
local hpSize        = nil
local cashDisplay   = nil
local levelDisplay  = nil
local oldHP         = nil
local deathEffect   = nil
local roundTweenIn  = nil
local roundTweenOut = nil
local levelUpLabel  = nil

-------------
-- Buttons --
-------------
local ShopButton  = nil
local StatsButton = nil

-----------------
-- Connections --
-----------------
local healthConnection      = nil
local staminaConnection     = nil
local onDeathConnection     = nil
local mapChangeConnection   = nil
local worldStatusConnection = nil
local roundChangeConnection = nil
local cashConnection        = nil
local levelConnection       = nil
local maxHealthConnection   = nil
local timeChangeConnection  = nil
local roundTextConnection   = nil


--------------
-- Function --
--------------
local function formatNumber(number)
	number = tostring(number)
	return number:reverse():gsub("...","%0,",math.floor((#number - 1 ) / 3)):reverse()
end

local function secondsToRoundTime(seconds)
	if seconds <= 0 then
		return "00:00"
	else
		local hours = string.format("%02.f", math.floor(seconds/3600))
		local mins = string.format("%02.f", math.floor(seconds/60 - (hours * 60)))
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60))
		return mins..":"..secs
	end
end

local function onPlayerSpawn()
	repeat wait() until player.Character
	local t = tick()
	while (tick() - t) < 0.1 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	
	local DeathScreen        = replicatedStorage.GUIStorage:WaitForChild("DeathScreen"):Clone()
	local camera             = game.workspace.Camera
	local mapChanging        = false
	local userOnMobile       = false
	humanoid     = newCharacter:WaitForChild("Humanoid")
	oldHP        = humanoid.Health
	
	if #camera:GetChildren() > 0 then
		local success, response = pcall(function()
			camera.DeathEffect:Destroy()
		end)
	end 
	
	--[[
	if userInputService.TouchEnabled and not userInputService.MouseEnabled and not userInputService.GamepadEnabled and not GuiService:IsTenFootInterface() then -- Best way of determining user touchscreen, it only works if touchscreen is enabled, add a player option to disable this.
		userOnMobile = true
	end
	]]--
	
	if userInputService:GetLastInputType() == Enum.UserInputType.Touch then -- Best way of determining user touchscreen, it only works if touchscreen is enabled, add a player option to disable this.
		userOnMobile = true
	end

	
	if userOnMobile then
		RequestAll:InvokeServer("Mobile")
		PrimaryGUI               = player.PlayerGui:WaitForChild("PrimaryGUI")
		WeaponGUI                = player.PlayerGui:WaitForChild("weaponGUI")
		local ConfirmationGUI    = player.PlayerGui:WaitForChild("ConfirmationGUI")
		local WeaponSelectionGUI = player.PlayerGui:WaitForChild("WeaponSelectionGUI")
		local MobileGUI          = player.PlayerGui:WaitForChild("MobileControlGUI")
		local RoundDisplay       = PrimaryGUI:WaitForChild("RoundDisplay")
		local BloodGUI  	     = player.PlayerGui:WaitForChild("BloodGUI")
		local ShopGUI            = player.PlayerGui:WaitForChild("ShopGUI")
		local Bloodied           = BloodGUI:WaitForChild("Bloodied")
		local corePart           = game.Workspace.Camera:WaitForChild("CorePart")
		local movingPart         = game.Workspace.Camera:WaitForChild("MovingPart")
		local lookingPart        = game.Workspace.Camera:WaitForChild("LookingPart")
		local levelUpSound       = PrimaryGUI.LevelUpSound
		HPCurrent    = PrimaryGUI.UserHealth.HPCurrent
		HPOld        = PrimaryGUI.UserHealth.HPOld
		SPCurrent    = PrimaryGUI.UserHealth.SPCurrent
		HPValue      = PrimaryGUI.UserHealth.HPValue
		hpMax        = PrimaryGUI.MaxHp.Value
		CashValue    = PrimaryGUI.Cash
		Level        = PrimaryGUI.Level
		Stamina      = PrimaryGUI.Stamina
		cashDisplay  = PrimaryGUI.CurrentMoney
		levelDisplay = PrimaryGUI.CurrentLevel
		levelUpLabel = PrimaryGUI.LevelUpLabel
		TimerLabel   = PrimaryGUI.TimerLabel
		RoundText = PrimaryGUI.CurrentRound
		
		roundChangeConnection = RoundChange.onClientEvent:Connect(function(roundNumber)
			if roundNumber == 0 then
				RoundDisplay.Text = "<i>Intermission</i>"
				roundTweenIn = TweenService:Create(RoundDisplay, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66})
				roundTweenIn:Play()
				local t = tick()
				while (tick() - t) < 2 do
					game:GetService("RunService").RenderStepped:Wait()
				end
				roundTweenOut = TweenService:Create(RoundDisplay, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1})
				roundTweenOut:Play()
			elseif roundNumber == 11 then
				RoundDisplay.Text = "<i>Map Change</i>"
				roundTweenIn = TweenService:Create(RoundDisplay, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66})
				roundTweenIn:Play()
				local t = tick()
				while (tick() - t) < 2 do
					game:GetService("RunService").RenderStepped:Wait()
				end
				roundTweenOut = TweenService:Create(RoundDisplay, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1})
				roundTweenOut:Play()
			else
				RoundDisplay.Text = "<i>Round "..roundNumber.."</i>"
				roundTweenIn = TweenService:Create(RoundDisplay, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66})
				roundTweenIn:Play()
				local t = tick()
				while (tick() - t) < 2 do
					game:GetService("RunService").RenderStepped:Wait()
				end
				roundTweenOut = TweenService:Create(RoundDisplay, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1})
				roundTweenOut:Play()
			end
		end)
		
		CashValue.Value = ReturnCash:InvokeServer()
		Level.Value     = ReturnLevel:InvokeServer()
		cashDisplay.Text = "$"..formatNumber(CashValue.Value)
		levelDisplay.Text = "LVL "..Level.Value
		cashConnection = CashValue.Changed:Connect(function()
			cashDisplay.Text = "$"..formatNumber(CashValue.Value)
		end)
		
		local t = tick()
		while (tick() - t) < 0.1 do
			game:GetService("RunService").RenderStepped:Wait()
		end
		
		if humanoid.MaxHealth > 100 then
			hpSize = 0.631
		else
			hpSize = 0.585
		end
		maxHealthConnection = humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
			if humanoid.MaxHealth > 100 then
				hpSize = 0.631
				HPValue.Text = humanoid.Health
			else
				hpSize = 0.585
			end

			maxHealthConnection:Disconnect()
		end)
		
		healthConnection = humanoid.HealthChanged:Connect(function(dif)
			-- HP At 0 will be {0,0},{0.523,0}
			-- HP At max will be {0.949,0},{0.523,0}
			local hp = humanoid.Health

			dif = dif - oldHP
			oldHP = humanoid.Health
			if dif < 0 then 
				coroutine.wrap(function()
					Bloodied.ImageTransparency = 0
					Bloodied.Visible = true
					local tween = TweenService:Create(Bloodied, TweenInfo.new(0.5), {ImageTransparency = 1})
					tween:Play()
					wait(0.5)
					Bloodied.Visible = false
				end)()
			end

			if hp ~= nil then
				if hp <= 0 then
					HPValue.Text = 0
					HPOld:TweenSize(UDim2.new(0, 0, 0.523, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.15, true)
					HPCurrent.Size = UDim2.new(0, 0, 0.523, 0)
				else
					HPValue.Text = math.floor(hp)
					HPOld:TweenSize(UDim2.new(hpSize * (hp / hpMax), 0, 0.523, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.15, true)
					HPCurrent:TweenSize(UDim2.new(hpSize * (hp / hpMax), 0, 0.523, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				end
			end
		end)
		
		staminaConnection = Stamina.Changed:Connect(function()
			-- SP At 0 will be {0,0},{0.166,,0}
			-- SP At max will be {0.948,0},{0.166,,0}
			local sp = Stamina.Value

			if sp ~= nil then
				if sp <= 0 then
					SPCurrent.Size = UDim2.new(0, 0, 0.166, 0)
				else
					SPCurrent:TweenSize(UDim2.new(0.948 * (sp / 100), 0, 0.166, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				end
			end
		end)

		levelConnection = Level.Changed:Connect(function()
			levelUpLabel.Position = UDim2.new(0.452, 0, 0.683, 0)
			levelUpSound:Play()
			local newValue = Level.Value
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
			levelDisplay.Text = "LVL "..newValue
			local fadeInTween  = TweenService:Create(levelUpLabel, tweenInfo, {TextTransparency = 0, TextStrokeTransparency = 0.66})
			fadeInTween:Play()
			local t = tick()
			while (tick() - t) < 0.5 do
				game:GetService("RunService").RenderStepped:Wait()
			end
			local guiUpTween = TweenService:Create(levelUpLabel, tweenInfo, {Position = levelUpLabel.Position + UDim2.new(0, 0, -0.05, 0)})
			local fadeOutTween  = TweenService:Create(levelUpLabel, tweenInfo, {TextTransparency = 1, TextStrokeTransparency = 1})
			fadeOutTween:Play()
			guiUpTween:Play()
		end)
		
		TimerLabel.Text = secondsToRoundTime(RoundTime.Value)
		timeChangeConnection = RoundTime:GetPropertyChangedSignal("Value"):Connect(function()
			TimerLabel.Text = secondsToRoundTime(RoundTime.Value)
		end)
		
		RoundText.Text = WorldStatus.Value
		roundTextConnection = WorldStatus:GetPropertyChangedSignal("Value"):Connect(function()
			RoundText.Text = WorldStatus.Value
		end)

		
		mapChangeConnection = LoadedMap:GetPropertyChangedSignal("Value"):Connect(function()
			mapChanging = true
			mapChangeConnection:Disconnect()
			onDeathConnection:Disconnect()
			roundChangeConnection:Disconnect()
			healthConnection:Disconnect()
			maxHealthConnection:Disconnect()
			staminaConnection:Disconnect()
			cashConnection:Disconnect()
			levelConnection:Disconnect()
			timeChangeConnection:Disconnect()
			roundTextConnection:Disconnect()
			PrimaryGUI:Destroy()
			BloodGUI:Destroy()
			WeaponSelectionGUI:Destroy()
			ShopGUI:Destroy()
			ConfirmationGUI:Destroy()
			MobileGUI:Destroy()
			WeaponGUI:Destroy()
			
			corePart:Destroy()
			movingPart:Destroy()
			lookingPart:Destroy()
		end)

		onDeathConnection = humanoid.Died:Connect(function()
			onDeathConnection:Disconnect()
			roundChangeConnection:Disconnect()
			healthConnection:Disconnect()
			maxHealthConnection:Disconnect()
			staminaConnection:Disconnect()
			cashConnection:Disconnect()
			levelConnection:Disconnect()
			timeChangeConnection:Disconnect()
			roundTextConnection:Disconnect()
			PrimaryGUI:Destroy()
			BloodGUI:Destroy()
			WeaponSelectionGUI:Destroy()
			ShopGUI:Destroy()
			ConfirmationGUI:Destroy()
			MobileGUI:Destroy()
			WeaponGUI:Destroy()
			
			
			corePart:Destroy()
			movingPart:Destroy()
			lookingPart:Destroy()

			if mapChanging == false then
				DeathScreen.Parent = player.PlayerGui
				deathEffect = DeathScreen.DeathEffect
				deathEffect.Parent = camera
				for i = 4, 0, -1 do
					if DeathScreen.RespawnTimer then
						DeathScreen.RespawnTimer.Text = "Respawning in ".. i
						local t = tick()
						while (tick() - t) < 1 do
							game:GetService("RunService").RenderStepped:Wait()
						end
					end
				end
				DeathScreen:Destroy()
				deathEffect:Destroy()
			end
		end)
	else
		RequestAll:InvokeServer("Computer")
		
		PrimaryGUI               = player.PlayerGui:WaitForChild("PrimaryGUI")
		WeaponGUI                = player.PlayerGui:WaitForChild("weaponGUI")
		local ConfirmationGUI    = player.PlayerGui:WaitForChild("ConfirmationGUI")
		local WeaponSelectionGUI = player.PlayerGui:WaitForChild("WeaponSelectionGUI")
		local RoundDisplay       = PrimaryGUI:WaitForChild("RoundDisplay")
		local BloodGUI  	     = player.PlayerGui:WaitForChild("BloodGUI")
		local ShopGUI            = player.PlayerGui:WaitForChild("ShopGUI")
		local Bloodied           = BloodGUI:WaitForChild("Bloodied")
		local levelUpSound       = PrimaryGUI.LevelUpSound
		HPCurrent    = PrimaryGUI.UserHealth.HPCurrent
		HPOld        = PrimaryGUI.UserHealth.HPOld
		SPCurrent    = PrimaryGUI.UserHealth.SPCurrent
		HPValue      = PrimaryGUI.UserHealth.HPValue
		hpMax        = PrimaryGUI.MaxHp.Value
		CashValue    = PrimaryGUI.Cash
		Level        = PrimaryGUI.Level
		Stamina      = PrimaryGUI.Stamina
		cashDisplay  = PrimaryGUI.CurrentMoney
		levelDisplay = PrimaryGUI.CurrentLevel
		levelUpLabel = PrimaryGUI.LevelUpLabel
		TimerLabel   = PrimaryGUI.TimerLabel
		RoundText = PrimaryGUI.CurrentRound
		
		roundChangeConnection = RoundChange.onClientEvent:Connect(function(roundNumber)
			if roundNumber == 0 then
				RoundDisplay.Text = "<i>Intermission</i>"
				roundTweenIn = TweenService:Create(RoundDisplay, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66})
				roundTweenIn:Play()
				local t = tick()
				while (tick() - t) < 2 do
					game:GetService("RunService").RenderStepped:Wait()
				end
				roundTweenOut = TweenService:Create(RoundDisplay, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1})
				roundTweenOut:Play()
			elseif roundNumber == 11 then
				RoundDisplay.Text = "<i>Map Change</i>"
				roundTweenIn = TweenService:Create(RoundDisplay, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66})
				roundTweenIn:Play()
				local t = tick()
				while (tick() - t) < 2 do
					game:GetService("RunService").RenderStepped:Wait()
				end
				roundTweenOut = TweenService:Create(RoundDisplay, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1})
				roundTweenOut:Play()
			else
				RoundDisplay.Text = "<i>Round "..roundNumber.."</i>"
				roundTweenIn = TweenService:Create(RoundDisplay, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.66})
				roundTweenIn:Play()
				local t = tick()
				while (tick() - t) < 2 do
					game:GetService("RunService").RenderStepped:Wait()
				end
				roundTweenOut = TweenService:Create(RoundDisplay, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1})
				roundTweenOut:Play()
			end
		end)

		CashValue.Value = ReturnCash:InvokeServer()
		Level.Value     = ReturnLevel:InvokeServer()
		cashDisplay.Text = "$"..formatNumber(CashValue.Value)
		levelDisplay.Text = "LVL "..Level.Value
		cashConnection = CashValue.Changed:Connect(function()
			cashDisplay.Text = "$"..formatNumber(CashValue.Value)
		end)
		
		if humanoid.MaxHealth > 100 then
			hpSize = 0.585
		else
			hpSize = 0.876
		end

		maxHealthConnection = humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
			if humanoid.MaxHealth > 100 then
				hpSize = 0.585
				HPValue.Text = humanoid.Health
			else
				hpSize = 0.876
			end

			maxHealthConnection:Disconnect()
		end)

		healthConnection = humanoid.HealthChanged:Connect(function(dif)
			-- HP At 0 will be {0,0},{0.49,0}
			-- HP At max will be {0.876,0},{0.49,0}z
			local hp = humanoid.Health

			dif = dif - oldHP
			oldHP = humanoid.Health
			if dif < 0 then 
				coroutine.wrap(function()
					Bloodied.ImageTransparency = 0
					Bloodied.Visible = true
					local tween = TweenService:Create(Bloodied, TweenInfo.new(0.5), {ImageTransparency = 1})
					tween:Play()
					wait(0.5)
					Bloodied.Visible = false
				end)()
			end

			if hp ~= nil then
				if hp <= 0 then
					HPValue.Text = 0
					HPOld:TweenSize(UDim2.new(0, 0, 0.49, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.15, true)
					HPCurrent.Size = UDim2.new(0, 0, 0.49, 0)
				else
					HPValue.Text = math.floor(hp)
					HPOld:TweenSize(UDim2.new(hpSize * (hp / hpMax), 0, 0.49, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.15, true)
					HPCurrent:TweenSize(UDim2.new(hpSize * (hp / hpMax), 0, 0.49, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				end
			end
		end)

		staminaConnection = Stamina.Changed:Connect(function()
			-- SP At 0 will be {0,0},{0.156,,0}
			-- SP At max will be {0.876,0},{0.156,,0}
			local sp = Stamina.Value

			if sp ~= nil then
				if sp <= 0 then
					SPCurrent.Size = UDim2.new(0, 0, 0.156, 0)
				else
					SPCurrent:TweenSize(UDim2.new(0.876 * (sp / 100), 0, 0.156, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				end
			end
		end)

		levelConnection = Level.Changed:Connect(function()
			levelUpLabel.Position = UDim2.new(0.113, 0, 0.765, 0)
			levelUpSound:Play()
			local newValue = Level.Value
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
			levelDisplay.Text = "LVL "..newValue
			local fadeInTween  = TweenService:Create(levelUpLabel, tweenInfo, {TextTransparency = 0, TextStrokeTransparency = 0.66})
			fadeInTween:Play()
			local t = tick()
			while (tick() - t) < 0.5 do
				game:GetService("RunService").RenderStepped:Wait()
			end
			local guiUpTween = TweenService:Create(levelUpLabel, tweenInfo, {Position = levelUpLabel.Position + UDim2.new(0, 0, -0.05, 0)})
			local fadeOutTween  = TweenService:Create(levelUpLabel, tweenInfo, {TextTransparency = 1, TextStrokeTransparency = 1})
			fadeOutTween:Play()
			guiUpTween:Play()
		end)
		
		TimerLabel.Text = secondsToRoundTime(RoundTime.Value)
		timeChangeConnection = RoundTime:GetPropertyChangedSignal("Value"):Connect(function()
			TimerLabel.Text = secondsToRoundTime(RoundTime.Value)
		end)

		RoundText.Text = WorldStatus.Value
		roundTextConnection = WorldStatus:GetPropertyChangedSignal("Value"):Connect(function()
			RoundText.Text = WorldStatus.Value
		end)
		
		mapChangeConnection = LoadedMap:GetPropertyChangedSignal("Value"):Connect(function()
			mapChanging = true
			mapChangeConnection:Disconnect()
			onDeathConnection:Disconnect()
			roundChangeConnection:Disconnect()
			healthConnection:Disconnect()
			maxHealthConnection:Disconnect()
			staminaConnection:Disconnect()
			cashConnection:Disconnect()
			levelConnection:Disconnect()
			timeChangeConnection:Disconnect()
			roundTextConnection:Disconnect()
			PrimaryGUI:Destroy()
			BloodGUI:Destroy()
			WeaponSelectionGUI:Destroy()
			ShopGUI:Destroy()
			ConfirmationGUI:Destroy()
			WeaponGUI:Destroy()
		end)

		onDeathConnection = humanoid.Died:Connect(function()
			onDeathConnection:Disconnect()
			roundChangeConnection:Disconnect()
			healthConnection:Disconnect()
			maxHealthConnection:Disconnect()
			staminaConnection:Disconnect()
			cashConnection:Disconnect()
			levelConnection:Disconnect()
			timeChangeConnection:Disconnect()
			roundTextConnection:Disconnect()
			PrimaryGUI:Destroy()
			BloodGUI:Destroy()
			WeaponSelectionGUI:Destroy()
			ShopGUI:Destroy()
			ConfirmationGUI:Destroy()
			WeaponGUI:Destroy()
			
			if mapChanging == false then
				DeathScreen.Parent = player.PlayerGui
				deathEffect = DeathScreen.DeathEffect
				deathEffect.Parent = camera
				for i = 4, 0, -1 do
					if DeathScreen.RespawnTimer then
						DeathScreen.RespawnTimer.Text = "Respawning in ".. i
						local t = tick()
						while (tick() - t) < 1 do
							game:GetService("RunService").RenderStepped:Wait()
						end
					end
				end
				DeathScreen:Destroy()
				deathEffect:Destroy()
			end
		end)
	end
end

--------------------
-- Function Calls --
--------------------
newCharacter = player.Character
onPlayerSpawn()

-----------------------------
--    Connect Functions    --
-----------------------------
player.CharacterAdded:Connect(function(character) -- Detects player respawn and refreshes variables.
	newCharacter = character
	onPlayerSpawn()
end)