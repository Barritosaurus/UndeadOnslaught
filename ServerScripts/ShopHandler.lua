----------------------
-- POLI ShopHandler --
----------------------

--------------
-- Services --
--------------
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local WaitEvent

-------------
-- Modules --
-------------
local ItemList = require(ReplicatedStorage.Modules:WaitForChild("ItemCost"))
local PremList = require(ReplicatedStorage.Modules:WaitForChild("PremiumCost"))
local SessionData = require(ReplicatedStorage.Modules:WaitForChild("SessionData"))
local DataSavingModule = require(ReplicatedStorage.Modules:WaitForChild("DataSavingModule"))

------------
-- Values --
------------
local DiffBonus = ReplicatedStorage.ServerValues:WaitForChild("DiffBonus")

----------------------
-- Remote Functions --
----------------------
local CheckPurchase = ReplicatedStorage.ServerEvents:WaitForChild("CheckPurchase")
local CheckRobuxPurchase = ReplicatedStorage.ServerEvents:WaitForChild("CheckRobuxPurchase")
local CheckGamepassPurchase = ReplicatedStorage.ServerEvents:WaitForChild("CheckGamepassPurchase")
local SetSpeed = ReplicatedStorage.ServerEvents:WaitForChild("SetSpeed")
local SetHealth = ReplicatedStorage.ServerEvents:WaitForChild("SetHealth")
local AddCash = ReplicatedStorage.ServerEvents:WaitForChild("AddCash")
local ReturnCash = ReplicatedStorage.ServerEvents:WaitForChild("ReturnCash")
local ReturnPrice = ReplicatedStorage.ServerEvents:WaitForChild("ReturnPrice")

-------------------------
-- Purchase Validation --
-------------------------
local function removeCash(player, cost)
	local playerUserId = "user_"..player.UserId
	local playerGUI = player.PlayerGui:WaitForChild("PrimaryGUI")
	local cashValue = playerGUI:WaitForChild("Cash")
	local currentMoney = nil
	local savedCash = nil
	local serverCash = nil
	-- This loop finds the player in the SessionData dictionary, the iterator will be the index location of the player data.
	for i, object in ipairs(SessionData) do
		if object.ID == playerUserId then
			currentMoney = object.Cash
			object.Cash = currentMoney - cost
			cashValue.Value = currentMoney - cost
			TweenService:Create(cashValue, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0.3), {Value = currentMoney - cost}):Play()
			break
		end
	end
end

CheckPurchase.OnServerInvoke = function(player, itemName)
	local playerUserId = "user_"..player.UserId
	local itemCost     = ItemList[itemName]
	local currentMoney = nil
	local iterator = 0
	
	-- This loop finds the player in the SessionData dictionary, the iterator will be the index location of the player data.
	for i, object in ipairs(SessionData) do
		iterator = i

		if object.ID == playerUserId then
			currentMoney = object.Cash
			break
		end
	end
	
	if currentMoney >= itemCost then
		-- Removes the cost of the item if the player can afford it, and then adds it to the players data.
		SessionData[iterator][itemName] = true
		removeCash(player, itemCost)
		return true
	else
		-- Player does not have sufficient funds, cancels the operation and returns a false.
		return false
	end
end

CheckRobuxPurchase.OnServerInvoke = function(player, itemID)
	WaitEvent = Instance.new("BindableEvent")
	MarketplaceService:PromptProductPurchase(player, itemID)
	local finishedConnection = MarketplaceService.PromptProductPurchaseFinished:connect(function(confirmPlayer, assetId, isPurchased)
		if confirmPlayer == player.UserId then
			WaitEvent:Fire()
		end
	end)
	WaitEvent.Event:Wait()
	WaitEvent:Destroy()
	finishedConnection:Disconnect()
	return
end

CheckGamepassPurchase.OnServerInvoke = function(player, passID)
	WaitEvent = Instance.new("BindableEvent")
	local returnValue = false
	MarketplaceService:PromptGamePassPurchase(player, passID)
	local finishedConnection = MarketplaceService.PromptGamePassPurchaseFinished:connect(function(confirmPlayer, confirmID, isPurchased)
		if confirmPlayer.UserId == player.UserId and passID == confirmID then
			if isPurchased == true then
				returnValue = true
			end
			WaitEvent:Fire()
		end
	end)
	
	WaitEvent.Event:Wait()
	WaitEvent:Destroy()
	finishedConnection:Disconnect()
	return returnValue
end

SetSpeed.OnServerEvent:Connect(function(player, owned)
	if owned == true then
		player.Character.Humanoid.WalkSpeed = 28
	end
end)

SetHealth.OnServerEvent:Connect(function(player, owned)
	if owned == true then
		player.Character.Humanoid.MaxHealth = 150
		player.Character.Humanoid.Health = 150
	end
end)

AddCash.Event:Connect(function(firingPlayer, damageDealt, cashMultiplier)
	local actualPlayer = nil
	
	for i, object in ipairs(Players:GetChildren()) do
		if object.Name == firingPlayer then
				actualPlayer = object
				local playerUserId = "user_"..actualPlayer.UserId
				local playerGUI = actualPlayer.PlayerGui:WaitForChild("PrimaryGUI")
				local cashValue = playerGUI:WaitForChild("Cash")
				local savedCash = nil
				local serverCash = nil
			
				
				for i, object in ipairs(SessionData) do
				if object.ID == playerUserId then
						savedCash = object.Cash
					object.Cash = math.floor(savedCash + ((damageDealt * DiffBonus.Value) * cashMultiplier))
						--TweenService:Create(cashValue, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0.1), {Value = math.floor(savedCash + ((damageDealt * 2) * cashMultiplier))}):Play()
					cashValue.Value = math.floor(savedCash + ((damageDealt * DiffBonus.Value) * cashMultiplier))
					break
					end
				end
			break
		end
	end
end)

ReturnCash.OnServerInvoke = function(player)
	local currentMoney = nil
	local playerUserId = "user_"..player.UserId

	-- This loop finds the player in the SessionData dictionary, the iterator will be the index location of the player data.
	for i, object in ipairs(SessionData) do
		if object.ID == playerUserId then
			currentMoney = object.Cash
			break
		end
	end
	
	return currentMoney
end

local function processReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- If player leaves.
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local playerUserId = "user_"..player.UserId
	local productID = receiptInfo.ProductId
	local itemName = PremList[productID].name
	local iterator = 0
	
	for i, object in ipairs(SessionData) do
		iterator = i
		if object.ID == playerUserId then
			break
		end
	end
	
	SessionData[iterator][itemName] = true
	
	local success = pcall(function()
		print("Shop trying to save transaction...")
		DataSavingModule.savePlayerData(player.userId)
	end)
	
	if success then
		WaitEvent:Fire()
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		WaitEvent:Fire()
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

------------------------
-- Receipt Definition --
------------------------
MarketplaceService.ProcessReceipt = processReceipt