RunService = game:GetService("RunService")

NotificationSpacing = 36

Player = game.Players.LocalPlayer
ScreenBottomPadding = game.ReplicatedStorage.ClientStorage.ScreenBottomPadding
ScreenGui = script.Parent

NotificationsList = {}

function ArrangeNotifications(doInstantChange)
	local list = NotificationsList
	local nlist = #list
	local listInverted = {}
	for i = 1, nlist do
		listInverted[i] = list[nlist + 1 - i]
	end
	for i, item in ipairs(listInverted) do
		if doInstantChange then
			item.Position = UDim2.new(0, 0, 1, -ScreenBottomPadding.Value - (NotificationSpacing * i))
		else
			item:TweenPosition(UDim2.new(0, 0, 1, -ScreenBottomPadding.Value - (NotificationSpacing * i)), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
		end
	end
end
function SpawnNotification(text, color3, lifetime)
	assert(typeof(text) == "string")
	assert(typeof(color3) == "Color3" or color3 == nil)
	assert(typeof(lifetime) == "number" or lifetime == nil)
	
	local notification = Instance.new("TextLabel")
	notification.Name = "Notification"
	notification.Size = UDim2.new(1, 0, 0, 36)
	notification.BackgroundTransparency = 1
	notification.Position = UDim2.new(0, 0, 1, -36)
	notification.TextSize = 36
	notification.Font = Enum.Font.SourceSansSemibold
	notification.TextTransparency = 1
	notification.TextStrokeTransparency = 1
	notification.Text = text
	notification.TextColor3 = color3 or Color3.new(1, 1, 1)
	
	local lifeTag = Instance.new("NumberValue")
	lifeTag.Name = "LifetimeLeft"
	lifeTag.Value = lifetime or 4
	lifeTag.Parent = notification
	
	notification.Parent = ScreenGui
	NotificationsList[#NotificationsList + 1] = notification
	
	ArrangeNotifications()
	
	return notification
end
function OnRenderStepped(deltaTime)
	local list = NotificationsList
	local listCopy = {}
	for i, item in ipairs(list) do
		listCopy[i] = item
	end
	local function tableRemove(t, value)
		for i, item in ipairs(t) do
			if item == value then
				table.remove(t, i)
				break
			end
		end
	end
	
	-- Fade in and out notifications depending on their LifetimeLeft value.
	local rearrangePending = false
	for i, item in ipairs(listCopy) do
		-- Countdown
		if item.LifetimeLeft.Value > 0 then
			item.LifetimeLeft.Value = math.max(0, item.LifetimeLeft.Value - deltaTime)
		end
		
		if item.LifetimeLeft.Value == 0 then
			-- Fade out
			item.TextTransparency = math.min(1, item.TextTransparency + deltaTime)
			item.TextStrokeTransparency = item.TextTransparency
			
			if item.TextTransparency == 1 then
				item:Destroy()
				tableRemove(list, item)
				rearrangePending = true
			end
		else
			-- Fade in
			item.TextTransparency = math.max(0, item.TextTransparency - deltaTime * 2)
			item.TextStrokeTransparency = item.TextTransparency
		end
	end
	if rearrangePending then
		ArrangeNotifications()
	end
end

RunService.RenderStepped:Connect(OnRenderStepped)
ScreenBottomPadding.Changed:Connect(function(value)
	return ArrangeNotifications(false)
end)

game.ReplicatedStorage.ClientStorage.SpawnNotification.OnInvoke = SpawnNotification
