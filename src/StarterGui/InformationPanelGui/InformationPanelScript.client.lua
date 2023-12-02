-- Some sort of board slideshow system.
-- 
-- ForbiddenJ

GuiService = game:GetService("GuiService")
RunService = game:GetService("RunService")

TweenLib = require(game.ReplicatedStorage.TweenLib)

SlideCyclerInterval = 15
TransitionDuration = 0.7

Frame = script.Parent.Frame
TabFrame = script.Parent.Frame.TabFrame
StartStopButton = script.Parent.Frame.StartStopButton
TabButtonPrefab = script.Parent.Frame.TabFrame.TabButtonPrefab

CurrentSlideIndex = 1
SlideCyclerActive = true
SlideTimeLeft = SlideCyclerInterval
TabButtons = {}
Slides = {}

-- Populate the Slides variable.
table.insert(Slides, script.Parent.Frame.GroupPage)
if not GuiService:IsTenFootInterface() then -- Don't suggest Flood Test Community to Xbox players!
	table.insert(Slides, script.Parent.Frame.MapTestPage)
end

function SetSlideCyclerActive(value)
	assert(typeof(value) == "boolean")
	
	SlideCyclerActive = value
	
	StartStopButton.Icon.Image =
		value
		and "rbxasset://textures/AnimationEditor/button_pause_white@2x.png"
		or "rbxasset://textures/AnimationEditor/button_control_play.png"
	
	SlideTimeLeft = SlideCyclerInterval
end
function ChangeSlide(newIndex, instant)
	assert(Slides[newIndex] ~= nil, "Index must refer to a valid slide!")
	
	local newSlide = Slides[newIndex]
	
	-- Transition the slides.
	for i, slide in pairs(Slides) do
		TweenLib.StopGuiTween(slide)
		if instant or newIndex == CurrentSlideIndex then
			slide.Visible = i == newIndex
			slide.Position = UDim2.new(0, 0, 0, 0)
		elseif i == newIndex and not slide.Visible then
			slide.Position = UDim2.new(1, 0, 0, 0)
			TweenLib.TweenGuiTransform(
				slide,
				nil,
				UDim2.new(0, 0, 0, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				TransitionDuration)
			slide.Visible = true
		elseif i ~= newIndex and slide.Visible then
			TweenLib.TweenGuiTransform(
				slide,
				nil,
				UDim2.new(-1, 0, 0, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				TransitionDuration,
				function(...)
					slide.Visible = false
					slide.Position = UDim2.new(0, 0, 0, 0)
				end)
		end
	end
	
	-- Update the tab buttons.
	for i, button in pairs(TabButtons) do
		button.Circle.ImageTransparency = i == newIndex and 0 or 0.5
	end
	
	-- Change the background color.
	if instant then
		TweenLib.StopTween(Frame, "BackgroundColorTween")
		Frame.BackgroundColor3 = newSlide.BackgroundColor3
	else
		TweenLib.TweenObject(
			Frame,
			TweenInfo.new(TransitionDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = newSlide.BackgroundColor3},
			"BackgroundColorTween")
	end
	
	SlideTimeLeft = SlideCyclerInterval
	CurrentSlideIndex = newIndex
end
function ChangeToNextSlide()
	return ChangeSlide(CurrentSlideIndex < #Slides and CurrentSlideIndex + 1 or 1)
end

-- Create the buttons.
TabButtonPrefab.Parent = nil
for i, slide in ipairs(Slides) do
	local button = TabButtonPrefab:Clone()
	button.MouseButton1Click:Connect(function()
		SetSlideCyclerActive(false)
		ChangeSlide(i, false)
	end)
	button.Text = tostring(i)
	button.Name = string.format("Button%03i", i)
	button.Parent = TabFrame
	TabButtons[i] = button
end

-- Make the slides transparent.
for i, slide in ipairs(Slides) do
	slide.BackgroundTransparency = 1
end

-- Begin the cycle thing.
ChangeSlide(1, true)
SetSlideCyclerActive(true)
RunService.RenderStepped:Connect(function(deltaTime)
	if SlideCyclerActive then
		SlideTimeLeft = SlideTimeLeft - deltaTime
		if SlideTimeLeft <= 0 then
			ChangeToNextSlide()
		end
	end
	StartStopButton.Progress.Value = SlideTimeLeft / SlideCyclerInterval
end)
StartStopButton.MouseButton1Click:Connect(function()
	SetSlideCyclerActive(not SlideCyclerActive)
end)
