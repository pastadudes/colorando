
local id = 70259868
local plr = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- A sample function providing one usage of InputBegan
local function onInputBegan(input, _gameProcessed)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local key = input.KeyCode
		if key == Enum.KeyCode.R then
			print("r")
			end
	end
end

UserInputService.InputBegan:Connect(onInputBegan)