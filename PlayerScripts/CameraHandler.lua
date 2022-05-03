---------------------------------------
--    POLI Top-Down Camera System    --
--    		  Version 1.0			 --
---------------------------------------

-----------
-- Yield --
-----------
repeat wait() until game.Players.LocalPlayer.Character

--------------
-- Services --
--------------
local runService 		= game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local userInputService  = game:GetService("UserInputService")
local GuiService        = game:GetService("GuiService")
local Players    = game:GetService("Players")
local player     = game.Players.LocalPlayer

--------------------------
-- Variable Declaration --
--------------------------
local char           = nil
local humanoid       = nil
local playerRoot     = nil
local offset         = nil
local fov            = nil
local mouse          = nil
local camera         = nil
local lookingPart    = nil
local mobileGUI      = nil
local obscuringParts = {}

-----------------
-- Connections --
-----------------
local renderStepConnection     = nil
local onDiedConnection         = nil

---------------
-- Functions --
---------------
local function onPlayerSpawn()
	local t = tick()
	while (tick() - t) < 0.2 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	runService:UnbindFromRenderStep("Camera")
	char           = player.Character
	humanoid       = char:WaitForChild("Humanoid")
	playerRoot     = char.PrimaryPart
	camera         = game.workspace.Camera
	fov            = 80
	
	for i, part in pairs(obscuringParts) do
		if part.Transparency < 1 then
			part.Transparency = 0
		end
	end	
	
	obscuringParts = {}
	mouse          = player:GetMouse()
	camera.CameraType = "Scriptable"
	
	if userInputService.TouchEnabled and not userInputService.KeyboardEnabled and not userInputService.MouseEnabled and not userInputService.GamepadEnabled and not GuiService:IsTenFootInterface() then -- Best way of determining user touchscreen, it only works if touchscreen is enabled, add a player option to disable this.
		offset = Vector3.new(-10, 30, 0)
		fov    = 80
	else
		offset = Vector3.new(-20, 45, 0)
		fov    = 90
	end
	
	if humanoid == nil then
		onPlayerSpawn()
		return
	end
	
	local function onRenderStep()
		if char then
			if char:FindFirstChild("HumanoidRootPart") then
				local playerPosition = char.HumanoidRootPart.Position
				local cameraPosition = playerPosition + offset
				mobileGUI = player.PlayerGui:FindFirstChild("MobileControlGUI")
				camera.CFrame = CFrame.new(cameraPosition, playerPosition)


				for i, part in pairs(obscuringParts) do
					if part.Transparency < 1 then
						part.Transparency = 0
					end
				end	
				obscuringParts = camera:GetPartsObscuringTarget({playerPosition}, char:GetChildren())
				for i, part in pairs(obscuringParts) do
					if part.Transparency < 1 then
						part.Transparency = 0.8
					end
				end	
			end
		end
	end
	
	runService:BindToRenderStep("Camera", 201, onRenderStep)
	char.PrimaryPart = char:WaitForChild("HumanoidRootPart")
	humanoid.AutoRotate = false
	renderStepConnection = runService.Stepped:connect(function()
		if mobileGUI then
			if char == nil then
				warn("No character with camera to adjust detected, skipping this frame.")
			elseif playerRoot == nil then
				warn("No playerRoot set, skipping this frame.")
			end
		else
			if char == nil then
				warn("No character with camera to adjust detected, skipping this frame.")
			elseif playerRoot == nil then
				warn("No playerRoot set, skipping this frame.")
			elseif char.Humanoid.Health > 0 and not CollectionService:HasTag(char, "Downed") then
				local MousePos = mouse.Hit.p
				local lookVector = Vector3.new(MousePos.X,playerRoot.CFrame.Y,MousePos.Z)
				char:SetPrimaryPartCFrame(CFrame.new(playerRoot.CFrame.p, lookVector))
			end
		end
	end)
	
	onDiedConnection = humanoid.Died:Connect(function()
		onDiedConnection:Disconnect()
		renderStepConnection:Disconnect()
	end)
end

--------------------
-- Function Calls --
--------------------
onPlayerSpawn()
player.CharacterAdded:Connect(onPlayerSpawn)
