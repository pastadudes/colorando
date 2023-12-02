-- Causes the humanoid to make splash sounds when it enters or leaves water.
-- 
-- By ForbiddenJ

SplashInSoundURL = "rbxasset://sounds/impact_water.mp3"
SplashOutSoundURL = "rbxasset://sounds/impact_water.mp3"

Humanoid = script.Parent.Parent.Humanoid
CurrentBodyValue = script.Parent:WaitForChild("CurrentBody")

SplashSound = Instance.new("Sound")
SplashSound.Name = "SplashSound"
SplashSound.SoundId = SplashInSoundURL
SplashSound.Parent = Humanoid.RootPart

CurrentBodyValue.Changed:Connect(function(value)
	if value ~= nil then
		SplashSound.SoundId = SplashInSoundURL
		SplashSound:Play()
	else
		SplashSound.SoundId = SplashOutSoundURL
		SplashSound:Play()
	end
end)
