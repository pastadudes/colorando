-- Creates objects which turn framed buttons into interactive switches.

local mod = {}

mod.OptionTemplates = {}
mod.OptionTemplates.Boolean = {
	[1] = {Value = false, Text = "Off", ButtonColor = Color3.new(1, 0.1, 0.1)},
	[2] = {Value = true, Text = "On", ButtonColor = Color3.new(0.1, 1, 0.1)},
}
mod.OptionTemplates.GhostPlayers = {
	[1] = {Value = 0, Text = "Off", ButtonColor = Color3.new(1, 0.1, 0.1)},
	[2] = {Value = 1, Text = "Near", ButtonColor = Color3.new(1, 1, 0.1)},
	[3] = {Value = 2, Text = "All", ButtonColor = Color3.new(0.1, 1, 0.1)},
}

function mod.new(frame, valueObject, optionTemplateName)
	assert(typeof(frame) == "Instance" and frame:IsA("TextButton"), "A TextButton is the only valid first argument.")
	assert(typeof(valueObject) == "Instance", "You must provide an Instance that has a Value property.")
	assert(mod.OptionTemplates[optionTemplateName] ~= nil, "OptionTemplateName must be the name of a valid option template.")
	assert(frame.Button:IsA("TextButton"), "There must be a TextButton named Button within the frame.")
	
	local self = {}
	
	-- Functions
	self.UpdateButton = mod.UpdateButton
	self.Dispose = mod.Dispose
	
	-- Constructor
	self.Frame = frame
	self.Button = frame.Button
	self.ValueObject = valueObject
	self.OptionTable = mod.OptionTemplates[optionTemplateName]
	self.EventConnections = {}
	self.EventConnections[1] = valueObject:GetPropertyChangedSignal("Value"):Connect(function()
		return self:UpdateButton()
	end)
	local function onClick()
		valueObject.Value = mod.rollValue(self.OptionTable, valueObject.Value)
	end
	self.EventConnections[2] = self.Frame.MouseButton1Click:Connect(onClick)
	self.EventConnections[3] = self.Button.MouseButton1Click:Connect(onClick)
	
	self:UpdateButton()
	
	return self
end
function mod.rollValue(optionTable, value)
	local currentOptionIndex = mod.findOptionIndex(optionTable, value)
	local newOptionIndex = nil
	if currentOptionIndex then
		newOptionIndex = currentOptionIndex < #optionTable and currentOptionIndex + 1 or 1
	end
	if newOptionIndex then
		return optionTable[newOptionIndex].Value
	else
		error("The value supplied is not a valid option.")
	end
end
function mod.findOptionIndex(optionTable, value)
	local r = nil
	for i, option in ipairs(optionTable) do
		if option.Value == value then
			r = i
		end
	end
	return r
end

function mod:UpdateButton()
	local selectedOptionIndex = mod.findOptionIndex(self.OptionTable, self.ValueObject.Value)
	local selectedOption = self.OptionTable[selectedOptionIndex]
	
	self.Button.Size = UDim2.new(0.5, 0, 1, 0)
	self.Button:TweenPosition(UDim2.new((selectedOptionIndex - 1) / (#self.OptionTable - 1) / 2, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
	self.Button.BackgroundColor3 = selectedOption.ButtonColor
	self.Button.Text = selectedOption.Text
end
function mod:Dispose()
	for i, connection in pairs(self.EventConnections) do
		connection:Disconnect()
		self.EventConnections[i] = nil
	end
end

return mod
