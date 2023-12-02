-- Allows the character to climb ladders and trusses like a rocket while
-- continuously jumping and walking into them. Overrides default jumping
-- velocity.
-- 
-- Thank you for your forum post Crazyblox! Saved me a lot of time figuring
-- the solution out.
-- 
-- https://devforum.roblox.com/t/humanoid-jump-state-not-triggering-from-truss-jump-with-shiftlock-first-person/242877
--
-- ForbiddenJ

Humanoid = script.Parent.Humanoid
RootPart = Humanoid.RootPart

Humanoid.Jumping:Connect(function(isJumping)
    if isJumping then
	    RootPart.Velocity = Vector3.new(RootPart.Velocity.X, Humanoid.JumpPower * 1.1, RootPart.Velocity.Z)
    end
end)
