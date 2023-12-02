-- Controls the lighting effects depending on the player's setting.
-- 
-- ForbiddenJ

Effect1 = game.Lighting.DefaultBloom
Effect2 = game.Lighting.DefaultColorCorrection
LightingFXEnabled = game.ReplicatedStorage.ClientConfig.LightingFXEnabled

function Update()
	Effect1.Enabled = LightingFXEnabled.Value
	Effect2.Enabled = LightingFXEnabled.Value
end

LightingFXEnabled:GetPropertyChangedSignal("Value"):Connect(Update)

Update()
