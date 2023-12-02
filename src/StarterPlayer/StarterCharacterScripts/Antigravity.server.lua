local objectValue = Instance.new("ObjectValue")

objectValue.Parent = script.Parent
local character = script.Parent
local isUpsideDown = false

local vectorForce =	 Instance.new("BodyForce")
vectorForce.Parent = character.HumanoidRootPart

-- Function to toggle upside-down state
local function toggleUpsideDown(plr)
	
	if plr.Name ~= character.Name then return end
	
	isUpsideDown = not isUpsideDown
	-- Adjust gravity based on upside-down state
	
	-- Adjust character's rotation to reflect upside-down state
	character.HumanoidRootPart.RootJoint.C0 = character.HumanoidRootPart.RootJoint.C0 * CFrame.Angles(math.pi, 0, math.pi)
end


-- Connect object value change event
game.ReplicatedStorage.AntiGrav.OnServerEvent:Connect(toggleUpsideDown)

game:GetService("RunService").Stepped:Connect(function(time, step)
	if isUpsideDown then
		
		
		vectorForce.Force = Vector3.new(0,3000,0)
	else
		vectorForce.Force = Vector3.new(0,0,0)
	end
	
end)