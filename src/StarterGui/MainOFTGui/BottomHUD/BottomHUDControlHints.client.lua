UserInputService = game:GetService("UserInputService")

GameMenuButtonHint = script.Parent.GameMenuButton.ControlHint
SpectateButtonHint = script.Parent.SpectateButton.ControlHint
SpectatePrevHint = script.Parent.SpectateControlFrame.SpectatePrevButton.ControlHint
SpectateNextHint = script.Parent.SpectateControlFrame.SpectateNextButton.ControlHint

function Update(lastInputType)
	local isGamepad = lastInputType.Name:sub(1, 7) == "Gamepad"
	
	GameMenuButtonHint.Visible = isGamepad
	SpectateButtonHint.Visible = isGamepad
	SpectatePrevHint.Visible = isGamepad
	SpectateNextHint.Visible = isGamepad
end

Update(UserInputService:GetLastInputType())

UserInputService.LastInputTypeChanged:Connect(Update)
