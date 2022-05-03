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
local t = tick()
while (tick() - t) < 0.5 do
	game:GetService("RunService").RenderStepped:Wait()
end

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
local MobileGUI          = nil

-------------------
-- Client Values --
-------------------
local mouse            = nil
local userData         = nil
local character        = nil
local primaryWeapon    = nil
local secondaryWeapon  = nil
local currentPrimary   = nil
local currentSecondary = nil
local primaryTool      = nil
local secondaryTool    = nil

-----------------
-- Connections --
-----------------
local mouseUpConnection         = nil
local mouseDownConnection       = nil
local primaryWeaponConnection   = nil
local secondaryWeaponConnection = nil
local humanoidDeathConnection   = nil
local mapChangeConnection       = nil

------------
-- Events --
------------
local LoadedMap = ReplicatedStorage.ServerValues:WaitForChild("LoadedMap")

--------------
-- Function --
--------------
local function onPlayerSpawn(character)
	userData           = GetUserData:InvokeServer()
	humanoid           = character:WaitForChild("Humanoid")
	PrimaryGUI         = player.PlayerGui:WaitForChild("PrimaryGUI")
	MobileGUI          = player.PlayerGui:FindFirstChild("MobileControlGUI")
	WeaponSelectionGUI = player.PlayerGui:WaitForChild("WeaponSelectionGUI")
	primaryWeapon      = WeaponSelectionGUI:WaitForChild("PrimaryWeapon")
	secondaryWeapon    = WeaponSelectionGUI:WaitForChild("SecondaryWeapon")
	currentPrimary     = WeaponSelectionGUI:WaitForChild("CurrentPrimary")
	currentSecondary   = WeaponSelectionGUI:WaitForChild("CurrentSecondary")
	mouse              = player:GetMouse()
	mouse.Icon         = "rbxassetid://6953466411"
	currentPrimary.Value   = userData.PrimaryWeapon
	currentSecondary.Value = userData.SecondaryWeapon
	primaryWeapon.WeaponName.Text   = currentPrimary.Value
	secondaryWeapon.WeaponName.Text = currentSecondary.Value
	
	if MobileGUI then
		----------------------------
		-- Intiial Equip of Tools --
		----------------------------
		local button1      = WeaponSelectionGUI:WaitForChild("PrimaryWeapon")
		local button2      = WeaponSelectionGUI:WaitForChild("SecondaryWeapon")
		primaryTool        = player.Backpack:WaitForChild(currentPrimary.Value)
		secondaryTool      = player.Backpack:WaitForChild(currentSecondary.Value)
		humanoid:EquipTool(primaryTool)
		primaryWeapon:TweenPosition(UDim2.new(0.829, 0, 0.301, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		primaryWeapon:TweenSize(UDim2.new(0.152, 0, 0.089, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		secondaryWeapon:TweenPosition(UDim2.new(0.869, 0, 0.401, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		secondaryWeapon:TweenSize(UDim2.new(0.110, 0, 0.080, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		
		---------------------------------------------
		-- Events to fire after player is spawned. --
		---------------------------------------------
		primaryWeaponConnection = currentPrimary:GetPropertyChangedSignal("Value"):Connect(function()
			humanoid:UnequipTools()
			primaryWeapon.WeaponName.Text = currentPrimary.Value
			primaryTool = player.Backpack[currentPrimary.Value]
			humanoid:EquipTool(primaryTool)
			primaryWeapon:TweenPosition(UDim2.new(0.829, 0, 0.301, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			primaryWeapon:TweenSize(UDim2.new(0.152, 0, 0.089, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenPosition(UDim2.new(0.869, 0, 0.401, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenSize(UDim2.new(0.110, 0, 0.070, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		end)

		secondaryWeaponConnection = currentSecondary:GetPropertyChangedSignal("Value"):Connect(function()
			humanoid:UnequipTools()
			secondaryWeapon.WeaponName.Text = currentSecondary.Value
			secondaryTool = player.Backpack[currentSecondary.Value]
			humanoid:EquipTool(secondaryTool)
			primaryWeapon:TweenPosition(UDim2.new(0.869, 0, 0.301, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			primaryWeapon:TweenSize(UDim2.new(0.110, 0, 0.080, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenPosition(UDim2.new(0.829, 0, 0.401, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenSize(UDim2.new(0.152, 0, 0.089, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		end)
		
		----------------------
		-- Weapon Selection --
		----------------------
		local currentWeapon = 1
		mouseUpConnection = button1.InputBegan:Connect(function()
			if currentWeapon < 2 and not CollectionService:HasTag(character, "Downed") then
				-- Nothing
			elseif not CollectionService:HasTag(character, "Downed") then
				currentWeapon = 1
			end

			if currentWeapon == 1 and not CollectionService:HasTag(character, "Downed") then
				humanoid:EquipTool(primaryTool)
				primaryWeapon:TweenPosition(UDim2.new(0.829, 0, 0.301, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				primaryWeapon:TweenSize(UDim2.new(0.152, 0, 0.089, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenPosition(UDim2.new(0.869, 0, 0.401, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenSize(UDim2.new(0.110, 0, 0.070, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			elseif not CollectionService:HasTag(character, "Downed") then
				humanoid:EquipTool(secondaryTool)
				primaryWeapon:TweenPosition(UDim2.new(0.869, 0, 0.301, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				primaryWeapon:TweenSize(UDim2.new(0.110, 0, 0.080, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenPosition(UDim2.new(0.829, 0, 0.401, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenSize(UDim2.new(0.152, 0, 0.089, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			end
		end)
		mouseDownConnection = button2.InputBegan:Connect(function()
			if currentWeapon > 1 and not CollectionService:HasTag(character, "Downed") then
				-- Nothing
			elseif not CollectionService:HasTag(character, "Downed") then
				currentWeapon = 2
			end

			if currentWeapon == 1 and not CollectionService:HasTag(character, "Downed") then
				humanoid:EquipTool(primaryTool)
				primaryWeapon:TweenPosition(UDim2.new(0.829, 0, 0.301, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				primaryWeapon:TweenSize(UDim2.new(0.152, 0, 0.089, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenPosition(UDim2.new(0.869, 0, 0.401, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenSize(UDim2.new(0.110, 0, 0.070, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			elseif not CollectionService:HasTag(character, "Downed") then
				humanoid:EquipTool(secondaryTool)
				primaryWeapon:TweenPosition(UDim2.new(0.869, 0, 0.301, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				primaryWeapon:TweenSize(UDim2.new(0.110, 0, 0.080, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenPosition(UDim2.new(0.829, 0, 0.401, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenSize(UDim2.new(0.152, 0, 0.089, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			end
		end)

		local function equipPrimary()
			humanoid:EquipTool(primaryTool)
			primaryWeapon:TweenPosition(UDim2.new(0.829, 0, 0.301, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			primaryWeapon:TweenSize(UDim2.new(0.152, 0, 0.089, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenPosition(UDim2.new(0.869, 0, 0.401, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenSize(UDim2.new(0.110, 0, 0.070, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		end

		local function equipSecondary()
			humanoid:EquipTool(secondaryTool)
			primaryWeapon:TweenPosition(UDim2.new(0.869, 0, 0.301, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			primaryWeapon:TweenSize(UDim2.new(0.110, 0, 0.080, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenPosition(UDim2.new(0.829, 0, 0.401, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenSize(UDim2.new(0.152, 0, 0.089, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		end
		
		mapChangeConnection = LoadedMap:GetPropertyChangedSignal("Value"):Connect(function()
			contextActionService:UnbindAction("PrimarySwap")
			contextActionService:UnbindAction("SecondarySwap")
			mouseUpConnection:Disconnect()
			mouseDownConnection:Disconnect()
			mapChangeConnection:Disconnect()
			humanoidDeathConnection:Disconnect()
			primaryWeaponConnection:Disconnect()
			secondaryWeaponConnection:Disconnect()
			primaryTool = nil
			secondaryTool = nil
		end)

		humanoidDeathConnection = humanoid.Died:Connect(function()
			mapChangeConnection:Disconnect()
			humanoidDeathConnection:Disconnect()
			primaryWeaponConnection:Disconnect()
			secondaryWeaponConnection:Disconnect()
			mouseUpConnection:Disconnect()
			mouseDownConnection:Disconnect()
			primaryTool = nil
			secondaryTool = nil
		end)
		
	else
		
		----------------------------
		-- Intiial Equip of Tools --
		----------------------------
		primaryTool        = player.Backpack:WaitForChild(currentPrimary.Value)
		secondaryTool      = player.Backpack:WaitForChild(currentSecondary.Value)
		humanoid:EquipTool(primaryTool)
		primaryWeapon:TweenPosition(UDim2.new(0.882, 0, 0.716, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		primaryWeapon:TweenSize(UDim2.new(0.108, 0, 0.07, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		secondaryWeapon:TweenPosition(UDim2.new(0.930, 0, 0.800, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		secondaryWeapon:TweenSize(UDim2.new(0.064, 0, 0.035, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)

		---------------------------------------------
		-- Events to fire after player is spawned. --
		---------------------------------------------
		primaryWeaponConnection = currentPrimary:GetPropertyChangedSignal("Value"):Connect(function()
			humanoid:UnequipTools()
			primaryWeapon.WeaponName.Text = currentPrimary.Value
			primaryTool = player.Backpack[currentPrimary.Value]
			humanoid:EquipTool(primaryTool)
			primaryWeapon:TweenPosition(UDim2.new(0.882, 0, 0.716, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			primaryWeapon:TweenSize(UDim2.new(0.108, 0, 0.07, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenPosition(UDim2.new(0.930, 0, 0.800, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenSize(UDim2.new(0.064, 0, 0.035, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		end)

		secondaryWeaponConnection = currentSecondary:GetPropertyChangedSignal("Value"):Connect(function()
			humanoid:UnequipTools()
			secondaryWeapon.WeaponName.Text = currentSecondary.Value
			secondaryTool      = player.Backpack[currentSecondary.Value]
			humanoid:EquipTool(secondaryTool)
			humanoid:EquipTool(secondaryTool)
			primaryWeapon:TweenPosition(UDim2.new(0.930, 0, 0.750, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			primaryWeapon:TweenSize(UDim2.new(0.064, 0, 0.035, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenPosition(UDim2.new(0.882, 0, 0.796, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenSize(UDim2.new(0.108, 0, 0.07, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		end)

		----------------------
		-- Weapon Selection --
		----------------------
		local currentWeapon = 1
		mouseUpConnection = Mouse.WheelForward:Connect(function()
			if currentWeapon < 2 and not CollectionService:HasTag(character, "Downed") then
				currentWeapon = currentWeapon + 1
			elseif not CollectionService:HasTag(character, "Downed") then
				currentWeapon = 1
			end

			if currentWeapon == 1 and not CollectionService:HasTag(character, "Downed") then
				humanoid:EquipTool(primaryTool)
				primaryWeapon:TweenPosition(UDim2.new(0.882, 0, 0.716, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				primaryWeapon:TweenSize(UDim2.new(0.108, 0, 0.07, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenPosition(UDim2.new(0.930, 0, 0.800, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenSize(UDim2.new(0.064, 0, 0.035, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			elseif not CollectionService:HasTag(character, "Downed") then
				humanoid:EquipTool(secondaryTool)
				primaryWeapon:TweenPosition(UDim2.new(0.930, 0, 0.750, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				primaryWeapon:TweenSize(UDim2.new(0.064, 0, 0.035, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenPosition(UDim2.new(0.882, 0, 0.796, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenSize(UDim2.new(0.108, 0, 0.07, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			end
		end)
		mouseDownConnection = Mouse.WheelBackward:Connect(function()
			if currentWeapon > 1 and not CollectionService:HasTag(character, "Downed") then
				currentWeapon = currentWeapon - 1
			elseif not CollectionService:HasTag(character, "Downed") then
				currentWeapon = 2
			end

			if currentWeapon == 1 and not CollectionService:HasTag(character, "Downed") then
				humanoid:EquipTool(primaryTool)
				primaryWeapon:TweenPosition(UDim2.new(0.882, 0, 0.716, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				primaryWeapon:TweenSize(UDim2.new(0.108, 0, 0.07, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenPosition(UDim2.new(0.930, 0, 0.800, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenSize(UDim2.new(0.064, 0, 0.035, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			elseif not CollectionService:HasTag(character, "Downed") then
				humanoid:EquipTool(secondaryTool)
				primaryWeapon:TweenPosition(UDim2.new(0.930, 0, 0.750, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				primaryWeapon:TweenSize(UDim2.new(0.064, 0, 0.035, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenPosition(UDim2.new(0.882, 0, 0.796, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
				secondaryWeapon:TweenSize(UDim2.new(0.108, 0, 0.07, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			end
		end)

		local function equipPrimary()
			humanoid:EquipTool(primaryTool)
			primaryWeapon:TweenPosition(UDim2.new(0.882, 0, 0.716, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			primaryWeapon:TweenSize(UDim2.new(0.108, 0, 0.07, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenPosition(UDim2.new(0.930, 0, 0.800, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenSize(UDim2.new(0.064, 0, 0.035, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		end

		local function equipSecondary()
			humanoid:EquipTool(secondaryTool)
			primaryWeapon:TweenPosition(UDim2.new(0.930, 0, 0.750, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			primaryWeapon:TweenSize(UDim2.new(0.064, 0, 0.035, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenPosition(UDim2.new(0.882, 0, 0.796, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
			secondaryWeapon:TweenSize(UDim2.new(0.108, 0, 0.07, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
		end

		contextActionService:BindActionAtPriority("PrimarySwap", equipPrimary, true, 200, Enum.KeyCode.One)
		contextActionService:BindActionAtPriority("SecondarySwap", equipSecondary, true, 200, Enum.KeyCode.Two)

		mapChangeConnection = LoadedMap:GetPropertyChangedSignal("Value"):Connect(function()
			contextActionService:UnbindAction("PrimarySwap")
			contextActionService:UnbindAction("SecondarySwap")
			mouseUpConnection:Disconnect()
			mouseDownConnection:Disconnect()
			mapChangeConnection:Disconnect()
			humanoidDeathConnection:Disconnect()
			primaryWeaponConnection:Disconnect()
			secondaryWeaponConnection:Disconnect()
			primaryTool = nil
			secondaryTool = nil
		end)

		humanoidDeathConnection = humanoid.Died:Connect(function()
			mapChangeConnection:Disconnect()
			humanoidDeathConnection:Disconnect()
			primaryWeaponConnection:Disconnect()
			secondaryWeaponConnection:Disconnect()
			mouseUpConnection:Disconnect()
			mouseDownConnection:Disconnect()
			contextActionService:UnbindAction("PrimarySwap")
			contextActionService:UnbindAction("SecondarySwap")
			primaryTool = nil
			secondaryTool = nil
		end)
	end
end

-----------------------------
--    Connect Functions    --
-----------------------------
player.CharacterAdded:Connect(function(character) -- Detects player respawn and refreshes variables.
	onPlayerSpawn(character)
end)
