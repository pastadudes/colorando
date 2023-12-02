-- Manages the status frame.
-- 
-- ForbiddenJ

RunService = game:GetService("RunService")

WaterLib = require(game.ReplicatedStorage.WaterLib)

NormalActivityTimer = 3
LowOxygenWarningThreshold = 60
AcidWarningFrequency = 1.5
AcidWarningColor = Color3.new(0, 1, 0)

AirMax = WaterLib.AirMax
AirTankMax = WaterLib.AirTankMax

Player = game.Players.LocalPlayer
AirLabel = script.Parent.AirLabel
AirMeter = script.Parent
AirMeterBar = script.Parent.AirBar
AirPenaltyBar = script.Parent.AirBar.PenaltyBar
AirTankMeterBar = script.Parent.AirTankBar
AirTankPenaltyBar = script.Parent.AirTankBar.PenaltyBar
IsActive = script.Parent.IsActive

ColorTweens = {
	{
		-- The target object.
		Object = AirLabel,
		-- The target property name of the object.
		Property = "TextColor3",
		-- Will also include a NormalValue field, which is filled in later.
		NormalValue = nil,
		-- WarningTarget can be left out to implicitly mean it's not interpolated with warning colors.
		WarningTarget = Color3.new(1, 0.1, 0.1),
		-- Can be left out to implicitly mean false.
		IsInterpolatedWithAcidFlash = false,
	},
	{Object = AirLabel, Property = "TextStrokeColor3", IsInterpolatedWithAcidFlash = true},
	{Object = AirMeter, Property = "BackgroundColor3", WarningTarget = Color3.new(0.2, 0.05, 0.02)},
	{Object = AirMeter, Property = "BorderColor3", IsInterpolatedWithAcidFlash = true},
	{Object = AirMeterBar, Property = "BackgroundColor3", WarningTarget = Color3.new(1, 1, 1)},
	{Object = AirPenaltyBar, Property = "BackgroundColor3", WarningTarget = Color3.new(1, 0.1, 1)},
	{Object = AirTankMeterBar, Property = "BackgroundColor3", WarningTarget = Color3.new(1, 0.7, 0.1)},
	{Object = AirTankPenaltyBar, Property = "BackgroundColor3", WarningTarget = Color3.new(1, 0.1, 1)},
}
for i, entry in pairs(ColorTweens) do -- Insert a NormalValue field into each entry in ColorTweens.
	entry.NormalValue = entry.Object[entry.Property]
end

Character = nil
CharacterWaterState = nil
CharacterEventHooks = {}
AcidWarningAlpha = 1
ActivityTimer = 0

function UpdateAirMeter(deltaTime)
	deltaTime = deltaTime or 0
	
	local warningAlpha = 0
	local waterState = CharacterWaterState ~= nil and WaterLib.GetWaterState(CharacterWaterState.CurrentBody.Value) or nil
	local airLabelText = "∞" -- Infinity symbol.
	
	if CharacterWaterState ~= nil and CharacterWaterState.IsBreathEnabled.Value then
		-- Update the various bars.
		local airTankPenalty = math.min(CharacterWaterState.SplashAirPenalty.Value, CharacterWaterState.AirTank.Value)
		local airPenalty = math.clamp(CharacterWaterState.SplashAirPenalty.Value - airTankPenalty, 0, CharacterWaterState.Air.Value)
		airLabelText = string.format("%i", CharacterWaterState.Air.Value + CharacterWaterState.AirTank.Value)
		AirMeterBar.Size = UDim2.new(CharacterWaterState.Air.Value / AirMax, 0, 1, 0)
		AirTankMeterBar.Size = UDim2.new(CharacterWaterState.AirTank.Value / AirTankMax, 0, 1, -1)
		AirPenaltyBar.Position = UDim2.new(1 - airPenalty / CharacterWaterState.Air.Value, 0, 0, 0)
		AirPenaltyBar.Size = UDim2.new(airPenalty / CharacterWaterState.Air.Value, 0, 1, 0)
		AirTankPenaltyBar.Position = UDim2.new(1 - airTankPenalty / CharacterWaterState.AirTank.Value, 0, 0, 0)
		AirTankPenaltyBar.Size = UDim2.new(airTankPenalty / CharacterWaterState.AirTank.Value, 0, 1, 0)
		
		-- How much to warn the player?
		warningAlpha = 1 - math.min((CharacterWaterState.Air.Value + CharacterWaterState.AirTank.Value) / LowOxygenWarningThreshold, 1)
		
		-- Should be force-shown?
		if waterState ~= nil or CharacterWaterState.Air.Value < AirMax then
			ActivityTimer = NormalActivityTimer
			IsActive.Value = true
		else
			ActivityTimer = math.max(ActivityTimer - deltaTime, 0)
			IsActive.Value = ActivityTimer > 0
		end
	else
		-- Reflect that no info is available.
		AirMeterBar.Size = UDim2.new(1, 0, 1, 0)
		AirTankMeterBar.Size = UDim2.new(0, 0, 1, 0)
		AirPenaltyBar.Size = UDim2.new(0, 0, 1, 0)
		AirTankPenaltyBar.Size = UDim2.new(0, 0, 1, 0)
		
		-- Should be force-shown?
		ActivityTimer = 0
		IsActive.Value = false
	end
	
	-- If is in acid, flash green and warn player.
	if waterState == "acid" and CharacterWaterState.IsBreathEnabled.Value then
		AcidWarningAlpha = AcidWarningAlpha + AcidWarningFrequency * deltaTime
		AcidWarningAlpha = AcidWarningAlpha - math.floor(AcidWarningAlpha)
		
		-- Interpolate acid flashing into the other warning.
		warningAlpha = warningAlpha + (1 - warningAlpha) * (1 - AcidWarningAlpha)
		
		airLabelText = airLabelText .. " - Danger: Acid!"
	else
		AcidWarningAlpha = 1
	end
	
	-- Color Tweening for Warnings
	for i, entry in pairs(ColorTweens) do
		if entry.WarningTarget ~= nil then
			-- Glow red when running low on air.
			entry.Object[entry.Property] = entry.NormalValue:lerp(entry.WarningTarget, warningAlpha)
		elseif entry.IsInterpolatedWithAcidFlash then
			-- Acid flashing.
			entry.Object[entry.Property] = AcidWarningColor:lerp(entry.NormalValue, AcidWarningAlpha)
		end
	end
	
	AirLabel.Text = airLabelText
end
function BindToCharacterAsync(character)
	for i, connection in pairs(CharacterEventHooks) do
		connection:Disconnect()
		CharacterEventHooks[i] = nil
	end
	if character ~= nil then
		local folder = character:WaitForChild("Water", 2)
		folder:WaitForChild("Air", 2)
		folder:WaitForChild("AirTank", 2)
		folder:WaitForChild("SplashAirPenalty", 2)
		folder:WaitForChild("CurrentBody", 2)
		folder:WaitForChild("IsBreathEnabled", 2)
		folder:WaitForChild("OnBreathUpdate", 2)
		CharacterWaterState = folder
		
		CharacterEventHooks[1] = CharacterWaterState.OnBreathUpdate.Event:Connect(UpdateAirMeter)
	end
	Character = character
	UpdateAirMeter()
end

RunService.RenderStepped:Connect(UpdateAirMeter)
Player.CharacterAdded:Connect(BindToCharacterAsync)

UpdateAirMeter()
BindToCharacterAsync(Player.Character)
