-- This script provides one aspect of support for older maps that use EventScript
-- by providing a module in a location where those older maps expect it.
-- 
-- ForbiddenJ

local WaterLib = require(game.ReplicatedStorage.WaterLib)

local mod = {}

function mod.moveWater(water, move, dur, isLocalSpace)
	return WaterLib.MoveWater(water, move, dur, isLocalSpace)
end
function mod.setWaterState(water, state)
	return WaterLib.SetWaterState(water, state)
end

return mod
