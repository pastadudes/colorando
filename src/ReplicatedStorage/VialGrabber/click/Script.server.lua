local click = script.Parent.ClickDetector
local vial = game.ReplicatedStorage:WaitForChild("Vial")


function onMouseClick(plr)
	print("ung")
	local clone = vial:Clone()
	local bp = plr:WaitForChild("Backpack")
	local item = bp:FindFirstChild("Vial")
	local item2 = bp:FindFirstChild("Holy vial")
	if item == nil and item2 == nil then
		print("hugh")
		clone.Parent = bp
	end
end

click.MouseClick:connect(onMouseClick)
