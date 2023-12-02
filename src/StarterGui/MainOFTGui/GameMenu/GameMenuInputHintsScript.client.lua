UserInputService = game:GetService("UserInputService")

CloseHint = script.Parent.CloseHint
TabLeftHint = script.Parent.TabLeftHint
TabRightHint = script.Parent.TabRightHint

function Update(lastInputType)
	local isGamepad = lastInputType.Name:sub(1, 7) == "Gamepad"
	
	CloseHint.Visible = isGamepad
	TabLeftHint.Visible = isGamepad
	TabRightHint.Visible = isGamepad
end

Update(UserInputService:GetLastInputType())

UserInputService.LastInputTypeChanged:Connect(Update)
