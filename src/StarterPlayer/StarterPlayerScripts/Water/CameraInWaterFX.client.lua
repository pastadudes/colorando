-- Applies effects to the Camera depending on the CurrentBody value in CameraInWaterDetector.
-- 
-- Requires a SoundGroup named SoundFX to be present in your game.
-- 
-- By ForbiddenJ

local RunService = game:GetService("RunService")

assert(game.SoundService.SoundFX:IsA("SoundGroup"))

local WhiteColor = Color3.new(1, 1, 1)
local WaterTintAlpha = 0.75
local FisheyeEffectCycleDuration = 4.5
local FisheyeFovStart = 60
local FisheyeFovPeak = 70

local CameraInWaterDetector = script.Parent.CameraInWaterDetector

local Camera = workspace.CurrentCamera

local ColorCorrectionEffect = Instance.new("ColorCorrectionEffect")
ColorCorrectionEffect.Name = "WaterColorCorrectionEffect"
ColorCorrectionEffect.Enabled = false
ColorCorrectionEffect.Parent = Camera
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Name = "WaterBlurEffect"
BlurEffect.Size = 7.5
BlurEffect.Enabled = false
BlurEffect.Parent = Camera
local SoundEffect1 = Instance.new("EqualizerSoundEffect")
SoundEffect1.Name = "WaterSoundEffect1"
SoundEffect1.Priority = 11
SoundEffect1.LowGain = 4
SoundEffect1.MidGain = -20
SoundEffect1.HighGain = -25
SoundEffect1.Enabled = false
SoundEffect1.Parent = game.SoundService.SoundFX
local SoundEffect2 = Instance.new("ReverbSoundEffect")
SoundEffect2.Name = "WaterSoundEffect2"
SoundEffect2.DecayTime = 2
SoundEffect2.Density = 0.3
SoundEffect2.Diffusion = 0.33
SoundEffect2.DryLevel = -3
SoundEffect2.Enabled = false
SoundEffect2.Priority = 12
SoundEffect2.WetLevel = -9
SoundEffect2.Parent = game.SoundService.SoundFX

local OriginalFOV = Camera.FieldOfView
local FisheyeEffectAlpha = 0
local Water = nil

local function UpdateEffects()
	local old = Water
	Water = CameraInWaterDetector.CurrentBody.Value
	local isInWater = Water ~= nil
	
	ColorCorrectionEffect.Enabled = isInWater
	ColorCorrectionEffect.TintColor = isInWater and WhiteColor:lerp(Water.Color, WaterTintAlpha) or WhiteColor
	BlurEffect.Enabled = isInWater
	SoundEffect1.Enabled = isInWater
	SoundEffect2.Enabled = isInWater
	
	if old ~= nil and Water == nil then
		Camera.FieldOfView = OriginalFOV
		FisheyeEffectAlpha = 0
	elseif old == nil and Water ~= nil then
		OriginalFOV = Camera.FieldOfView
	end
end

CameraInWaterDetector.CurrentBody.Changed:Connect(UpdateEffects)
RunService.RenderStepped:Connect(function(deltaTime)
	UpdateEffects()
	
	if Water ~= nil then
		FisheyeEffectAlpha = FisheyeEffectAlpha + deltaTime / FisheyeEffectCycleDuration
		FisheyeEffectAlpha = FisheyeEffectAlpha - math.floor(FisheyeEffectAlpha)
		
		local alpha = math.sin(math.pi * 2 * (FisheyeEffectAlpha - 0.25)) / 2 + 0.5
		Camera.FieldOfView = FisheyeFovStart + (FisheyeFovPeak - FisheyeFovStart) * alpha
	end
end)

UpdateEffects()
