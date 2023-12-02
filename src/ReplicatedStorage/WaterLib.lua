-- Provides the base functionality used to simulate water machanics from Flood Escape 2.
-- 
-- Script created by ForbiddenJ

RunService = game:GetService("RunService")
TweenService = game:GetService("TweenService")

DefaultStateChangeDuration = 1
WaterColor = Color3.fromRGB(33, 84, 185)
WaterAcidColor = BrickColor.new("Lime green").Color
WaterLavaColor = BrickColor.new("Really red").Color

local mod = {}

mod.AirMax = 100
mod.AirTankMax = 300

function mod.IsWater(basePart)
	return typeof(basePart) == "Instance" and basePart:IsA("BasePart") and string.sub(basePart.Name, 1, 6) == "_Water"
end
function mod.GetWaterState(water)
	if mod.IsWater(water) then
		local waterState = water:FindFirstChild("State")
		return (waterState ~= nil and waterState:IsA("StringValue")) and waterState.Value or "water"
	end
	return nil
end
function mod.MoveWater(water, move, dur, isLocalSpace)
	assert(typeof(water) == "Instance" and water:IsA("BasePart"), "Argument 1 must be an Instance of type BasePart.")
	assert(typeof(move) == "Vector3", "Argument 2 must be a Vector3!")
	assert(typeof(dur) == "number" or dur == nil, "Argument 3 only supports numbers!")
	
	if dur > 0 then
		spawn(function(...)
			local alpha = 0
			repeat
				local deltaTime = RunService.Heartbeat:Wait()
				local oldAlpha = alpha
				alpha = math.min(alpha + (deltaTime / dur), 1)
				local translateCFrame = CFrame.new(move * (alpha - oldAlpha))
				water.CFrame = isLocalSpace and water.CFrame * translateCFrame or translateCFrame * water.CFrame
			until alpha >= 1
		end)
	else
		water.CFrame = isLocalSpace and water.CFrame * CFrame.new(move) or CFrame.new(move) * water.CFrame
	end
end
function mod.SetWaterState(water, state, changeDuration)
	assert(mod.IsWater(water), "Argument 1 must be a valid water body!")
	assert(typeof(state) == "string", 'Argument 2 must be "water", "acid", or "lava"!')
	local lState = string.lower(state)
	assert(lState == "water" or lState == "acid" or lState == "lava", 'Argument 2 must be "water", "acid", or "lava"!')
	changeDuration = typeof(changeDuration) and changeDuration or DefaultStateChangeDuration
	
	local waterStateTag = water:FindFirstChild("State")
	if waterStateTag == nil then
		waterStateTag = Instance.new("StringValue")
		waterStateTag.Name = "State"
		waterStateTag.Value = "water"
		waterStateTag.Parent = water
	end
	if waterStateTag:IsA("StringValue") then
		local targetColor = WaterColor
		if lState == "acid" then
			targetColor = WaterAcidColor
		elseif lState == "lava" then
			targetColor = WaterLavaColor
		end
		
		local tween = TweenService:Create(
			water,
			TweenInfo.new(changeDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
			{Color = targetColor})
		tween.Completed:Connect(function(...)
			waterStateTag.Value = lState
		end)
		tween.Parent = water
		game.Debris:AddItem(tween, changeDuration + 0.5)
		tween:Play()
	else
		error("There's something named State inside of the water object which is not a StringValue.")
	end
end

return mod
