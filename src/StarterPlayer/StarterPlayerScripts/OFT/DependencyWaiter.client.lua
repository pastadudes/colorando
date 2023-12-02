-- This script uses the yielding behavior of BindableFunctions with no callbacks
-- to cause other scripts to wait until this script is done executing.
-- 
-- ForbiddenJ

-- Wait for general dependencies.
Player = game.Players.LocalPlayer
Player:WaitForChild("PlayState")
Player:WaitForChild("MapVote")
Player.PlayerGui:WaitForChild("MainOFTGui")

-- Implement Wait BindableFunction to end waiting invokes.
function script.Wait.OnInvoke()
	return true
end
