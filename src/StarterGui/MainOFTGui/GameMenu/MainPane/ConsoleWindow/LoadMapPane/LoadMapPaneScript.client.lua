GameLib = require(game.ReplicatedStorage.GameLib)

Player = game.Players.LocalPlayer
LoadMapIDRemote = game.ReplicatedStorage.Game.Admin.InstallMapFromID
--LogMessage = game.ReplicatedStorage.ClientStorage.Console.LogMessage
MapIdInput = script.Parent.MapIDInput
LoadMapButton = script.Parent.LoadMapButton

IsDoingSomething = false

function OnLoadRequested()
	if not IsDoingSomething then
		IsDoingSomething = true
		
		local success, msgs = LoadMapIDRemote:InvokeServer(MapIdInput.Text)
		
		LoadMapButton.BorderColor3 = success and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
		LoadMapButton.TextColor3 = LoadMapButton.BorderColor3
		
		if success then
			MapIdInput.Text = ""
		end
		
		wait(1)
		
		LoadMapButton.BorderColor3 = Color3.new(0,0,0)
		LoadMapButton.TextColor3 = Color3.new(1, 1, 1)
		
		IsDoingSomething = false
	end
end

LoadMapButton.MouseButton1Click:Connect(OnLoadRequested)
MapIdInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		OnLoadRequested()
	end
end)

script.Parent.Visible = GameLib.HasControlPrivileges(Player)

--[[

You can load maps with their asset IDs at any time, though they aren't saved when this server shuts down.

Be careful what you load. Maps can do anything, including showing scary things, giving admin commands, or breaking the server entirely.

]]
