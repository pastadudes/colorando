-- Hat Sanitizer Script
-- 
-- Creator: ForbiddenJ
-- 
-- This basic script ensures that player hats are not able to run scripts.
-- 
-- The reason I did this is because there was an incident where hats were scripted to give
-- specific players server-scripting privileges in games, and it still seems to be possible
-- to do.
-- 
-- With a bunch of players now able to upload hats and such under the "UGC Catalog", I figured
-- that it might be possible for them insert potentially-malicious scripts, whether
-- intentionally or by accident, and then players spawn them into games, thereby launching
-- such scripts.

local PlayersService = game:GetService("Players")

-- Watch player characters.
local function BindPlayer(player)
	local function OnSpawning()
		local character = player.Character
		
		for i, accessory in ipairs(character:GetDescendants()) do
			if accessory:IsA("Accessory") then
				local isScripted = false
				
				for i, thing in ipairs(accessory:GetDescendants()) do
					if thing:IsA("BaseScript") then
						thing:Destroy()
						isScripted = true
					end
				end
			end
		end
	end
	
	player:GetPropertyChangedSignal("Character"):Connect(OnSpawning)
	player.CharacterAdded:Connect(OnSpawning)
end
