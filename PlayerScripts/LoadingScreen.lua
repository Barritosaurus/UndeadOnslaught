--------------
-- Services --
--------------
local Players           = game:GetService("Players")
local ReplicatedFirst   = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local userInputService  = game:GetService("UserInputService")
local GuiService        = game:GetService("GuiService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local player 		    = Players.LocalPlayer 
local playerGui         = player:WaitForChild("PlayerGui")

---------------
-- Variables --
---------------
local loadingProgress = 0
local loadingComplete = false

------------------
-- GUI Elements --
------------------
local LoadingGUI 	 = ReplicatedFirst:WaitForChild("LoadingScreenGUI")
local PrimaryGUI     = ReplicatedFirst:WaitForChild("PrimaryGUI")
LoadingGUI.Parent    = playerGui
PrimaryGUI.Parent    = playerGui
local Background 	 = LoadingGUI.Background
local Gradient       = LoadingGUI.Gradient
local SpawnButton 	 = LoadingGUI.SpawnButton
local LoadingCurrent = LoadingGUI.LoadingCurrent
local LoadingEmpty   = LoadingGUI.LoadingEmpty
local LogoClean      = LoadingGUI.LogoClean
local LogoBloody     = LoadingGUI.LogoBloody
local MenuSound      = LoadingGUI.Music
local TipLabel       = LoadingGUI.TipLabel

-------------------
-- Functionality --
-------------------
ReplicatedFirst:RemoveDefaultLoadingScreen()
if userInputService:GetLastInputType() == Enum.UserInputType.Touch then -- Best way of determining user touchscreen, it only works if touchscreen is enabled, add a player option to disable this.
	TipLabel.Text = "Tip : Sprint and reload using the buttons above the joysticks!"
	TipLabel.Size = UDim2.new(0.248, 0, 0.036, 0)
	print("User is on mobile, if this incorrect please report this bug to the developer.")
end

-----------------
-- Intial Load --
-----------------
for loadingProgress = 1, 100 do
	if loadingComplete == true then
		LoadingCurrent.Size = UDim2.new(0.287, 0, 0.07, 0)
	else
		LoadingCurrent:TweenSize(UDim2.new(0.287 * (loadingProgress / 100), 0, 0.07, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.05, true)
	end
	wait(0.01)
end

------------
-- Events --
------------
local SpawnEvent = ReplicatedStorage.ServerEvents:WaitForChild("SpawnEvent")
local LoadedMap  = ReplicatedStorage.ServerValues:WaitForChild("LoadedMap")

-----------------
-- Connections --
-----------------
local center = game.Workspace.MapObjects.CurrentMap.NoTarget.CameraCenter
local c      = 0
local target = center.CFrame * CFrame.Angles(0, math.rad(c), 0) * CFrame.new(0, 0, -10) 
local onMapChangeConnection
onMapChangeConnection = LoadedMap:GetPropertyChangedSignal("Value"):Connect(function()
	local t = tick()
	while (tick() - t) < 3 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	center = game.Workspace.MapObjects.CurrentMap.NoTarget:WaitForChild("CameraCenter")
	target = center.CFrame * CFrame.Angles(0, math.rad(c), 0) * CFrame.new(0, 0, -10) 
end)

----------------
-- Camera Pan --
----------------
local function onPlayerJoin()
	local t = tick()
	while (tick() - t) < 0.2 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	RunService:UnbindFromRenderStep("Camera")
	local char           = player.Character 
	local camera         = game.Workspace.Camera
	local fov            = 90
	camera.CameraType    = "Custom"
	local function onRenderStep()
		target = center.CFrame * CFrame.Angles(0, math.rad(c), 0) * CFrame.new(0, 0, -10) 
		target = CFrame.new(target.p, center.Position)
		camera.CFrame = target

		c = c + 0.1;
	end

	RunService:BindToRenderStep("Camera", 201, onRenderStep)
end
onPlayerJoin()

if not game:IsLoaded() then
	game.Loaded:Wait()
end

MenuSound:Play()

coroutine.wrap(function()
	for i = 0, 50 do
		MenuSound.Volume = MenuSound.Volume + 0.0025
		wait(0.01)
	end
end)()

loadingComplete = true
local backgroundTween = TweenService:Create(Background, TweenInfo.new(0.3), {ImageTransparency = 1})
backgroundTween:Play()
LoadingEmpty.ImageTransparency = 1
LoadingCurrent:TweenSize(UDim2.new(0.108, 0, 0.082, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.5, true)
LoadingCurrent:TweenPosition(UDim2.new(0.445, 0, 0.656, 0), Enum.EasingDirection.InOut,  Enum.EasingStyle.Linear, 0.5, true)
local t = tick()
while (tick() - t) < 0.5 do
	game:GetService("RunService").RenderStepped:Wait()
end
local buttonTween = TweenService:Create(LoadingCurrent, TweenInfo.new(0.2), {ImageTransparency = 1})
buttonTween:Play()
SpawnButton.Visible = 1

------------------
-- Button Touch --
------------------
guiConnection = SpawnButton.MouseButton1Click:Connect(function()
	guiConnection:Disconnect()
	local logoTween = TweenService:Create(LogoBloody, TweenInfo.new(1), {ImageTransparency = 1})
	local buttonTween = TweenService:Create(SpawnButton, TweenInfo.new(1), {ImageTransparency = 1})
	local textTween   = TweenService:Create(SpawnButton.SpawnLabel, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1})
	local tipTween    = TweenService:Create(TipLabel, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1})
	local GradientTween = TweenService:Create(Gradient, TweenInfo.new(1), {BackgroundTransparency = 0})
	logoTween:Play()
	buttonTween:Play()
	textTween:Play()
	tipTween:Play()
	GradientTween:Play()
	local t = tick()
	while (tick() - t) < 1 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	RunService:UnbindFromRenderStep("Camera")
	PrimaryGUI:Destroy()
	coroutine.wrap(function()
		for i = 0, 50 do
			MenuSound.Volume = MenuSound.Volume - 0.0025
			wait(0.01)
		end
	end)()
	SpawnEvent:FireServer()
	local t = tick()
	while (tick() - t) < 1 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	GradientTween = TweenService:Create(Gradient, TweenInfo.new(1), {BackgroundTransparency = 1})
	GradientTween:Play()
	local t = tick()
	while (tick() - t) < 1 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	onMapChangeConnection:Disconnect()
	LoadingGUI:Destroy()
	MenuSound:Destroy()
end)
