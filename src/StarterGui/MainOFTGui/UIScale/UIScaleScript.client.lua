GuiService = game:GetService("GuiService")

MinimumPixelHeight = 512

UIScale = script.Parent
ScreenGui = script.Parent.Parent

function Update()
	if GuiService:IsTenFootInterface() then
		UIScale.Scale = ScreenGui.AbsoluteSize.Y / MinimumPixelHeight
	else
		UIScale.Scale = math.min(1, ScreenGui.AbsoluteSize.Y / MinimumPixelHeight)
	end
end

Update()

ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(Update)
