-- When the player dies, do a blackout effect.
-- 
-- ForbiddenJ

TweenLib = require(game.ReplicatedStorage.TweenLib)

Player = game.Players.LocalPlayer
BlackoutEffect = nil
BlackoutBlurEffect = nil
SoundFX = game.SoundService.SoundFX

SoundFXBaseVolume = SoundFX.Volume
DeathBind = nil

function OnDeath()
	TweenLib.TweenObject(
		SoundFX,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 2),
		{Volume = 0})
	TweenLib.TweenObject(
		BlackoutEffect,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 2),
		{Brightness = -1, TintColor = Color3.new(0, 0, 0)})
	TweenLib.TweenObject(
		BlackoutBlurEffect,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 2),
		{Size = 64})
	BlackoutEffect.Enabled = true
	BlackoutBlurEffect.Enabled = true
end
function OnSpawn(character)
	-- Handle death
	local humanoid = character and character:WaitForChild("Humanoid", 2)
	if humanoid ~= nil then
		if DeathBind ~= nil then
			DeathBind:Disconnect()
		end
		DeathBind = humanoid.Died:Connect(OnDeath)
	end
	
	-- Fade in screen.
	TweenLib.TweenObject(
		SoundFX,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		{Volume = SoundFXBaseVolume})
	TweenLib.TweenObject(
		BlackoutEffect,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		{Brightness = 0, TintColor = Color3.new(1, 1, 1)},
		nil,
		function(...)
			BlackoutEffect.Enabled = false
		end)
	TweenLib.TweenObject(
		BlackoutBlurEffect,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		{Size = 0},
		nil,
		function(...)
			BlackoutBlurEffect.Enabled = false
		end)
end

BlackoutEffect = Instance.new("ColorCorrectionEffect")
BlackoutEffect.Name = "BlackoutEffect"
BlackoutEffect.Brightness = 0
BlackoutEffect.Enabled = false
BlackoutEffect.Parent = workspace.CurrentCamera
BlackoutBlurEffect = Instance.new("BlurEffect")
BlackoutBlurEffect.Name = "BlackoutBlurEffect"
BlackoutBlurEffect.Size = 0
BlackoutBlurEffect.Enabled = false
BlackoutBlurEffect.Parent = workspace.CurrentCamera

OnSpawn(Player.Character)

Player.CharacterAdded:Connect(OnSpawn)
