-- Simply makes the teleport button work.

local TeleportService = game:GetService("TeleportService")
local PlayersService = game:GetService("Players")

script.Parent.TeleportButton.MouseButton1Click:Connect(function()
	TeleportService:Teleport(3900426789, PlayersService.LocalPlayer)
end)
