local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local function toggleAdminMenu()
	local adminMenu = game.Players.LocalPlayer.PlayerGui:FindFirstChild("AdminMenu")

	if not adminMenu then
		-- Create the admin menu GUI
		adminMenu = Instance.new("ScreenGui")
		adminMenu.Name = "AdminMenu"
		-- Add UI elements to the admin menu GUI
		-- ...
		adminMenu.Parent = game.Players.LocalPlayer.PlayerGui
		print("Admin menu created")
	else
		-- Toggle the visibility of the admin menu
		adminMenu.Enabled = not adminMenu.Enabled
		print("Admin menu toggled")
	end
end
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		toggleAdminMenu()
	end
end)