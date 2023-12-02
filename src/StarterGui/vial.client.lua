local clone = game.ReplicatedStorage:WaitForChild("VialGrabber"):Clone()
local vial = game.Workspace:WaitForChild("VialUnlock")
local click = vial.click.ClickDetector




function onMouseClick(plr)
	print("clicked")
	
	local item = game.Workspace["Item tray"]:FindFirstChild("VialGrabber")
	if item == nil then
		print("item")
	clone.Parent = game.Workspace:WaitForChild("Item tray")
	end
end

click.MouseClick:connect(onMouseClick)