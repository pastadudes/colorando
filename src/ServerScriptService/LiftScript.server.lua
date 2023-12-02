GameLib = require(game.ReplicatedStorage.GameLib)

LiftModel = workspace.Lift.Platform
LiftBlock = workspace.Lift.Platform.PrimaryPart
LoweringSound = workspace.Lift.Platform.PrimaryPart.LoweringSound
RunGameLoopFunction = script.Parent.RoundController.RunGameLoop
GameState = game.ReplicatedStorage.Game.GameState

OriginalCFrame = LiftModel:GetPrimaryPartCFrame()
AnimateDebounce = true

-- Animation stuff
GameState.Changed:Connect(function(value)
	if value == "Intermission" and AnimateDebounce then
		AnimateDebounce = false
		
		LoweringSound.TimePosition = 1.2
		LoweringSound:Resume()
		
		wait(3.5)
		
		LiftBlock:SetNetworkOwner(nil)
		LiftBlock.BodyVelocity.Velocity = Vector3.new(0, -5, 0)
		
		wait(3.0)
		
		-- Reset to original position.
		LiftBlock.BodyVelocity.Velocity = Vector3.new(0, 5, 0)
		LoweringSound:Stop()
		
		AnimateDebounce = true
	end
end)

-- Set up the Lift's behavior, and protect against exploiters who may try to send the lift to the void to get it deleted.
LiftBlock:SetNetworkOwner(nil)
LiftBlock.BodyVelocity.Velocity = Vector3.new(0, 5, 0)

-- Determine who's in the lift and who's not.
LiftBlock.Touched:Connect(function(other)
	local character = other.Parent
	local player = character and game.Players:GetPlayerFromCharacter(character)
	if player ~= nil and player.PlayState.Value == "None" and GameLib.GetProximity(player, LiftBlock.Position) < LiftBlock.Size.Magnitude then -- Because I don't care to do strict box calculations. At least they're in the lobby.
		player.PlayState.Value = "WaitingInLift"
		RunGameLoopFunction:Invoke()
	end
end)
spawn(function(...)
	while true do
		wait(0.2)
		
		for i, player in ipairs(game.Players:GetPlayers()) do
			local position = Vector3.new(0, 0, 0)
			if player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart") ~= nil then
				position = player.Character.HumanoidRootPart.Position
			end
			
			local isInLift = false
			local point = OriginalCFrame:PointToObjectSpace(position)
			if math.abs(point.X) < LiftBlock.Size.X / 2 + 1 and math.abs(point.Y) < 60 / 2 and math.abs(point.Z) < LiftBlock.Size.Z / 2 + 1 then
				isInLift = true
			end
			if not isInLift and player.PlayState.Value == "WaitingInLift" then
				player.PlayState.Value = "None"
			end
		end
	end
end)
