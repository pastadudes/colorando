-- Decides when GUI elements should be displayed or hidden. (Except for SpectateControlFrame, which manages itself.)
-- 
-- ForbiddenJ

UserInputService = game:GetService("UserInputService")

IsDisplayed = script.Parent.IsDisplayed
HideGuiEnabled = game.ReplicatedStorage.ClientConfig.HideGuiEnabled
IsGameMenuOpen = script.Parent.Parent.GameMenu.IsOpen

SpectateButton_IsDisplayed = script.Parent.SpectateButton.IsDisplayed
GameMenuButton_IsDisplayed = script.Parent.GameMenuButton.IsDisplayed
AirMeter_IsDisplayed = script.Parent.AirMeter.IsDisplayed
AirMeter_IsActive = script.Parent.AirMeter.IsActive
SpectateControlFrame_IsDisplayed = script.Parent.SpectateControlFrame.IsDisplayed

MouseHovering = false
IsHiddenByOtherGUI = false

function Update()
	local focused = not HideGuiEnabled.Value or MouseHovering
	IsDisplayed.Value = not IsHiddenByOtherGUI
		
	--SpectateButton_IsDisplayed.Value = not IsHiddenByOtherGUI
	--GameMenuButton_IsDisplayed.Value = not IsHiddenByOtherGUI
	AirMeter_IsDisplayed.Value =
		(focused or AirMeter_IsActive.Value)
		and not IsHiddenByOtherGUI and not SpectateControlFrame_IsDisplayed.Value
end

SpectateControlFrame_IsDisplayed.Changed:Connect(Update)
AirMeter_IsActive.Changed:Connect(Update)
HideGuiEnabled.Changed:Connect(Update)
IsGameMenuOpen.Changed:Connect(function(value)
	IsHiddenByOtherGUI = value
	Update()
end)

-- Mouse Events
UserInputService:GetPropertyChangedSignal("MouseEnabled"):Connect(Update)
script.Parent.MouseEnter:Connect(function()
	MouseHovering = true
	Update()
end)
script.Parent.MouseLeave:Connect(function()
	MouseHovering = false
	Update()
end)

IsHiddenByOtherGUI = IsGameMenuOpen.Value
Update()
