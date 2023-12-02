-- Notifies a player that they should look for other mechanisms to activate buttons.
-- 
-- ForbiddenJ

GameLib = require(game.ReplicatedStorage.GameLib)

Player = game.Players.LocalPlayer
SpawnNotificationFunction = game.ReplicatedStorage.ClientStorage.SpawnNotification

Debounce = true

function OnTouch(thing)
	if Debounce and GameLib.IsButton(thing.Parent) and thing.Parent._ButtonState.Value == "Inactive" then
		Debounce = false
		
		SpawnNotificationFunction:Invoke("This button must be activated by another mechanism.", Color3.new(1, 1, 0.2), 8)
		
		wait(6)
		Debounce = true
	end
end

function TryBindToCharacter(character)
	if character then
		for i, item in ipairs(character:GetChildren()) do
			if item:IsA("BasePart") then
				item.Touched:Connect(OnTouch)
			end
		end
	end
end

TryBindToCharacter(Player.Character)
Player.CharacterAdded:Connect(TryBindToCharacter)
