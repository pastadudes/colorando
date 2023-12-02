local Players = game:GetService("Players")

workspace.person.Head.Dialog.DialogChoiceSelected:Connect(function(player, choice)
	if choice.Name == "howtoplay" then
		local character = player.Character
		local partToTeleportTo = workspace:WaitForChild("verynicelol") -- Replace "PartName" with the name of the part you want to teleport to

		if character and partToTeleportTo then
			local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
			humanoidRootPart.CFrame = partToTeleportTo.CFrame
		end
	end
end)