-- Replaces the standard selection box with a custom animated one using the following elements:
-- 
-- - BlankSelectionBox
-- - CustomSelectionBox
-- 
-- Created by ForbiddenJ

local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local TweenLib = require(game.ReplicatedStorage.TweenLib)

local PlayerGui = game.Players.LocalPlayer.PlayerGui
local SelectionBox = script.Parent.CustomSelectionBox
local UIScale = script.Parent.UIScale

PlayerGui.SelectionImageObject = script.Parent.BlankSelectionBox
SelectionBox.Visible = false

-- Tween the color nicely.
SelectionBox.ImageColor3 = Color3.new(0.2, 1, 1)
TweenLib.TweenObject(
	SelectionBox,
	TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, math.huge, true),
	{ImageColor3 = Color3.new(0.2, 0.2, 1)},
	"ColorTween")

-- Make the selection box always appear around selected objects.
RunService.RenderStepped:Connect(function(deltaTime)
	local selected = GuiService.SelectedObject
	if selected ~= nil then
		-- Position the box around the selection.
		local pos = (selected.AbsolutePosition + Vector2.new(0, 36)) / UIScale.Scale
		local size = selected.AbsoluteSize / UIScale.Scale
		SelectionBox.Position = UDim2.new(0, pos.X - 4, 0, pos.Y - 4)
		SelectionBox.Size = UDim2.new(0, size.X + 8, 0, size.Y + 8)
		SelectionBox.Visible = true
	else
		SelectionBox.Visible = false
	end
end)
