local event = game.ReplicatedStorage:WaitForChild("skyEvent")


game.Lighting.ClockTime = 14
game.Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
local wrongAtmos = game.Lighting:FindFirstChild("NightAtmos")
if wrongAtmos ~= nil then
	wrongAtmos:Destroy() 
end

game.Lighting.Brightness = 2

local function onNotifyPlayer()
	wait(0.5)
	local map = game.Workspace.Multiplayer:FindFirstChild("Map").Settings.MapName.Value
	print(map)
	if map == "Bar" then 
		game.Lighting.ClockTime = 20.5
		game.Lighting.OutdoorAmbient = Color3.fromRGB(18,18,18)
		local atmos = game.ReplicatedStorage:WaitForChild("NightAtmos")
		local fog = atmos:Clone()
		fog.Parent = game.Lighting
		game.Lighting.Brightness = 0.3
		
		
	end
	
	if map ~= "Bar" then
		wrongAtmos:Destroy()
	end
	if map == "Grasslands" then 
		wait(0.5)
		local map = game.Workspace.Multiplayer:FindFirstChild("Map").Settings.MapName.Value
		game.Lighting.ClockTime = 14
		game.Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
		local wrongAtmos = game.Lighting:FindFirstChild("NightAtmos")
		if wrongAtmos ~= nil then wrongAtmos:Destroy() end
		
		game.Lighting.Brightness = 2

	end
end


event.OnClientEvent:Connect(onNotifyPlayer)