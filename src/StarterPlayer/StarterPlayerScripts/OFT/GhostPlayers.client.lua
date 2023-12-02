-- Depending on the player's preference, this fades away other players.
-- 
-- ForbiddenJ

RunService = game:GetService("RunService")

FullyOpaqueDistance = 32

LocalPlayer = game.Players.LocalPlayer
GhostPlayersSetting = game.ReplicatedStorage.ClientConfig.GhostPlayers

PlayerCharacters = {} -- List of character models indexed by player objects.

function RegisterPlayer(player)
	player.CharacterAdded:Connect(function(character)
		PlayerCharacters[player] = character
		if GhostPlayersSetting.Value == 2 then
			SetTransparency(character, 1)
		end
	end)
	player.CharacterRemoving:Connect(function(character)
		PlayerCharacters[player] = nil
	end)
	
	PlayerCharacters[player] = player.Character
	if player.Character ~= nil and GhostPlayersSetting.Value == 2 then
		SetTransparency(player.Character, 1)
	end
end
function SetTransparency(character, transparency)
	assert(typeof(character) == "Instance" and character:IsA("Model"), "Must provide a valid Model.")
	assert(typeof(transparency) == "number", "Must provide a valid number for transparency.")
	
	local roundedTransparency = math.ceil(transparency * 10) / 10
	
	if character ~= PlayerCharacters[LocalPlayer] then
		for i, item in ipairs(character:GetDescendants()) do
			if item:IsA("BasePart") then
				item.LocalTransparencyModifier = roundedTransparency
			end
		end
	end
end
function Update()
	if GhostPlayersSetting.Value == 1 then
		local playerTorso = PlayerCharacters[LocalPlayer] and PlayerCharacters[LocalPlayer]:FindFirstChild("HumanoidRootPart")
		local playerPosition = playerTorso ~= nil and playerTorso.Position or Vector3.new(0, 0, 0)
		
		for player, character in pairs(PlayerCharacters) do
			if player ~= LocalPlayer then
				local rootPart = character:FindFirstChild("HumanoidRootPart")
				local magnitude = rootPart ~= nil and (rootPart.Position - playerPosition).Magnitude or FullyOpaqueDistance
				local transparency = 1 - math.min(magnitude / FullyOpaqueDistance, 1)
				SetTransparency(character, transparency)
			end
		end
	end
end

for i, player in ipairs(game.Players:GetPlayers()) do
	RegisterPlayer(player)
end
game.Players.PlayerAdded:Connect(RegisterPlayer)

GhostPlayersSetting.Changed:Connect(function(value)
	if value == 0 then
		for player, character in pairs(PlayerCharacters) do
			SetTransparency(character, 0)
		end
	elseif value == 2 then
		for player, character in pairs(PlayerCharacters) do
			SetTransparency(character, 1)
		end
	end
end)
--spawn(function(...)
--	while true do
--		wait(0.2)
--		Update()
--	end
--end)
RunService.RenderStepped:Connect(Update)
