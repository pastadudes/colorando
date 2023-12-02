-- Keeps track of which water body the humanoid is swimming in.
-- 
-- By ForbiddenJ

local RunService = game:GetService("RunService")

local WaterLib = require(game.ReplicatedStorage.WaterLib)
local WaterBodyTracker = require(game.ReplicatedStorage.WaterBodyTracker)

local CurrentWaterBody = script.Parent:WaitForChild("CurrentBody")
local Character = script.Parent.Parent
local CharacterHead = Character.Head

RunService.Heartbeat:Connect(function(deltaTime)
	CurrentWaterBody.Value = WaterBodyTracker.GetWaterBodyAt(CharacterHead.Position)
end)
