local button = script.Parent
local goofs = script.Parent.Parent.Parent.Parent.UselessJunk

local function pressed()
	if goofs.Enabled == true then
		goofs.Enabled = false
	else
		goofs.Enabled = true
	end
end

button.Activated:Connect(pressed)
