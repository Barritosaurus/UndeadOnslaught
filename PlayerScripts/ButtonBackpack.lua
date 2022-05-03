-----------
-- Yield --
-----------
repeat wait() until game.Players.LocalPlayer.Character

--------------------------
-- Variable Declaration -- 
--------------------------
local player     = game:GetService("Players").LocalPlayer
local contextActionService = game:GetService("ContextActionService")
local character  = player.Character
local humanoid   = character:WaitForChild("Humanoid")
local GuiObject  = script.Parent
local mouse      = player:GetMouse()
local PrimaryGUI = player.PlayerGui:WaitForChild("PrimaryGUI")
local ShopGUI    = player.PlayerGui:WaitForChild("ShopGUI")
local textlabel  = PrimaryGUI.MouseOverLabel
local MenuOpen   = PrimaryGUI.MenuOpen

-----------------
-- Connections --
-----------------
local guiConnection     = nil
local onDeathConnection = nil


--------------
-- On Death --
--------------
onDeathConnection = humanoid.Died:Connect(function()
	ShopGUI.Enabled = false
	MenuOpen.Value  = false
	contextActionService:UnbindAction("InventoryButton")
	guiConnection:Disconnect()
	onDeathConnection:Disconnect()
end)

----------------
-- Gui Events --
----------------
local function toggleMenu()
	if ShopGUI.Enabled == true then
		ShopGUI.Enabled = false
		MenuOpen.Value  = false
	else
		ShopGUI.Enabled = true
		MenuOpen.Value  = true
	end
end

function onInventory(actionName, inputState)
	if inputState == Enum.UserInputState.Begin then
		toggleMenu()
	end
end

contextActionService:BindActionAtPriority("InventoryButton", onInventory, true, 200, Enum.KeyCode.B)
guiConnection = GuiObject.MouseButton1Click:Connect(function()
	toggleMenu()
end)