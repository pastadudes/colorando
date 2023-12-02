-- This module keeps track of water bodies that exist in the local Workspace.
-- It primarily serves the water mechanics and their corresponding effects.
-- 
-- ForbiddenJ

-- Dependencies
WaterLib = require(game.ReplicatedStorage.WaterLib)

-- Public Members
local mod = {}

mod.WaterBodies = {}
mod.OnWaterBodyAdded = script.OnWaterBodyAdded.Event
mod.OnWaterBodyLost = script.OnWaterBodyLost.Event

function mod.GetWaterBodyAt(position)
	assert(typeof(position) == "Vector3", "Position must be a Vector3.")
	
	local resultWater = nil
	for i, water in ipairs(mod.WaterBodies) do
		-- Thanks to the developer forum post called "Check if a point is inside a possibly rotated part"
		local point = water.CFrame:PointToObjectSpace(position)
		if math.abs(point.X) < water.Size.X / 2 and math.abs(point.Y) < water.Size.Y / 2 and math.abs(point.Z) < water.Size.Z / 2 then
		    resultWater = water
			break
		end
	end
	return resultWater
end

-- Private Members
function TryRegisterWaterBody(object)
	if WaterLib.IsWater(object) then
		-- No defensive checks as DescendantAdded will not be called twice for the same object before DescendantRemoving.
		table.insert(mod.WaterBodies, object)
		script.OnWaterBodyAdded:Fire(object)
	end
end
function TryUnregisterWaterBody(object)
	if WaterLib.IsWater(object) then
		for i, item in pairs(mod.WaterBodies) do
			if object == item then
				table.remove(mod.WaterBodies, i)
				script.OnWaterBodyLost:Fire(object)
				break
			end
		end
	end
end

-- Start tracking the Workspace.
for i, item in pairs(workspace:GetDescendants()) do
	TryRegisterWaterBody(item)
end
workspace.DescendantAdded:Connect(TryRegisterWaterBody)
workspace.DescendantRemoving:Connect(TryUnregisterWaterBody)

return mod
