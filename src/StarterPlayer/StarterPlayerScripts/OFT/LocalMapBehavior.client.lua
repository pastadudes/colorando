-- Manages the client-side behavior of maps.
-- 
-- ForbiddenJ

script.Parent.DependencyWaiter.Wait:Invoke()

RunService = game:GetService("RunService")

GameLib = require(game.ReplicatedStorage.GameLib)

Player = game.Players.LocalPlayer
Camera = workspace.CurrentCamera
PlayState = Player.PlayState
CurrentMap = game.ReplicatedStorage.Game.CurrentMap
ExitOpen = game.ReplicatedStorage.Game.ExitOpen
GameState = game.ReplicatedStorage.Game.GameState
OnEcoSpawned = game.ReplicatedStorage.Game.OnEcoSpawned
OnPlayerSurvived = game.ReplicatedStorage.Game.OnPlayerSurvived
SpawnNotificationFunction = game.ReplicatedStorage.ClientStorage.SpawnNotification
IsDisplayingLocators = script.Parent.ButtonLocators.IsDisplayingLocators

ExitRegion = nil
SurvivedMap = false

function SetExitBlocksCollideable(value)
	assert(CurrentMap.Value ~= nil, "There is no map to change ExitBlocks in right now.")
	for i, item in ipairs(CurrentMap.Value:GetChildren()) do
		if item.Name == "ExitBlock" and item:IsA("BasePart") then
			item.CanCollide = value
		end
	end
end

CurrentMap.Changed:Connect(function(value)
	SurvivedMap = false
	
	if value ~= nil then
		ExitRegion = CurrentMap.Value:WaitForChild("ExitRegion", 5)
	else
		ExitRegion = nil
	end
end)
GameState.Changed:Connect(function(value)
	if value == "Intermission" and PlayState.Value == "Waiting" then
		SpawnNotificationFunction:Invoke("Intermission...")
	end
end)
PlayState.Changed:Connect(function(value)
	IsDisplayingLocators.Value = (value == "Playing")
	if value == "Playing" then
		-- Spawn a notification describing map is being played.
		local mapSettings = CurrentMap.Value.Settings
		local difficulty = mapSettings.Difficulty.Value
		SpawnNotificationFunction:Invoke(
			string.format("%s [%s] by %s", mapSettings.MapName.Value, GameLib.DifficultyNames[difficulty], mapSettings.Creator.Value),
			GameLib.DifficultyColors[difficulty])
	end
end)
OnPlayerSurvived.OnClientEvent:Connect(function()
	-- Notify the player they survived a map, and make the barriers solid.
	local notification = SpawnNotificationFunction:Invoke("You survived!", Color3.new(0.2, 1, 0.2), 4)
	SurvivedMap = true
	SetExitBlocksCollideable(true)
end)
OnEcoSpawned.OnClientEvent:Connect(function(spawnPlate)
	-- Reposition the camera behind the player.
	local headCFrame = Player.Character.Head.CFrame
	Camera.CFrame =
		CFrame.new(-spawnPlate.Position) * CFrame.new(Player.Character.Head.Position) *
		spawnPlate.CFrame * CFrame.Angles(math.pi / 180 * -20, 0, 0)
end)
