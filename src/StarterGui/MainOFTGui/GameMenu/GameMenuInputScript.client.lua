GuiService = game:GetService("GuiService")
UserInputService = game:GetService("UserInputService")
ContextActionService = game:GetService("ContextActionService")

CurrentPanelName = script.Parent.CurrentPanelName
GetCurrentPanelFunction = script.Parent.GetCurrentPanel
IsOpen = script.Parent.IsOpen
TabPreviousFunction = script.Parent.TabPrevious
TabNextFunction = script.Parent.TabNext

function SelectFirstElement()
	if IsOpen.Value and (UserInputService.KeyboardEnabled or UserInputService.GamepadEnabled) then
		local panel = GetCurrentPanelFunction:Invoke()
		local element = panel.FirstSelect.Value
		GuiService.GuiNavigationEnabled = true
		GuiService.SelectedObject = element
	end
end
function ActionHandler(actionName, inputState, inputObj)
	if actionName == "GameMenuToggle" and inputState == Enum.UserInputState.Begin then
		IsOpen.Value = not IsOpen.Value
		return Enum.ContextActionResult.Sink
	elseif IsOpen.Value then
		if actionName == "GameMenuClose" and inputState == Enum.UserInputState.Begin then
			IsOpen.Value = false
			return Enum.ContextActionResult.Sink
		elseif actionName == "GameMenuTabPrevious" and inputState == Enum.UserInputState.Begin then
			TabPreviousFunction:Invoke()
			return Enum.ContextActionResult.Sink
		elseif actionName == "GameMenuTabNext" and inputState == Enum.UserInputState.Begin then
			TabNextFunction:Invoke()
			return Enum.ContextActionResult.Sink
		end
	end
	return Enum.ContextActionResult.Pass
end

CurrentPanelName.Changed:Connect(function(value)
	delay(0.3, SelectFirstElement)
end)
IsOpen.Changed:Connect(function(...)
	if IsOpen.Value then
		delay(0.3, SelectFirstElement)
	else
		GuiService.GuiNavigationEnabled = false
		GuiService.SelectedObject = nil
	end
end)
GuiService.AutoSelectGuiEnabled = false
ContextActionService:BindActionAtPriority("GameMenuToggle", ActionHandler, false, 4000, Enum.KeyCode.ButtonSelect, Enum.KeyCode.Backquote)
ContextActionService:BindActionAtPriority("GameMenuClose", ActionHandler, false, 4000, Enum.KeyCode.ButtonB)
ContextActionService:BindActionAtPriority("GameMenuTabPrevious", ActionHandler, false, 4000, Enum.KeyCode.ButtonL1, Enum.KeyCode.Q)
ContextActionService:BindActionAtPriority("GameMenuTabNext", ActionHandler, false, 4000, Enum.KeyCode.ButtonR1, Enum.KeyCode.E)
