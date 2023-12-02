-- Manages the air supply and kills the humanoid when it runs out.
-- 
-- Thank you guy at this link for helping me tune the air loss rate better.
-- https://www.youtube.com/watch?time_continue=170&v=arLJ3tuWF9Y
-- 
-- By ForbiddenJ

RunService = game:GetService("RunService")

WaterLib = require(game.ReplicatedStorage.WaterLib)

BreathLossRate = 8
BreathLossAcidRate = 30
BreathRecoveryRate = 20
BreathRecoveryCooldown = 2
BreathSplashPenaltyMax = 20
BreathSplashAcidPenaltyRate = 20 -- Maybe?
BreathSplashPenaltyRecoveryRate = 6 -- Maybe?
AirMax = WaterLib.AirMax

Humanoid = script.Parent.Parent.Humanoid
Air = script.Parent:WaitForChild("Air")
AirTank = script.Parent:WaitForChild("AirTank")
SplashAirPenalty = script.Parent:WaitForChild("SplashAirPenalty")
CurrentBody = script.Parent:WaitForChild("CurrentBody")
IsBreathEnabled = script.Parent:WaitForChild("IsBreathEnabled")
OnBreathUpdate = script.Parent:WaitForChild("OnBreathUpdate")

BreathRecoveryWait = 0

function DamageAirSupply(amount)
	-- Inflict damage upon the air supply.
	local airDebt = amount
	local function takeAir(value)
		local takeAmount = math.min(airDebt, value.Value)
		value.Value = math.max(0, value.Value - takeAmount)
		airDebt = airDebt - takeAmount
	end
	takeAir(AirTank)
	takeAir(Air)
		
	-- When the air supply is out, the character dies.
	if Air.Value <= 0 then
		Humanoid.Health = 0
		script.Disabled = true
	end
end

RunService.Heartbeat:Connect(function(deltaTime)
	if IsBreathEnabled.Value then
		if CurrentBody.Value ~= nil then
			BreathRecoveryWait = BreathRecoveryCooldown
			
			-- How much breath to take away?
			local waterState = WaterLib.GetWaterState(CurrentBody.Value)
			if waterState ~= nil and string.lower(waterState) == "acid" then
				DamageAirSupply(BreathLossAcidRate * deltaTime)
				SplashAirPenalty.Value = math.min(SplashAirPenalty.Value + BreathSplashAcidPenaltyRate * deltaTime, BreathSplashPenaltyMax)
			elseif waterState ~= nil and string.lower(waterState) == "lava" then
				DamageAirSupply((WaterLib.AirTankMax + WaterLib.AirMax) * 10)
			else
				DamageAirSupply(BreathLossRate * deltaTime)
			end
		else
			BreathRecoveryWait = math.max(0, BreathRecoveryWait - deltaTime)
			if BreathRecoveryWait <= 0 then
				SplashAirPenalty.Value = math.max(SplashAirPenalty.Value - BreathSplashPenaltyRecoveryRate * deltaTime, 0)
				Air.Value = math.min(AirMax, Air.Value + BreathRecoveryRate * deltaTime)
			end
		end
		
		-- This is so the GUI can update once every frame, instead of once for each changed variable, because it's
		-- likely that several variables will change in the same frame.
		OnBreathUpdate:Fire()
	end
end)
CurrentBody.Changed:Connect(function(value)
	if value ~= nil and IsBreathEnabled.Value then
		local waterState = WaterLib.GetWaterState(value)
		if string.lower(waterState) == "acid" then
			DamageAirSupply(SplashAirPenalty.Value)
			SplashAirPenalty.Value = 0
		end
	end
end)
IsBreathEnabled.Changed:Connect(function(value)
	if not value then
		-- Reset the values.
		Air.Value = AirMax
		AirTank.Value = 0
		SplashAirPenalty.Value = 0
		BreathRecoveryWait = 0
	end
	
	OnBreathUpdate:Fire()
end)

Air.Value = AirMax
