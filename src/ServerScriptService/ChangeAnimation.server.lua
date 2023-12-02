local Players = game:GetService("Players")

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")

	for _, track in pairs(animator:GetPlayingAnimationTracks()) do
		track:Stop(0)
	end

	local animateScript = character:WaitForChild("Animate")
	animateScript.run.RunAnim.AnimationId = "rbxassetid://9908003369"        -- Run
	animateScript.jump.JumpAnim.AnimationId = "rbxassetid://9908026020"      -- Jump
	animateScript.fall.FallAnim.AnimationId = "rbxassetid://9907980867"      -- Fall
end

local function onPlayerAdded(player)
	player.CharacterAppearanceLoaded:Connect(onCharacterAdded)
end

Players.PlayerAdded:Connect(onPlayerAdded)