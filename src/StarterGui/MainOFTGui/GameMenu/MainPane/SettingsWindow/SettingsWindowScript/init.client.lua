-- Manages the Settings window.
-- 
-- ForbiddenJ

ToggleButton = require(script.ToggleButton)

ContentFrame = script.Parent.ContentPane

FovOptionHandler = ToggleButton.new(ContentFrame.FovOption, game.ReplicatedStorage.ClientConfig.WideFOV, "Boolean")
MusicOptionHandler = ToggleButton.new(ContentFrame.MusicOption, game.ReplicatedStorage.ClientConfig.MusicEnabled, "Boolean")
LightingFXOptionHandler = ToggleButton.new(ContentFrame.LightingFXOption, game.ReplicatedStorage.ClientConfig.LightingFXEnabled, "Boolean")
GhostOptionHandler = ToggleButton.new(ContentFrame.GhostOption, game.ReplicatedStorage.ClientConfig.GhostPlayers, "GhostPlayers")
HideGuiOptionHandler = ToggleButton.new(ContentFrame.HideGuiOption, game.ReplicatedStorage.ClientConfig.HideGuiEnabled, "Boolean")
