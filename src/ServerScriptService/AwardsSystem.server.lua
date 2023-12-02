-- Abstracts out the tracking of badges using a simple naming scheme.
--
-- This also is my first time experimenting with awarding badges.
-- 
-- I'm not a big fan of BadgeService functions that yield from web calls, which is why I made this script.
-- 
-- Created by ForbiddenJ

BadgeService = game:GetService("BadgeService")
RunService = game:GetService("RunService")

AwardsList = require(game.ReplicatedStorage.AwardsSystem.AwardsList)

AwardGainedEvent = game.ReplicatedStorage.AwardsSystem.AwardGained

function GrantAwardAsync(player, awardId)
	assert(typeof(player) == "Instance" and player:IsA("Player"), "Argument 1 must be a Player.")
	assert(typeof(awardId) == "string", "Argument 2 must refer to a registered award!")
	local award = assert(AwardsList[awardId], "Argument 2 must refer to a registered award!")
	
	assert(IsAwardable(awardId), "The award can't be granted!")
	
	local ownershipValue = player.AwardsOwned:FindFirstChild(awardId)
	if not ownershipValue.Value then
		if not RunService:IsStudio() then
			BadgeService:AwardBadge(player.UserId, award.BadgeId)
		end
		ownershipValue.Value = true
		AwardGainedEvent:FireClient(player, awardId)
		print("[Awards System] Awarded " .. awardId .. " to " .. player.Name .. ".")
	end
end
function IsAwardable(awardId)
	assert(typeof(awardId) == "string", "Argument 1 must refer to a registered award!")
	local award = assert(AwardsList[awardId], "Argument 1 must refer to a registered award!")
	
	return award.GameId == game.GameId or RunService:IsStudio()
end

function BindPlayer(player)
	local data = Instance.new("Folder")
	data.Name = "AwardsOwned"
	for id, award in pairs(AwardsList) do
		local entry = Instance.new("BoolValue")
		entry.Name = id
		entry.Value = false
		entry.Parent = data
		
		if not RunService:IsStudio() then
			-- Reload the award state.
			spawn(function(...)
				entry.Value = BadgeService:UserHasBadgeAsync(player.UserId, award.BadgeId)
			end)
		end
	end
	data.Parent = player
end

script.GrantAwardAsync.OnInvoke = GrantAwardAsync
script.IsAwardable.OnInvoke = IsAwardable
game.Players.PlayerAdded:Connect(BindPlayer)
