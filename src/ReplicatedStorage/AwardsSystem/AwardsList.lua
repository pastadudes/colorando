-- A list of major awards in Open Flood Test.

local data = {
	TheSecret = {Name = "Secret Place", BadgeId = 2124539450, Description = "Shh..."},
	--CorrosiveSewersSecret = {Name = "Sizzling Obscurity", BadgeID = 0, Description = "Find this in Corrosive Sewers."},
	--FloodyCavernsSecret = {Name = "Dark Mine", BadgeID = 0, Description = "Find this in Floody Caverns."},
}

for id, award in pairs(data) do
	award.ID = id -- So that the named IDs can be looked up from their tables.
	award.GameId = 1068226746 -- So the system knows which game the badges belong to.
end

return data
