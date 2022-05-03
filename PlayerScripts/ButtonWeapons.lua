------------------------------------
-- This code opens the weapon tab --
------------------------------------

-----------
-- Yield --
-----------
repeat wait() until game.Players.LocalPlayer.Character

--------------------------
-- Variable Declaration -- 
--------------------------
local player        = game:GetService("Players").LocalPlayer
local character     = player.Character
local humanoid      = character:WaitForChild("Humanoid")
local GuiObject     = script.Parent
local mouse         = player:GetMouse()
local ShopGUI       = player.PlayerGui.ShopGUI
local WeaponMenu    = ShopGUI:WaitForChild("WeaponMenu")
local SettingsMenu  = ShopGUI:WaitForChild("SettingsMenu")
local PowerupMenu   = ShopGUI:WaitForChild("PowerupMenu")
local WeaponDisplay = ShopGUI:WaitForChild("WeaponDisplay")

-----------------
-- Connections --
-----------------
local guiConnection     = nil
local onDeathConnection = nil
local clickConnection   = nil


--------------
-- On Death --
--------------
onDeathConnection = humanoid.Died:Connect(function()
	guiConnection:Disconnect()
	hoverConnection:Disconnect()
	onDeathConnection:Disconnect()
	clickConnection:Disconnect()
end)

----------------
-- Gui Events --
----------------
guiConnection = GuiObject.MouseButton1Click:Connect(function()
	PowerupMenu.Visible = false
	WeaponMenu.Visible = true
	WeaponDisplay.Visible = true
	SettingsMenu.Visible = false
end)

local pingSound = ShopGUI:WaitForChild("ItemHover")
local clickSound = ShopGUI:WaitForChild("ItemClick")
hoverConnection = GuiObject.MouseEnter:Connect(function()
	pingSound:Play()
end)
clickConnection = GuiObject.MouseButton1Click:Connect(function()
	clickSound:Play()
end)