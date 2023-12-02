-- Modifies the character's basic movement behaviors for Open Flood Test.

local PhysicsService = game:GetService("PhysicsService")
local Humanoid = script.Parent.Humanoid

-- Set the humanoid's WalkSpeed to match that of FE2.
Humanoid.WalkSpeed = 20

-- Set every character part to the collision group "PlayerChars".
for i, item in ipairs(script.Parent:GetChildren()) do
	if item:IsA("BasePart") then
		PhysicsService:SetPartCollisionGroup(item, "PlayerChars")
	end
end

-- There was a script to make people reset when they sit here

