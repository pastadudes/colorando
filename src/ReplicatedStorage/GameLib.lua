local mod = {}

local RunService = game:GetService("RunService")

mod.DifficultyNames = {
	[1] = "Easy",
	[2] = "Normal",
	[3] = "Hard",
	[4] = "Insane",
	[5] = "Crazy",
}
mod.DifficultyColors = {
	[1] = Color3.new(0.2, 1, 0.2),
	[2] = Color3.new(1, 1, 0.2),
	[3] = Color3.new(1, 0.2, 0.2),
	[4] = Color3.new(0.85, 0, 1),
	[5] = Color3.new(1, 0.6, 0.2),
}
mod.LobbyMusicURL = "rbxassetid://1841370772"
mod.MapBehaviorStartDelay = 1
mod.GroupButtonPlayerPercentage = 0.275

-- Returns whether the object is a button, and if so, whatever was appended after the expected name.
function mod.IsButton(object)
	assert(typeof(object) == "Instance")
	
	local isButton, nameExtension = false, nil
	
	if object:IsA("Model") and string.sub(object.Name, 1, 7) == "_Button" then
		isButton, nameExtension = true, string.sub(object.Name, 8, -1)
	end
	
	return isButton, nameExtension
end

-- Returns all players belonging to a certain play status
function mod.GetPlayersWithPlayState(playState)
	assert(typeof(playState) == "string")
	
	local r = {}
	for i, player in ipairs(game.Players:GetPlayers()) do
		if player.PlayState.Value == playState then
			r[#r + 1] = player
		end
	end
	return r
end

-- Returns all players that should be put into the next map.
function mod.GetQueuedPlayers()
	local r = {}
	for i, player in ipairs(game.Players:GetPlayers()) do
		if player.PlayState.Value == "Waiting" or player.PlayState.Value == "WaitingInLift" then
			r[#r + 1] = player
		end
	end
	return r
end

-- Returns whether a given player has control privileges.
function mod.HasControlPrivileges(player)
	return
		(game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId) or
		RunService:IsStudio()
end

-- Returns whether a given physical location is within the bounding box of a BasePart.
function mod.IsLocationWithinBlock(part, location)
	assert(typeof(part) == "Instance" and part:IsA("BasePart"), "Argument 1 must be a BasePart.")
	assert(typeof(location) == "Vector3", "Argument 2 must be a Vector3.")
	
	local point = part.CFrame:PointToObjectSpace(location)
	return
		math.abs(point.X) < part.Size.X / 2 and
		math.abs(point.Y) < part.Size.Y / 2 and
		math.abs(point.Z) < part.Size.Z / 2
end

-- This function provides a method for detecting player proximity, which is useful for
-- enforcing maximum interaction distances.
function mod.GetProximity(player, location)
	assert(typeof(player) == "Instance" and player:IsA("Player"), "Argument 1 must be a Player object.")
	assert(typeof(location) == "Vector3", "Argument 2 must be a Vector3.")

	local torso = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if torso ~= nil and torso:IsA("BasePart") then
		return (torso.Position - location).Magnitude
	else
		return math.huge
	end
end

return mod
