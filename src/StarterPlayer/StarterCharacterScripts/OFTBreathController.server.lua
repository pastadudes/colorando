-- This game-specific script sets IsBreathEnabled to true while the
-- player's PlayState is "Playing" and false on any other value.
-- 
-- ForbiddenJ

Player = game.Players:GetPlayerFromCharacter(script.Parent)
PlayState = Player.PlayState
IsBreathEnabled = script.Parent:WaitForChild("Water"):WaitForChild("IsBreathEnabled")

function UpdateIsBreathEnabled()
	IsBreathEnabled.Value = (PlayState.Value == "Playing")
end

UpdateIsBreathEnabled()

PlayState.Changed:Connect(UpdateIsBreathEnabled)
