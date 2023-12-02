function Trigger()

	game.ReplicatedStorage.AntiGrav:FireServer(game.Players.LocalPlayer.Name)
end

game.ReplicatedStorage.AntiGrav.OnClientEvent:Connect(Trigger)
