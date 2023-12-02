IsGameMenuOpen = script.Parent.Parent.Parent.GameMenu.IsOpen

script.Parent.MouseButton1Click:Connect(function()
	IsGameMenuOpen.Value = true
end)
