-- Adds sounds to the GUI buttons.
-- 
-- ForbiddenJ

Sound = script.Parent
GuiTarget = script.Parent.Parent
ButtonBindings = {} -- A table of MouseButton1Down connections indexed by their buttons.

function TryBindButton(object)
	if object:IsA("GuiButton") then
		ButtonBindings[object] = object.MouseButton1Down:Connect(function()
			Sound:Play()
		end)
	end
end
for i, item in ipairs(GuiTarget:GetDescendants()) do
	TryBindButton(item)
end
GuiTarget.DescendantAdded:Connect(TryBindButton)
GuiTarget.DescendantRemoving:Connect(function(object)
	if ButtonBindings[object] ~= nil then
		ButtonBindings[object]:Disconnect()
		ButtonBindings[object] = nil
	end
end)
