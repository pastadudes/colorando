-- Manages the game menu screen.
-- 
-- ForbiddenJ

StarterGui = game.StarterGui
UserInputService = game:GetService("UserInputService")

TweenLib = require(game.ReplicatedStorage.TweenLib)

Player               = game.Players.LocalPlayer
IsOpen               = script.Parent.IsOpen
CurrentPanelName     = script.Parent.CurrentPanelName
IsTabPaneExpanded    = script.Parent.IsTabPaneExpanded
TitleBar             = script.Parent.TitleBar
CloseButton          = script.Parent.CloseButton
TabPane              = script.Parent.TabPane
MainPane             = script.Parent.MainPane
ExpandTabPaneButton  = script.Parent.TabPane.ExpandButton
PanelList = {
	{
		Name = "GameInfo",
		Panel = MainPane.GameInfoWindow,
		Button = TabPane.GameInfoButton,
	},
	{
		Name = "MapList",
		Panel = MainPane.MapListWindow,
		Button = TabPane.MapListButton,
	},
	{
		Name = "Console",
		Panel = MainPane.ConsoleWindow,
		Button = TabPane.ConsoleButton,
	},
	{
		Name = "Settings",
		Panel = MainPane.SettingsWindow,
		Button = TabPane.SettingsButton,
	},
}
BlurEffect = nil

-- Functions

function IndexOfPanelEntryWithName(name)
	assert(typeof(name) == "string", "Argument 1 must be a string.")
	
	for i, entry in ipairs(PanelList) do
		if entry.Name == name then
			return i, entry
		end
	end
	error("Entry '" .. name .. "' is not a registered panel name.")
end
function GetCurrentPanel()
	return select(2, IndexOfPanelEntryWithName(CurrentPanelName.Value)).Panel
end
function UpdateMenuVisibility(shouldDoInstantly)
	if shouldDoInstantly then
		TweenLib.StopGuiTween(script.Parent)
		BlurEffect.Size = IsOpen.Value and 16 or 0
		script.Parent.Position = IsOpen.Value and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 0, 1, 0)
		script.Parent.Visible = IsOpen.Value
	else
		if IsOpen.Value then
			TweenLib.TweenGuiTransform(
				script.Parent,
				nil,
				UDim2.new(0, 0, 0, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.5)
			script.Parent.Visible = true
		else
			TweenLib.TweenGuiTransform(
				script.Parent,
				nil,
				UDim2.new(0, 0, 1, 0),
				Enum.EasingDirection.In,
				Enum.EasingStyle.Quad,
				0.5,
				function(...)
					script.Parent.Visible = false
				end)
		end
		
		-- Animate the blur effect.
		TweenLib.TweenObject(
			BlurEffect,
			TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{Size = IsOpen.Value and 16 or 0},
			"EffectTween")
	end
	
	-- Handle Roblox's core GUI.
	UserInputService.ModalEnabled = IsOpen.Value
end
function UpdateTabPane()
	TabPane:TweenSize(
		IsTabPaneExpanded.Value and UDim2.new(0, 160, 1, -40) or UDim2.new(0, 40, 1, -40),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.3,
		true)
	ExpandTabPaneButton.Label.Visible = IsTabPaneExpanded.Value
	
	for i, entry in ipairs(PanelList) do
		-- Highlight the button?
		entry.Button.BorderSizePixel = CurrentPanelName.Value == entry.Name and 2 or 1
		entry.Button.BorderColor3 = CurrentPanelName.Value == entry.Name and Color3.new(0.2, 1, 1) or Color3.new(0, 0, 0)
		
		entry.Button.Label.Visible = IsTabPaneExpanded.Value
	end
end
function UpdateVisiblePanel(shouldDoInstantly)
	for i, entry in ipairs(PanelList) do
		local pane = entry.Panel
		
		TweenLib.StopGuiTween(pane)
		
		local oldVisible = pane.Visible
		local newVisible = (entry.Name == CurrentPanelName.Value)
		
		if shouldDoInstantly or oldVisible == newVisible then
			pane.Position = UDim2.new(0, 0, 0, 0)
			pane.Visible = newVisible
		elseif oldVisible ~= newVisible then
			if newVisible then
				pane.Position = UDim2.new(0, 0, 1, 0)
				TweenLib.TweenGuiTransform(
					pane,
					nil,
					UDim2.new(0, 0, 0, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					0.3)
				pane.Visible = true
			else
				TweenLib.TweenGuiTransform(
					pane,
					nil,
					UDim2.new(0, 0, -1, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					0.3,
					function(...)
						pane.Visible = false
					end)
			end
		end
	end
	
	TitleBar.Text = GetCurrentPanel().Title.Value
end
function UpdateEverything(shouldDoInstantly)
	UpdateMenuVisibility(shouldDoInstantly)
	UpdateTabPane(shouldDoInstantly)
	UpdateVisiblePanel(shouldDoInstantly)
end
function TabNext()
	local currentIndex = IndexOfPanelEntryWithName(CurrentPanelName.Value)
	local newIndex = currentIndex >= #PanelList and 1 or currentIndex + 1
	CurrentPanelName.Value = PanelList[newIndex].Name
	IsTabPaneExpanded.Value = false
end
function TabPrevious()
	local currentIndex = IndexOfPanelEntryWithName(CurrentPanelName.Value)
	local newIndex = currentIndex <= 1 and #PanelList or currentIndex - 1
	CurrentPanelName.Value = PanelList[newIndex].Name
	IsTabPaneExpanded.Value = false
end

-- Constructor

BlurEffect = Instance.new("BlurEffect")
BlurEffect.Name = "GameMenuBlurEffect"
BlurEffect.Size = 0
BlurEffect.Enabled = false
BlurEffect.Parent = workspace.CurrentCamera
BlurEffect:GetPropertyChangedSignal("Size"):Connect(function()
	BlurEffect.Enabled = (BlurEffect.Size > 0)
end)

script.Parent.Visible = true

UpdateEverything(true)

-- Handle all the different values.
IsOpen.Changed:Connect(function(value)
	UpdateMenuVisibility(false)
end)
IsTabPaneExpanded.Changed:Connect(function(value)
	UpdateTabPane(false)
end)
CurrentPanelName.Changed:Connect(function(value)
	UpdateTabPane(false)
	UpdateVisiblePanel(false)
end)
CloseButton.MouseButton1Click:Connect(function()
	IsOpen.Value = false
end)
ExpandTabPaneButton.MouseButton1Click:Connect(function()
	IsTabPaneExpanded.Value = not IsTabPaneExpanded.Value
end)

-- Prepare the tab buttons.
for i, entry in ipairs(PanelList) do
	entry.Button.MouseButton1Click:Connect(function()
		CurrentPanelName.Value = entry.Name
		IsTabPaneExpanded.Value = false
	end)
	
	-- Notification badge
	local count = entry.Panel:FindFirstChild("NotificationCount")
	if count ~= nil and count:IsA("IntValue") then
		local counter = entry.Button.NotificationCounter
		local function updateCounter()
			counter.Visible = count.Value > 0
			counter.Text = tostring(count.Value)
		end
		count.Changed:Connect(updateCounter)
		updateCounter()
	end
end

script.Parent.TabNext.OnInvoke = TabNext
script.Parent.TabPrevious.OnInvoke = TabPrevious
script.Parent.GetCurrentPanel.OnInvoke = GetCurrentPanel
