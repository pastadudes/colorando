-- Detects which water body the Camera is in and sets it as the CurrentBody's value.
-- 
-- By ForbiddenJ

local RunService = game:GetService("RunService")

local WaterLib = require(game.ReplicatedStorage.WaterLib)
local WaterBodyTracker = require(game.ReplicatedStorage.WaterBodyTracker)

local Camera = workspace.CurrentCamera
local CurrentBody = script.CurrentBody

RunService.RenderStepped:Connect(function(deltaTime)
	CurrentBody.Value = WaterBodyTracker.GetWaterBodyAt(Camera.CFrame.Position)
end)
