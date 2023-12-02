repeat wait(0.5) until game:IsLoaded()
local touch = game.Workspace:WaitForChild("DialogStarter")

touch.Touched:Connect(function() -- Touched Event
	-- Code

	




script.Parent.Enabled = true

local box = script.Parent:WaitForChild("Frame")
local title = box:WaitForChild("Frame"):WaitForChild("name")
local dialog = box:WaitForChild("one")
local dialog2 = box:WaitForChild("two")
local dialog3 = box:WaitForChild("free")
dialog3.Visible = false
dialog2.Visible = true
dialog.Visible = false

wait(2)

dialog.Visible = true
dialog2.Visible = false

wait(3)

dialog.Visible = false
dialog2.Visible = false
dialog3.Visible = true
wait(2)

script.Parent.Enabled = false

end)
