--------------
-- Services --
--------------
local CollectionService = game:GetService("CollectionService")
local Players           = game:GetService("Players")

---------------
-- Functions --
---------------
-- Detect Player Spawn --
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		CollectionService:AddTag(character, "Player")
	end)
end)