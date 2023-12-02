local touch = script.Parent
local ough = script.Parent.Parent:WaitForChild("oof")


local function PlayerTouched(Part)
	local Parent = Part.Parent
	if ough.Playing == false then
		ough:Play()
	end
end


touch.Touched:connect(PlayerTouched)

