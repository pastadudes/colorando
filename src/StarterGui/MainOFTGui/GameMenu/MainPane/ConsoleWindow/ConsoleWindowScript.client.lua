-- Manages the output window.
-- 
-- ForbiddenJ

RunService = game:GetService("RunService")
TextService = game.TextService

MaxLineCount = 200

TweenLib = require(game.ReplicatedStorage.TweenLib)

GetMessageLogBindable = game.ReplicatedStorage.ClientStorage.Console.GetMessageLog
OnMessageLogged = game.ReplicatedStorage.ClientStorage.Console.OnMessageLogged

ScreenGui = script:FindFirstAncestorWhichIsA("ScreenGui")
UIScale = ScreenGui.UIScale
NotificationCount = script.Parent.NotificationCount
Panel = script.Parent
OutputFrame = script.Parent.OutputFrame
TextBlockPrefab = script.Parent.OutputFrame.TextBlock
TextBlocks = {}

PendingLayoutUpdate = false

function DisplayMessage(message, messageType)
	local block = TextBlockPrefab:Clone()
	
	block.Text = message
	if messageType == Enum.MessageType.MessageInfo then
		block.TextColor3 = Color3.new(0.5, 0.5, 1)
	elseif messageType == Enum.MessageType.MessageWarning then
		block.TextColor3 = Color3.new(1, 1, 0.2)
	elseif messageType == Enum.MessageType.MessageError then
		block.TextColor3 = Color3.new(1, 0.2, 0.2)
	end
	
	table.insert(TextBlocks, block)
	block.Parent = OutputFrame
	
	block.BackgroundColor3 = Color3.new(1, 1, 1)
	
	if Panel.Visible then
		block.BackgroundTransparency = 0
		TweenLib.TweenObject(
			block,
			TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundTransparency = 1},
			"FlashTween")
	elseif NotificationCount.Value < MaxLineCount then
		NotificationCount.Value = NotificationCount.Value + 1
	end
end
function UpdateLayout(alsoChangeScrollingPosition)
	-- Don't do anything since this panel is not visible.
	if not Panel.Visible then
		return
	end
	
	-- Purge lines as necessary.
	local count = #TextBlocks
	if count > MaxLineCount then
		local overflow = count - MaxLineCount
		for i = 1, overflow do
			TextBlocks[i]:Destroy()
			TextBlocks[i] = nil
		end
		table.move(TextBlocks, overflow + 1, count, 1)
		for i = count - overflow + 1, count do
			TextBlocks[i] = nil
		end
	end
	
	-- Arrange the lines.
	local y = 0
	for i, block in ipairs(TextBlocks) do
		local textDimensions = TextService:GetTextSize(
			block.Text,
			block.TextSize,
			block.Font,
			Vector2.new(OutputFrame.AbsoluteSize.X * UIScale.Scale - 20, math.huge))
		
		block.Position = UDim2.new(0, 10, 0, y)
		block.Size = UDim2.new(1, -20, 0, textDimensions.Y)
		y = y + textDimensions.Y
	end
	
	-- Manage the scroll bar.
	OutputFrame.CanvasSize = UDim2.new(0, 0, 0, y)
	if alsoChangeScrollingPosition then
		OutputFrame.CanvasPosition = Vector2.new(0, y - OutputFrame.AbsoluteSize.Y * UIScale.Scale)
	end
end

TextBlockPrefab.Parent = nil
for i, entry in ipairs(GetMessageLogBindable:Invoke()) do
	DisplayMessage(entry.message, entry.messageType)
end
UpdateLayout(true)

Panel:GetPropertyChangedSignal("Visible"):Connect(function()
	NotificationCount.Value = 0
	UpdateLayout(true)
end)
ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateLayout)
UIScale:GetPropertyChangedSignal("Scale"):Connect(UpdateLayout)
OnMessageLogged.Event:Connect(function(...)
	DisplayMessage(...)
	PendingLayoutUpdate = true
end)
RunService.RenderStepped:Connect(function(deltaTime)
	if PendingLayoutUpdate then
		PendingLayoutUpdate = false
		UpdateLayout(true)
	end
end)
