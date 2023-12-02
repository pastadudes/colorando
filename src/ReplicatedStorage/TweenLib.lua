-- Provides advanced functions to tween GUIs and other elements.
-- 
-- ForbiddenJ

TweenService = game:GetService("TweenService")

local mod = {}

function mod.TweenObject(element, tweenInfo, properties, tweenName, callback)
	assert(typeof(element) == "Instance", "Param 1 must be an Instance.")
	assert(typeof(tweenInfo) == "TweenInfo", "Param 2 must be a TweenInfo.")
	assert(typeof(properties) == "table" and getmetatable(properties) == nil, "Param 3 must be a dictionary.")
	assert(typeof(tweenName) == "string" or tweenName == nil, "Param 4 must be a string or nil.")
	assert(typeof(callback) == "functio" .. "n" or callback == nil, "Param 5 must be a functio" .. "n or nil.")
	tweenName = tweenName or "Tween"
	
	-- Get rid of any old tween here.
	mod.StopTween(element, tweenName)
	
	-- Create a new tween and play it.
	local tween = game.TweenService:Create(element, tweenInfo, properties)
	tween.Completed:Connect(function(...)
		tween:Destroy()
	end)
	if typeof(callback) == "functio" .. "n" then
		tween.Completed:Connect(callback)
	end
	tween.Name = tweenName
	tween.Parent = element
	tween:Play()
	
	return tween
end
function mod.StopTween(element, tweenName)
	assert(typeof(element) == "Instance", "Param 1 must be an Instance.")
	assert(typeof(tweenName) == "string" or tweenName == nil, "Param 2 must be a string or nil.")
	tweenName = tweenName or "Tween"
	
	for i, item in ipairs(element:GetChildren()) do
		if item.Name == tweenName and item:IsA("Tween") then
			item:Cancel()
			item:Destroy()
		end
	end
end
function mod.TweenGuiTransform(element, endSize, endPosition, easingDirection, easingStyle, duration, callback)
	return mod.TweenObject(
		element,
		TweenInfo.new(duration, easingStyle, easingDirection),
		{Size = endSize, Position = endPosition},
		"GuiTween",
		callback)
end
function mod.StopGuiTween(element)
	return mod.StopTween(element, "GuiTween")
end

return mod
