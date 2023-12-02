local button = script.Parent
local char = game.Players.LocalPlayer.Character
local event = game.ReplicatedStorage.DespawnEvent

local function pressed()
	local egg = game.ReplicatedStorage.EggModel:Clone()

	egg.Parent = game.Workspace

	egg.Position = char.HumanoidRootPart.Position
	game:GetService("Debris"):AddItem(egg, 15)
	wait(0.01)
	
	for i = 1, #char:GetChildren() do
		if char:GetChildren()[i].Name ~= "Humanoid" or char:GetChildren()[i].Name ~= "HumanoidRootPart" then
			char:GetChildren()[i]:Destroy()
		end
	end
	char.Humanoid.Health = 0
end

button.Activated:Connect(pressed)
