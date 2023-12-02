-- Prompts the local player to vote when the player 
-- 
-- ForbiddenJ

local GameLib = require(game.ReplicatedStorage.GameLib)

local Player = game.Players.LocalPlayer
local GameState = game.ReplicatedStorage.Game.GameState
local NextMapOverride = game.ReplicatedStorage.Game.NextMapOverride
local MapVote = Player.MapVote
local PlayState = Player.PlayState
local SpawnNotificationFunction = game.ReplicatedStorage.ClientStorage.SpawnNotification
local GameMenuCurrentPanelName = script.Parent.GameMenu.CurrentPanelName
local GameMenuIsOpen = script.Parent.GameMenu.IsOpen
local PromptedPlayerToVote = false

local function TryPromptPlayerToVote()
	if not PromptedPlayerToVote
		and MapVote.Value == ""
		and GameState.Value ~= "Intermission"
		and (PlayState.Value == "Waiting" or PlayState.Value == "WaitingInLift") then
		
		PromptedPlayerToVote = true
		
		delay(0.7, function(...)
			SpawnNotificationFunction:Invoke("Please choose a map.")
		end)
		delay(2, function(...)
			if GameState.Value == "Map Voting" then
				GameMenuCurrentPanelName.Value = "MapList"
				GameMenuIsOpen.Value = true
			end
		end)
	end
end

GameState.Changed:Connect(function(value)
	if value == "Map Voting" then
		PromptedPlayerToVote = false
	end
	TryPromptPlayerToVote()
end)
PlayState.Changed:Connect(function(value)
	TryPromptPlayerToVote()
end)
NextMapOverride.Changed:Connect(function(value)
	if value ~= "" then
		SpawnNotificationFunction:Invoke("The next map was overridden.")
	end
end)
MapVote.Changed:Connect(function(value)
	if value == "_Random" then
		SpawnNotificationFunction:Invoke("You voted for a random map.")
	elseif value ~= "" then
		SpawnNotificationFunction:Invoke("You voted for a map.")
	end
end)
