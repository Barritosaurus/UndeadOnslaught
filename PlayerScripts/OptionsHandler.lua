-------------------------
-- Service Declaration --
-------------------------
local ReplicatedStorage    = game:GetService("ReplicatedStorage")
local MarketplaceService   = game:GetService("MarketplaceService")
local contextActionService = game:GetService("ContextActionService")
local UserInputService     = game:GetService("UserInputService")
local CollectionService    = game:GetService("CollectionService")
local GetUserData          = ReplicatedStorage.ServerEvents:WaitForChild("GetUserData")
local player               = game:GetService("Players").LocalPlayer
local playerID             = player.UserId
local Mouse 			   = player:GetMouse()
local humanoid             = nil

---------------
-- Variables --
---------------
local PrimaryGUI         = nil
local WeaponSelectionGUI = nil

-------------------
-- Client Values --
-------------------
local userData         = nil
local character        = nil

-----------------
-- Connections --
-----------------
local Option1Connection = nil
local Option2Connection = nil
local Option3Connection = nil
local Option4Connection = nil
local Option5Connection = nil
local humanoidDeathConnection = nil

------------
-- Events --
------------
local SetOption = ReplicatedStorage.ServerEvents:WaitForChild("SetOption")

--------------
-- Function --
--------------
local function onPlayerSpawn()
	local t = tick()
	while (tick() - t) < 0.5 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	repeat wait() until player.Character
	userData       = GetUserData:InvokeServer()
	character      = player.Character
	humanoid       = character:WaitForChild("Humanoid")
	local ShopGUI  = player.PlayerGui:WaitForChild("ShopGUI")
	local Settings = ShopGUI:WaitForChild("SettingsMenu")
	local Option1  = Settings:WaitForChild("Option1Button").State
	local Option2  = Settings:WaitForChild("Option2Button").State
	local Option3  = Settings:WaitForChild("Option3Button").State
	local Option4  = Settings:WaitForChild("Option4Button").State
	local Option5  = Settings:WaitForChild("Option5Button").State
	
	-- Initial Setting of Options --
	Option1.Value = userData.Option1
	Option2.Value = userData.Option2
	Option3.Value = userData.Option3
	Option4.Value = userData.Option4
	Option5.Value = userData.Option5
	
	-- State Changes --
	Option1Connection = Option1:GetPropertyChangedSignal("Value"):Connect(function() -- Music Control
		if Option1.Value == true then
			
		else
			
		end
		
		SetOption:FireServer(1, Option1.Value)
	end)
	Option2Connection = Option2:GetPropertyChangedSignal("Value"):Connect(function() -- Tint Control
		if Option1.Value == true then
			
		else
			
		end
		
		SetOption:FireServer(2, Option2.Value)
	end)
	Option3Connection = Option3:GetPropertyChangedSignal("Value"):Connect(function() -- N/A For now.
		
		SetOption:FireServer(3, Option3.Value)
	end)
	Option4Connection = Option4:GetPropertyChangedSignal("Value"):Connect(function() -- N/A For now.
		
		SetOption:FireServer(4, Option4.Value)
	end)
	Option5Connection = Option5:GetPropertyChangedSignal("Value"):Connect(function() -- N/A For now.
		
		SetOption:FireServer(5, Option5.Value)
	end)
	
	humanoidDeathConnection = humanoid.Died:Connect(function()
		humanoidDeathConnection:Disconnect()
		Option1Connection:Disconnect()
		Option2Connection:Disconnect()
		Option3Connection:Disconnect()
		Option4Connection:Disconnect()
		Option5Connection:Disconnect()
	end)
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
