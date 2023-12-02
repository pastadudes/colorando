-- Notifies the player when a map had errors when loading.
-- 
-- ForbiddenJ

Player = game.Players.LocalPlayer
SpawnNotificationFunction = game.ReplicatedStorage.ClientStorage.SpawnNotification

MapsWereRejected = game.ReplicatedStorage.Game.MapsWereRejected

function OnMapIsRejected()
	SpawnNotificationFunction:Invoke("Found errors in some maps. They are not playable.", Color3.new(1, 0.3, 0.1), 10)
end

if MapsWereRejected.Value then
	OnMapIsRejected()
end

MapsWereRejected.Changed:Connect(function(value)
	if value then
		OnMapIsRejected()
	end
end)
