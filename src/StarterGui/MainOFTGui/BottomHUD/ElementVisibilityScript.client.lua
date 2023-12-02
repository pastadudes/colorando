-- Manages the visibility behavior of the HUD.
-- 
-- ForbiddenJ

TweenLib = require(game.ReplicatedStorage.TweenLib)

NormalScreenPadding = 60
CollapsedScreenPadding = 20
EasingTime = 0.3

ScreenBottomPadding = game.ReplicatedStorage.ClientStorage.ScreenBottomPadding
IsDisplayed = script.Parent.IsDisplayed

Elements = {
	script.Parent.AirMeter,
	script.Parent.GameMenuButton,
	script.Parent.SpectateButton,
	script.Parent.SpectateControlFrame,
}
VisibleElementPositions = {}
for i, element in ipairs(Elements) do
	VisibleElementPositions[element] = element.Position
end

-- I know there's a TweenPosition built into GUI objects, but it doesn't fire its callback
-- the way I want, so I'm doing it this way.
function TweenPosition(element, position, callback)
	return TweenLib.TweenGuiTransform(
		element,
		nil,
		position,
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		EasingTime,
		callback)
end
function UpdateElement(element, isInstant)
	if element.IsDisplayed.Value and IsDisplayed.Value then
		local targetPosition = VisibleElementPositions[element]
		if isInstant then
			TweenLib.StopGuiTween(element)
			element.Position = targetPosition
		else
			if not element.Visible then
				element.Position = UDim2.new(targetPosition.X, UDim.new(1, 0))
			end
			TweenPosition(element, targetPosition)
		end
		element.Visible = true
	elseif isInstant then
		TweenLib.StopGuiTween(element)
		element.Visible = false
	else
		TweenPosition(element, UDim2.new(element.Position.X, UDim.new(1, 0)), function(state)
			if state == Enum.PlaybackState.Completed then
				element.Visible = false
			end
		end)
	end
end
function UpdateAllElements(isInstant)
	for i, element in ipairs(Elements) do
		UpdateElement(element, isInstant)
	end
end

IsDisplayed.Changed:Connect(function(value)
	UpdateAllElements(false)
end)

-- Prepare the elements to be controlled by this script.
for i, element in ipairs(Elements) do
	if element:IsA("GuiBase2d") then
		local isDisplayedValue = element:FindFirstChild("IsDisplayed")
		if isDisplayedValue == nil then
			isDisplayedValue = Instance.new("BoolValue")
			isDisplayedValue.Name = "IsDisplayed"
			isDisplayedValue.Value = true
			isDisplayedValue.Parent = element
		end
		
		local function onChanged(value)
			UpdateElement(element, false)
		end
		isDisplayedValue.Changed:Connect(onChanged)
	end
end

ScreenBottomPadding.Value = NormalScreenPadding
UpdateAllElements(true)
