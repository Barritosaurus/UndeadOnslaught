-----------
-- Yield --
-----------

--------------------------
-- Variable Declaration -- 
--------------------------
local player        = game:GetService("Players").LocalPlayer
local GuiObject     = script.Parent
local mouse         = player:GetMouse()
local LoadingScreenGUI = player.PlayerGui:WaitForChild("LoadingScreenGUI")

-----------------
-- Connections --
-----------------
local guiConnection     = nil
local onDeathConnection = nil
local clickConnection   = nil

--------------
-- On Death --
--------------
local pingSound = LoadingScreenGUI:WaitForChild("ItemHover")
local clickSound = LoadingScreenGUI:WaitForChild("ItemClick")
hoverConnection = GuiObject.MouseEnter:Connect(function()
	pingSound:Play()
end)
clickConnection = GuiObject.MouseButton1Click:Connect(function()
	clickSound:Play()
	clickConnection:Disconnect()
	hoverConnection:Disconnect()
end)