-- Allows players to spectate other players.
-- 
-- ForbiddenJ

ContextActionService = game:GetService("ContextActionService")

Camera = workspace.Camera
Player = game.Players.LocalPlayer
SpawnNotificationFunction = game.ReplicatedStorage.ClientStorage.SpawnNotification

SpectateTarget = script.Parent.SpectateTarget -- ObjectValue that refers to a Player object or nil.
SpectateControlFrame = script.Parent.BottomHUD.SpectateControlFrame
SpectatePrevButton = script.Parent.BottomHUD.SpectateControlFrame.SpectatePrevButton
SpectateNextButton = script.Parent.BottomHUD.SpectateControlFrame.SpectateNextButton
SpectateTargetText = script.Parent.BottomHUD.SpectateControlFrame.SpectateTargetText
SpectateModeBorder = script.Parent.SpectateModeBorder
SpectateButton = script.Parent.BottomHUD.SpectateButton

LastSpectated = nil
SpectateTargetEventConnections = {}

function TargetCameraOnPlayer(player)
	assert(typeof(player) == "Instance" and player:IsA("Player"))
	
	-- Try to target the camera on the other player. Fallback to the local player's
	-- character if the other player's character is dead and is not the local player.
	local humanoid = (player.Character and player.Character:WaitForChild("Humanoid", 0.5)) or
		(Player.Character and Player.Character:WaitForChild("Humanoid", 0.5))
	
	Camera.CameraSubject = humanoid
end
function UpdateSpectateGui()
	local targetPlayer = SpectateTarget.Value
	local isSpectating = targetPlayer ~= nil
	
	SpectateControlFrame.IsDisplayed.Value = isSpectating
	--SpectateControlFrame.Visible = isSpectating
	SpectateModeBorder.Visible = isSpectating
	SpectateButton.Image = not isSpectating and "rbxassetid://54479722" or "rbxasset://textures/StudioSharedUI/close.png"
	
	if targetPlayer ~= LastSpectated then
		-- Clear the old event connections.
		for i, v in pairs(SpectateTargetEventConnections) do
			v:Disconnect()
			SpectateTargetEventConnections[i] = nil
		end
		
		if isSpectating then
			-- Spectate the target player.
			SpectateTargetText.Text = targetPlayer.Name
			SpectateTargetEventConnections[1] = targetPlayer.CharacterAdded:Connect(UpdateSpectateGui)
		else
			-- Reset the GUI to normal.
			SpectateTargetText.Text = ""
			TargetCameraOnPlayer(Player)
		end
	end
	
	-- Exempt from player changes for CharacterAdded events.
	if isSpectating then
		TargetCameraOnPlayer(SpectateTarget.Value)
	end
	
	LastSpectated = SpectateTarget.Value
end
function SpectateToggle()
	if SpectateTarget.Value == nil then
		SpectateTarget.Value = Player
	else
		SpectateTarget.Value = nil
	end
end
function SpectatePrevious()
	local targetPlayer = SpectateTarget.Value
	if targetPlayer ~= nil then
		local players = game.Players:GetPlayers()
		
		-- Find the index of the player we're currently spectating.
		local currentI = nil
		for i, player in ipairs(players) do
			if player == targetPlayer then
				currentI = i
				break
			end
		end
		
		-- What's the previous valid player index?
		local targetI = currentI > 1 and currentI - 1 or #players
		
		-- Spectate the player at targetI.
		SpectateTarget.Value = players[targetI]
	end
end
function SpectateNext()
	local targetPlayer = SpectateTarget.Value
	if targetPlayer ~= nil then
		local players = game.Players:GetPlayers()
		
		-- Find the index of the player we're currently spectating.
		local currentI = nil
		for i, player in ipairs(players) do
			if player == targetPlayer then
				currentI = i
				break
			end
		end
		
		-- What's the next valid player index?
		local targetI = currentI < #players and currentI + 1 or 1
		
		-- Spectate the player at targetI.
		SpectateTarget.Value = players[targetI]
	end
end
function ActionHandler(actionName, inputState, inputObj)
	if actionName == "SpectateToggle" and inputState == Enum.UserInputState.Begin then
		SpectateToggle()
		return Enum.ContextActionResult.Sink
	elseif SpectateTarget.Value ~= nil then
		if actionName == "SpectatePrevious" and inputState == Enum.UserInputState.Begin then
			SpectatePrevious()
			return Enum.ContextActionResult.Sink
		elseif actionName == "SpectateNext" and inputState == Enum.UserInputState.Begin then
			SpectateNext()
			return Enum.ContextActionResult.Sink
		end
	end
	return Enum.ContextActionResult.Pass
end

UpdateSpectateGui()

SpectateTarget.Changed:Connect(UpdateSpectateGui)

-- Bind all the inputs!
SpectateButton.MouseButton1Click:Connect(SpectateToggle)
SpectatePrevButton.MouseButton1Click:Connect(SpectatePrevious)
SpectateNextButton.MouseButton1Click:Connect(SpectateNext)
ContextActionService:BindActionAtPriority("SpectateToggle", ActionHandler, false, 3500, Enum.KeyCode.ButtonY, Enum.KeyCode.Y)
ContextActionService:BindActionAtPriority("SpectatePrevious", ActionHandler, false, 3500, Enum.KeyCode.ButtonL1, Enum.KeyCode.Q)
ContextActionService:BindActionAtPriority("SpectateNext", ActionHandler, false, 3500, Enum.KeyCode.ButtonR1, Enum.KeyCode.E)

-- If the local player joins a round, automatically disable Spectate Mode.
Player.PlayState.Changed:Connect(function(value)
	if value == "Playing" then
		SpectateTarget.Value = nil
	end
end)

-- If the player that is being viewed leaves the game, then reset the target to the local player.
game.Players.PlayerRemoving:Connect(function(player)
	if player == SpectateTarget.Value then
		SpectateTarget.Value = Player
	end
end)
