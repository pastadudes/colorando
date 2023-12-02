GameLib = require(game.ReplicatedStorage.GameLib)

GameFolder = game.ReplicatedStorage.Game
MapInfoFolder = game.ReplicatedStorage.InstalledMapInfo

UIFrame = script.Parent.Frame

MapDifficultyLabelFallbackColor = UIFrame.MapDifficulty.BackgroundColor3

function UpdateMapDisplay()
	local nextMapPrefab = MapInfoFolder:FindFirstChild(GameFolder.NextMapName.Value)
	local mapSettings = nextMapPrefab and nextMapPrefab.Settings
	local difficulty = mapSettings and mapSettings.Difficulty.Value
	UIFrame.MapTitle.Text = mapSettings and mapSettings.MapName.Value or "None"
	UIFrame.MapImage.Image = mapSettings and "rbxassetid://" .. mapSettings.MapImage.Value or "rbxassetid://924320031"
	UIFrame.MapDifficulty.BackgroundColor3 = difficulty and GameLib.DifficultyColors[difficulty] or MapDifficultyLabelFallbackColor
	UIFrame.MapDifficulty.Text = difficulty and GameLib.DifficultyNames[difficulty] or ""
end
function UpdateTimerMeter()
	local oldSize = UIFrame.Meter.Size
	UIFrame.Meter.Size = UDim2.new(UDim.new(GameFolder.TimerAlpha.Value, oldSize.X.Offset), oldSize.Y)
end
function UpdateStatusLabel()
	UIFrame.StatusLabel.Text = GameFolder.GameState.Value
end

GameFolder.NextMapName.Changed:Connect(UpdateMapDisplay)
GameFolder.TimerAlpha.Changed:Connect(UpdateTimerMeter)
GameFolder.GameState.Changed:Connect(UpdateStatusLabel)

UpdateMapDisplay()
UpdateTimerMeter()
UpdateStatusLabel()
