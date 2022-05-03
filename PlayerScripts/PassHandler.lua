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
local MarketplaceService   = game:GetService("MarketplaceService")
local ReplicatedStorage    = game:GetService("ReplicatedStorage")
local SetSpeed 			   = ReplicatedStorage.ServerEvents:WaitForChild("SetSpeed")
local SetHealth            = ReplicatedStorage.ServerEvents:WaitForChild("SetHealth")
local contextActionService = game:GetService("ContextActionService")
local userInputService     = game:GetService("UserInputService")
local player               = game:GetService("Players").LocalPlayer
local playerID             = player.UserId
local humanoid             = nil

---------------
-- Variables --
---------------
local InRound           = replicatedStorage.ServerValues.InRound
local WorldStatus       = replicatedStorage.ServerValues.WorldStatus
local SpeedBoostID      = 17719860
local HPBoostID         = 17719918
local MoneyMultiplierID = 17719867
local SpeedBoost        = false
local HPBoost           = false
local MoneyMultiplier   = false
local PrimaryGUI        = nil

-------------------
-- Client Values --
-------------------
local hpMax      = nil
local multiplier = nil

--------------
-- Function --
--------------
local function onPlayerSpawn()
	repeat wait() until player.Character
	PrimaryGUI = player.PlayerGui:WaitForChild("PrimaryGUI")
	hpMax      = PrimaryGUI.MaxHp
	multiplier = PrimaryGUI.CashMultiplier
	humanoid   = player.Character:WaitForChild("Humanoid")
	
	local t = tick()
	while (tick() - t) < 1 do
		game:GetService("RunService").Heartbeat:Wait()
	end
	
	if MarketplaceService:UserOwnsGamePassAsync(player.UserId, SpeedBoostID) or MarketplaceService:UserOwnsGamePassAsync(player.UserId, 15550067) then
		coroutine.wrap(function()
			SetSpeed:FireServer(true)
		end)()
	end
	
	if MarketplaceService:UserOwnsGamePassAsync(player.UserId, HPBoostID) or MarketplaceService:UserOwnsGamePassAsync(player.UserId, 15550067) then
		coroutine.wrap(function()
			SetHealth:FireServer(true)
		end)()
	end
	
	if MarketplaceService:UserOwnsGamePassAsync(player.UserId, MoneyMultiplierID) or MarketplaceService:UserOwnsGamePassAsync(player.UserId, 15550067) then
		multiplier.Value = 1.5
	end
end

--------------------
-- Function Calls --
--------------------
onPlayerSpawn()

-----------------------------
--    Connect Functions    --
-----------------------------
player.CharacterAdded:Connect(function(character) -- Detects player respawn and refreshes variables.
	onPlayerSpawn()
end)