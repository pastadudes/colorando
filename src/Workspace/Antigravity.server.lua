local objectValue = script.Parent:WaitForChild("UpsideDownPad")
local character = script.Parent
local isUpsideDown = false

-- Function to toggle upside-down state
local function toggleUpsideDown()
	isUpsideDown = not isUpsideDown
	-- Adjust gravity based on upside-down state
	if isUpsideDown then
		character.Humanoid.GravityScale = -1
	else
		character.Humanoid.GravityScale = 1
	end
	-- Adjust character's rotation to reflect upside-down state
	character:SetPrimaryPartCFrame(CFrame.new(character.PrimaryPart.Position, character.PrimaryPart.Position + Vector3.new(0, 0, isUpsideDown and -1 or 1)))
end

-- Function to handle object value change
local function onObjectValueChange()
	local pad = objectValue.Value
	if pad and pad:IsA("BasePart") then
		toggleUpsideDown()
	end
end

-- Connect object value change event
objectValue.Changed:Connect(onObjectValueChange)