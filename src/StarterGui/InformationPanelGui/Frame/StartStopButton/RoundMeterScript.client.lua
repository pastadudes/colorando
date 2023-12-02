local Progress = script.Parent.Progress
local Frame = script.Parent
local LHalfGradient = script.Parent.LHalf.Circle.UIGradient
local RHalfGradient = script.Parent.RHalf.Circle.UIGradient

local function Update()
	local progress = Progress.Value
	
	-- Clamp right part between 0 and 180
	RHalfGradient.Rotation = math.clamp(progress * 360, 0, 180)
	-- Clamp left part between 180 and 360
	LHalfGradient.Rotation = math.clamp(progress * 360, 180, 360)
end

Update()

Progress:GetPropertyChangedSignal("Value"):Connect(Update)
