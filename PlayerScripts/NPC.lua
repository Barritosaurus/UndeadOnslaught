 --------------------------------------
-- POLISystems Lightweight NPC Script --
--         Created : 6/7/2021         --
--------------------------------------

--[[
	The goal of this NPC is to achieve an extremely
	verastile script for multiple classes of NPCs 
	for my game Undead Onslaught.
	
	Pathfinding check and target check every N seconds, 
	movement and all other systems are ran on each heartbeat.
	If a player is in direct line of sight to the player the
	NPC will chase them directly using Humanoid:MoveTo()
	if the NPC cannot see a player it will request a path
	every N seconds to the closest player; also will
	determine closest player every N seconds.

]]--

 ------------
-- Services --
 ------------
 local CollectionService  = game:GetService("CollectionService")
 local PathfindingService = game:GetService("PathfindingService")
 local RunService         = game:GetService("RunService")
 local Workspace          = game:GetService("Workspace")
 local Maid               = require(script:WaitForChild("Maid"))
 
  ------------------------
 -- Configuration Values --
 ------------------------
 local function getValueFromConfigs(name)
     local configuration = script.Parent:WaitForChild("Configuration")
     local valueObject   = configuration and configuration:FindFirstChild(name)
     return valueObject and valueObject.Value
 end
 
 local attackDamage   = getValueFromConfigs("AttackDamage")
 local walkSpeed      = getValueFromConfigs("Movespeed")
 local targetRadius   = 500
 local destroyOnDeath = true
 local searchInterval = 4 -- This is variable N
 local attackRange    = 4
 local attackDelay    = 1
 
 
  -------------------
 -- Maid Instancing --
  -------------------
 local NPC = Maid.new()
 NPC.Instance         = script.Parent
 NPC.Humanoid         = NPC.Instance:WaitForChild("Humanoid")
 NPC.Head             = NPC.Instance:WaitForChild("Head")
 NPC.HumanoidRootPart = NPC.Instance:WaitForChild("HumanoidRootPart")
 NPC.Alignment        = NPC.Instance.HumanoidRootPart:WaitForChild("AlignOrientation")
 
 
  --------------------
 -- Other Instancing --
  --------------------
 local worldAttachment  = Instance.new("Attachment")
 worldAttachment.Name   = "NPCWorldAttachment"
 worldAttachment.Parent = Workspace.Terrain
 NPC.WorldAttachment    = worldAttachment
 NPC.HumanoidRootPart.AlignOrientation.Attachment1 = worldAttachment
 
 
  --------------
 -- NPC States -- 
  --------------
 local startPos  = NPC.Instance.PrimaryPart.Position
 
 -- Logical Statements --
 local attacking           = false
 local chasing             = false
 local dead                = false
 local onCooldown          = false
 local lineOfSight         = false
 local searchingForTargets = false
 local movingToPoints      = false
 local running             = true
 
 -- Targets --
 local currentTarget         = nil
 local currentTargetDistance = 999 
 local newTarget             = nil
 local newTargetDistance     = -1
 
 -- Search Variables --
 local searchIndex     = 0
 local timeSearchEnded = 0
 local searchRegion    = nil
 local searchParts     = {}
 local pathObject      = nil
 local currentPath     = {}
 
 
  --------------
 -- Animations --
 --------------
 local attackAnimation = NPC.Humanoid:LoadAnimation(NPC.Instance.Animations.AttackAnimation)
 attackAnimation.Looped = false
 attackAnimation.Priority = Enum.AnimationPriority.Action
 NPC.AttackAnimation = attackAnimation
 
 --[[
 local idleAnimation = NPC.Humanoid:LoadAnimation(NPC.Instance.Animations.IdleAnimation)
 idleAnimation.Looped = false
 idleAnimation.Priority = Enum.AnimationPriority.Action
 NPC.IdleAnimation = idleAnimation
 ]]--
 
 local deathAnimation = NPC.Humanoid:LoadAnimation(NPC.Instance.Animations.DeathAnimation)
 deathAnimation.Looped = false
 deathAnimation.Priority = Enum.AnimationPriority.Action
 NPC.DeathAnimation = deathAnimation
 
 local runAnimation = NPC.Humanoid:LoadAnimation(NPC.Instance.Animations.RunAnim)
 runAnimation.Looped = true
 runAnimation.Priority = Enum.AnimationPriority.Movement
 NPC.RunAnimation = runAnimation
 
 local deadAnimation = NPC.Humanoid:LoadAnimation(NPC.Instance.Animations.DeadAnimation)
 deadAnimation.Looped = true
 deadAnimation.Priority = Enum.AnimationPriority.Action
 NPC.DeadAnimation = deadAnimation
 
 
  -------------
 -- Functions -- 
  -------------
 local random = Random.new()
 local function getRandomPointInCircle(centerPosition, circleRadius)
     local radius = math.sqrt(random:NextNumber()) * circleRadius
     local angle = random:NextNumber(0, math.pi * 2)
     local x = centerPosition.X + radius * math.cos(angle)
     local z = centerPosition.Z + radius * math.sin(angle)
 
     local position = Vector3.new(x, centerPosition.Y, z)
 
     return position
 end
 
 local function isAlive()
     return NPC.Humanoid.Health > 0 and NPC.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead
 end
 
 local function destroy()
     NPC:destroy()
 end
 
 
  -----------------
 -- Functionality --
  -----------------
 local function checkLineOfSight()
     if NPC and currentTarget.Parent then
         local distance = (NPC.HumanoidRootPart.Position - currentTarget.Position).Magnitude
         local temp = false
         local ray = Ray.new(
             NPC.Head.Position,
             (currentTarget.Parent.HumanoidRootPart.Position - NPC.HumanoidRootPart.Position).Unit * distance
         )
         local part = Workspace:FindPartOnRayWithIgnoreList(ray, {NPC.Instance, Workspace.MapObjects.CurrentMap.NoTarget.Zombies, currentTarget.Parent}, false, true)
         if part then
             lineOfSight = false
         else
             lineOfSight = true
         end
     end
 end
 
 local function isInstanceAttackable(targetInstance)
     local targetHumanoid = targetInstance and targetInstance.Parent and targetInstance.Parent:FindFirstChild("Humanoid")
     if not targetHumanoid then
         return false
     end
 
     local isAttackable = false
     local distance     = (NPC.HumanoidRootPart.Position - targetInstance.Position).Magnitude
 
     if distance <= targetRadius then
         local ray = Ray.new(
             NPC.HumanoidRootPart.Position,
             (targetInstance.Parent.HumanoidRootPart.Position - NPC.HumanoidRootPart.Position).Unit * distance
         )
 
         local part = Workspace:FindPartOnRayWithIgnoreList(ray, {targetInstance.Parent, NPC.Instance, Workspace.MapObjects}, false, true)
 
         if targetInstance ~= NPC.Instance and targetInstance:IsDescendantOf(Workspace) and targetHumanoid.Health > 0 and targetHumanoid:GetState() ~= Enum.HumanoidStateType.Dead and not CollectionService:HasTag(targetInstance.Parent, "ZombieFriend") and not CollectionService:HasTag(targetInstance.Parent, "Downed") and not part then
             isAttackable = true
         end
     end
     return isAttackable
 end
 
 local function requestPath()
     if currentTarget then
         local targetPosition = currentTarget.Position
         pathObject  = PathfindingService:CreatePath()
         pathObject:ComputeAsync(NPC.HumanoidRootPart.Position, targetPosition)
         currentPath = pathObject:GetWaypoints()
         pathing     = true
     end
 end
 
 local function moveNPC()
     if currentTarget then
         if pathing and not movingToPoints then
             local i = 0
             movingToPoints = true
             while pathing do
                 i = i + 1
                 if currentPath[i + 2] then
                     NPC.Humanoid:MoveTo(currentPath[i + 2].Position)
                     local t = tick()
                     while (tick() - t) < 0.3 do
                         game:GetService("RunService").Heartbeat:Wait()
                     end
                     if i > 25 then
                         NPC.Humanoid:MoveTo(getRandomPointInCircle(NPC.HumanoidRootPart.Position, targetRadius - 300))
                         requestPath()
                         i = 0
                         while (tick() - t) < 1 do
                             game:GetService("RunService").Heartbeat:Wait()
                         end
                     end
                 else
                     movingToPoints = false
                     pathing = false
                 end
             end
         elseif not movingToPoints then
             local targetPosition = (NPC.HumanoidRootPart.Position - currentTarget.Position).Unit + currentTarget.Position
             NPC.Humanoid:MoveTo(currentTarget.Position + (currentTarget.Velocity / 1.5))
         end
         
         NPC.AttackAnimation:Stop()
         if not NPC.RunAnimation.IsPlaying then
             NPC.RunAnimation:Play()
         end
     end
 end
 
 local function findTarget(usePathfinding)
     if usePathfinding then
         -- Do a new search region if we are not already searching through an existing search region
         if not searchingForTargets then
             searchingForTargets = true
 
             -- Create a new region
             local centerPosition = NPC.HumanoidRootPart.Position
             local topCornerPosition = centerPosition + Vector3.new(targetRadius, targetRadius, targetRadius)
             local bottomCornerPosition = centerPosition + Vector3.new(-targetRadius, -targetRadius, -targetRadius)
 
             searchRegion = Region3.new(bottomCornerPosition, topCornerPosition)
             searchParts = Workspace:FindPartsInRegion3WithIgnoreList(searchRegion, Workspace.MapObjects:GetChildren(), math.huge)
 
             newTarget = nil
             newTargetDistance = nil
 
             -- Reset to defaults
             searchIndex = 1
         end
 
         if searchingForTargets then
             -- Search through our list of parts and find attackable Humanoids
             local checkedParts = 0
             while searchingForTargets and searchIndex <= #searchParts and checkedParts < 10 do
                 local currentPart = searchParts[searchIndex]
                 if currentPart and currentPart.Parent and currentPart.Parent.Name ~= "Handle" and not currentPart:IsA("Tool") and isInstanceAttackable(currentPart) then
                     local character = currentPart.Parent
                     local distance = (character.HumanoidRootPart.Position - NPC.HumanoidRootPart.Position).magnitude
 
                     -- Determine if the charater is the closest.
                     if not newTargetDistance or distance < newTargetDistance then
                         newTarget = character.HumanoidRootPart
                         newTargetDistance = distance
                     end
                 end
 
                 searchIndex = searchIndex + 1
                 checkedParts = checkedParts + 1
             end
 
             if searchIndex >= #searchParts then
                 currentTarget = newTarget
                 searchingForTargets = false
                 timeSearchEnded = tick()
             end
         end
         requestPath()
     else
         -- Do a new search region if we are not already searching through an existing search region
         if not searchingForTargets then
             searchingForTargets = true
 
             -- Create a new region
             local centerPosition = NPC.HumanoidRootPart.Position
             local topCornerPosition = centerPosition + Vector3.new(targetRadius, targetRadius, targetRadius)
             local bottomCornerPosition = centerPosition + Vector3.new(-targetRadius, -targetRadius, -targetRadius)
 
             searchRegion = Region3.new(bottomCornerPosition, topCornerPosition)
             searchParts = Workspace:FindPartsInRegion3WithIgnoreList(searchRegion, Workspace.MapObjects:GetChildren(), math.huge)
 
             newTarget = nil
             newTargetDistance = nil
 
             -- Reset to defaults
             searchIndex = 1
         end
 
         if searchingForTargets then
             -- Search through our list of parts and find attackable Humanoids
             local checkedParts = 0
             while searchingForTargets and searchIndex <= #searchParts and checkedParts < 15 do
                 local currentPart = searchParts[searchIndex]
                 if currentPart and currentPart.Parent and currentPart.Parent.Name ~= "Handle" and not currentPart:IsA("Tool") and isInstanceAttackable(currentPart) then
                     local character = currentPart.Parent
                     local distance = (character.HumanoidRootPart.Position - NPC.HumanoidRootPart.Position).magnitude
 
                     -- Determine if the charater is the closest
                     if not newTargetDistance or distance < newTargetDistance then
                         newTarget = character.HumanoidRootPart
                         newTargetDistance = distance
                     end
                 end
 
                 searchIndex = searchIndex + 1
                 checkedParts = checkedParts + 1
             end
 
             if searchIndex >= #searchParts then
                 currentTarget = newTarget
                 searchingForTargets = false
                 timeSearchEnded = tick()
             end
         end
         pathing        = false
         movingToPoints = false
         currentPath = {}
     end
 end
 
 
 local function attackTarget()
     attacking = true
     
     local originalWalkSpeed = NPC.Humanoid.WalkSpeed
     NPC.Humanoid.WalkSpeed = originalWalkSpeed + 5
     NPC.Humanoid:MoveTo(currentTarget.Position + (currentTarget.Velocity / 3))
     
     -- Create a part and use it as a collider, to find Humanoids in front of the zombie
     -- This is not ideal, but it is the simplest way to achieve a hitbox
     local hitPart = Instance.new("Part")
     hitPart.Size = Vector3.new(3,2,3)
     hitPart.Transparency = 1
     hitPart.CanCollide = true
     hitPart.Anchored = true
     hitPart.CFrame = NPC.HumanoidRootPart.CFrame * CFrame.new(0, -1, -3)
     hitPart.Parent = Workspace
 
     local hitTouchingParts = hitPart:GetTouchingParts()
 
     -- Destroy the hitPart before it results in physics updates on touched parts
     hitPart:Destroy()
 
     -- Find Humanoids to damage
     local attackedHumanoids	= {}
     for _, part in pairs(hitTouchingParts) do
         local parentModel = part:FindFirstAncestorOfClass("Model")
         if isInstanceAttackable(part) and not attackedHumanoids[parentModel] then
             attackedHumanoids[parentModel.Humanoid] = true
         end
     end
 
     -- Damage the Humanoids
     for Humanoid in pairs(attackedHumanoids) do
         if not onCooldown then
             NPC.RunAnimation:Stop()
             NPC.AttackAnimation:Play()
             Humanoid:TakeDamage(attackDamage)
         end
     end
     onCooldown = true
     startPos = NPC.Instance.PrimaryPart.Position
     local t = tick()
     while (tick() - t) < attackDelay do
         game:GetService("RunService").Heartbeat:Wait()
     end
     NPC.AttackAnimation:Stop()
     NPC.Humanoid.WalkSpeed = originalWalkSpeed
     attacking = false
     onCooldown = false
 end
 
 local function onDeath()
     currentTarget       = nil
     attacking           = false
     newTarget           = nil
     searchParts         = nil
     searchingForTargets = false
 
     NPC.HeartbeatConnection:Disconnect()
 
     NPC.HumanoidRootPart.Anchored = true
     NPC.RunAnimation:Stop()
     NPC.DeathAnimation:Play()
     wait(NPC.DeathAnimation.Length)
     NPC.DeadAnimation:Play()
     --NPC.HumanoidRootPart.Anchored = false
     
     if destroyOnDeath then
         local t = tick()
         while (tick() - t) < 2 do
             game:GetService("RunService").Heartbeat:Wait()
         end
         destroy()
     end
 end
 
 
 
 
  -----------------------------
 -- Render / Heartbeat Timers --
  -----------------------------
 local function onHeartBeat()
     if currentTarget then
         checkLineOfSight()
         NPC.Alignment.Enabled = true
         NPC.WorldAttachment.CFrame = CFrame.new(NPC.HumanoidRootPart.Position, currentTarget.Position)
         if (currentTarget.Position - NPC.HumanoidRootPart.Position).magnitude < attackRange then
             if not attacking and not onCooldown then
                 attackTarget()
             end
         else
             moveNPC()
         end
     else
         NPC.Alignment.Enabled = false
         findTarget(true)
     end	
 end
 
 local function onNTimer()
     if lineOfSight then
         findTarget(false)
     else
         findTarget(true)
     end
 end
 
  ---------------
 -- Connections --
  ---------------
 NPC.DiedConnection = NPC.Humanoid.Died:Connect(function()
     running = false
     onDeath()
 end)
 
 runEvery = 32
 count = -1
 NPC.HeartbeatConnection = RunService.Heartbeat:Connect(function()
     count = (count + 1)%runEvery
     if count ~= 0 then
         return
     end
     onHeartBeat()
 end)
 
 while running == true do
     onNTimer()
     local t = tick()
     while (tick() - t) < searchInterval do
         game:GetService("RunService").Heartbeat:Wait()
     end
 end