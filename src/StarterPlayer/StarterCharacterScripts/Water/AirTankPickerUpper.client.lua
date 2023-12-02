-- Allows the player to make use of air tanks.
-- 
-- ForbiddenJ

TweenService = game.TweenService

SoundName = "AirTankPickupSound"
SoundId = "rbxassetid://12222095"

WaterLib = require(game.ReplicatedStorage.WaterLib)

Character = script.Parent.Parent

Sound = game.SoundService:FindFirstChild(SoundName)

function IsAirTank(object)
	return typeof(object) == "Instance" and object.Name == "AirTank" and object:IsA("Model")
end
function TouchedAirTank(airTank)
	if IsAirTank(airTank) and airTank:FindFirstChild("_AlreadyCollected") == nil then
		-- Mark the tank as collected
		local collectedTag = Instance.new("ObjectValue")
		collectedTag.Name = "_AlreadyCollected"
		collectedTag.Parent = airTank
		
		-- Hide the air bubble
		for i, item in pairs(airTank:GetDescendants()) do
			if item:IsA("BasePart") then
				local tween = TweenService:Create(item, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Transparency = 1})
				game.Debris:AddItem(tween, 1)
				tween:Play()
			elseif item:IsA("ParticleEmitter") then
				item.Enabled = false
			end
		end
		
		-- Play a sound.
		Sound:Play()
		
		-- Add air to the player's air tank.
		script.Parent.AirTank.Value = WaterLib.AirTankMax
	end
end
function OnCharacterTouched(otherPart)
	if not otherPart:IsDescendantOf(Character) and otherPart.Name == "Hitbox" and IsAirTank(otherPart.Parent) then
		TouchedAirTank(otherPart.Parent)
	end
end

if Sound == nil then
	Sound = Instance.new("Sound")
	Sound.Name = SoundName
	Sound.SoundId = SoundId
	Sound.Parent = game.SoundService
end

for i, item in ipairs(Character:GetChildren()) do
	if item:IsA("BasePart") then
		item.Touched:Connect(OnCharacterTouched)
	end
end
