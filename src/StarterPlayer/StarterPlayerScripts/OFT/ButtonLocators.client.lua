-- Generates floating markers and guide arrows in the player's GUI
-- so that they can quickly locate buttons.
-- 
-- ForbiddenJ

script.Parent.DependencyWaiter.Wait:Invoke()

RunService = game:GetService("RunService")
TweenService = game.TweenService

GuiPadding = Rect.new(20, 20, 20, 20 + 80) -- All positive values are treated as inward offsets from the edges of the screen.
GuideSize = Vector2.new(40, 40)

GameLib = require(game.ReplicatedStorage.GameLib)

Player = game.Players.LocalPlayer
Camera = workspace.CurrentCamera
Multiplayer = workspace.Multiplayer
ButtonMarkerPrefab = game.ReplicatedStorage.Prefabs.ButtonMarkerPrefab
GuideScreenGui = nil

IsDisplayingLocators = script.IsDisplayingLocators
RegisteredButtons = {} -- Array of Button Models
EmptyButtonList = {} -- An empty table used in place of the real one sometimes.
Markers = {} -- Array of BillboardGuis
Guides = {} -- Array of ImageLabels

function TryRegisterButton(object)
	local isButton, nameExtension = GameLib.IsButton(object)
	if isButton then
		RegisteredButtons[#RegisteredButtons + 1] = object
	end
end
function TryUnregisterButton(object)
	local isButton, nameExtension = GameLib.IsButton(object)
	if isButton then
		for i, button in pairs(RegisteredButtons) do
			if button == object then
				table.remove(RegisteredButtons, i)
			end
		end
	end
end
function GetAngle(vector2)
	assert(typeof(vector2) == "Vector2", "Argument must be a Vector2.")
	
	if vector2.X == 0 and vector2.Y == 0 then
		error("Point cannot be 0, 0.")
	end
	local radians = math.atan2(-vector2.X, vector2.Y)
	if radians < 0 then
		radians = radians + math.pi * 2
	end
	return radians
end
function UpdateMarkersAndGuides(deltaTime)
	local buttonList = IsDisplayingLocators.Value and RegisteredButtons or EmptyButtonList
	
	-- Match count of markers with count of buttons.
	local buttonCount = #buttonList
	local markerCount = #Markers
	for i = markerCount + 1, buttonCount do
		local clone = ButtonMarkerPrefab:Clone()
		clone.Parent = Player.PlayerGui
		Markers[i] = clone
	end
	for i = buttonCount + 1, markerCount do
		Markers[i]:Destroy()
		Markers[i] = nil
	end
	local guideCount = #Guides
	for i = guideCount + 1, buttonCount do
		local guide = Instance.new("ImageLabel")
		guide.Parent = GuideScreenGui
		guide.Size = UDim2.new(0, GuideSize.X, 0, GuideSize.Y)
		guide.BackgroundTransparency = 1
		guide.ScaleType = Enum.ScaleType.Stretch
		guide.Image = "rbxassetid://2500573769"
		local tween = TweenService:Create(
			guide,
			TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, math.huge, true),
			{ImageTransparency = 0.7})
		tween.Name = "AnimateTween"
		tween.Parent = guide
		tween:Play()
		Guides[i] = guide
	end
	for i = buttonCount + 1, guideCount do
		Guides[i].AnimateTween:Cancel()
		Guides[i]:Destroy()
		Guides[i] = nil
	end
	
	-- Update visual appearances of button waypoints.
	buttonCount = #buttonList
	local guideGuiBounds = Rect.new(GuiPadding.Min, GuideScreenGui.AbsoluteSize - GuiPadding.Min - GuiPadding.Max)
	local guideGuiSize = Vector2.new(guideGuiBounds.Width, guideGuiBounds.Height)
	local guideGuiCenter = GuiPadding.Min + guideGuiSize / 2
	for i, button in ipairs(buttonList) do
		local marker = Markers[i]
		local guide = Guides[i]
		
		local buttonHitbox = button.Hitbox
		local buttonState = button:FindFirstChild("_ButtonState")
		local buttonStateValue = (buttonState ~= nil and buttonState:IsA("StringValue")) and button._ButtonState.Value or nil
		
		local screenPosition, isOnScreen = Camera:WorldToScreenPoint(buttonHitbox.Position)
		isOnScreen =
			screenPosition.Z > 0 and
			screenPosition.X >= guideGuiBounds.Min.X and screenPosition.X <= guideGuiBounds.Max.X and
			screenPosition.Y >= guideGuiBounds.Min.Y and screenPosition.Y <= guideGuiBounds.Max.Y
		local isActive = buttonStateValue == "Active" or buttonStateValue == "ActiveGroup"
		
		local color = Color3.new(1, 1, 0)
		if buttonStateValue == "Active" then
			color = Color3.new(0, 1, 0)
		elseif buttonStateValue == "ActiveGroup" then
			color = Color3.new(0.4, 0.7, 1)
		end
		local bashCountNeeded = 1
		if button:FindFirstChild("_BashCountNeeded") and button:FindFirstChild("_BashCount") then
			bashCountNeeded = button._BashCountNeeded.Value - button._BashCount.Value
		end
		
		marker.Adornee = buttonHitbox
		marker.Enabled = buttonStateValue ~= "Pressed"
		marker.Image.ImageColor3 = color
		marker.Image.Image = isActive and "rbxassetid://2961714609" or "rbxassetid://2961714650"
		marker.Counter.Text = buttonStateValue == "ActiveGroup" and bashCountNeeded or ""
		if isActive then
			local markerImage = marker.Image
			markerImage.Rotation = markerImage.Rotation + 135 * deltaTime
			if markerImage.Rotation > 360 then
				markerImage.Rotation = markerImage.Rotation - 360
			end
		else
			marker.Image.Rotation = 0
		end
		
		local offsetFromScreenCenter = Vector2.new(screenPosition.X, screenPosition.Y) - guideGuiCenter
		if screenPosition.Z < 0 then
			offsetFromScreenCenter = -offsetFromScreenCenter
		end
		local guideUnitPosition = (offsetFromScreenCenter / guideGuiSize).Unit
		local guideScreenPosition = guideUnitPosition * guideGuiSize / 2 + guideGuiCenter
		guide.Visible = isActive and not isOnScreen
		guide.ImageColor3 = color
		guide.Position = UDim2.new(0, guideScreenPosition.X - GuideSize.X / 2, 0, guideScreenPosition.Y - GuideSize.Y / 2)
		guide.Rotation = GetAngle(offsetFromScreenCenter) / math.pi * 180 - 90
	end
end

GuideScreenGui = Instance.new("ScreenGui")
GuideScreenGui.Name = "GuideScreenGui"
GuideScreenGui.ResetOnSpawn = false
GuideScreenGui.Parent = Player.PlayerGui

for i, item in pairs(Multiplayer:GetDescendants()) do
	TryRegisterButton(item)
end

Multiplayer.DescendantAdded:Connect(TryRegisterButton)
Multiplayer.DescendantRemoving:Connect(TryUnregisterButton)
IsDisplayingLocators.Changed:Connect(function(value)
	UpdateMarkersAndGuides(0)
end)
RunService.RenderStepped:Connect(UpdateMarkersAndGuides)
