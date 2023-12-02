-- Notifies the player when they are being teleported.
-- 
-- ForbiddenJ

Player = game.Players.LocalPlayer
SpawnNotificationFunction = game.ReplicatedStorage.ClientStorage.SpawnNotification

Player.OnTeleport:Connect(function(teleportState, placeId, spawnName)
	if teleportState == Enum.TeleportState.Started then
		SpawnNotificationFunction:Invoke("Teleporting to game...", nil, 10)
		print("Teleport started ("..Player.Name..")")
	elseif teleportState == Enum.TeleportState.Failed then
		SpawnNotificationFunction:Invoke("Teleporting failed!", Color3.new(1, 0.3, 0.1), nil)
	end
end)
