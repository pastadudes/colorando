-- Controls the game's behavior.
-- 
-- ForbiddenJ

RunService = game:GetService("RunService")

GameLib = require(game.ReplicatedStorage.GameLib)
MapScriptLib = require(game.ServerScriptService.MapScript)
MapBehaviors = require(script.MapBehaviors)

MaxMapTime = 120
IntermissionTime = 5
MapVotingTime = 30

MultiplayerContainer = workspace.Multiplayer
HumanoidStoragePlate = workspace.HumanoidStorage.Baseplate
MapsFolder           = game.ServerStorage.InstalledMaps
GameConfig           = game.ReplicatedStorage.Config
GameFolder           = game.ReplicatedStorage.Game
GameState            = GameFolder.GameState
CurrentMap           = GameFolder.CurrentMap
NextButtonID         = GameFolder.NextButtonID
NextMapName          = GameFolder.NextMapName
NextMapOverride      = GameFolder.NextMapOverride
TimerAlpha           = GameFolder.TimerAlpha
OnEcoSpawned         = GameFolder.OnEcoSpawned
OnPlayerSurvived     = GameFolder.OnPlayerSurvived
ExitOpen             = GameFolder.ExitOpen
OnButton             = game.ServerStorage.Bindables.BtnPress
EventStringRunner    = script.EventStringRunner

IsGameLoopRunning = false
MapValues = nil
CurrentMapButtons = nil
CurrentMapExitRegions = nil

function DoMapChoosingPhase()
	-- Have players vote for a map
	if GameConfig.MapVotingEnabled.Value and #MapsFolder:GetChildren() > 1 then
		NextMapOverride.Value = ""
		GameState.Value = "Map Voting"
		local timeLeft = MapVotingTime
		while timeLeft > 0 do
			wait(1)
			if #game.Players:GetPlayers() > 1 then
				timeLeft = timeLeft - 1
			end
			TimerAlpha.Value = timeLeft / MapVotingTime
			
			local allVoted = true
			for i, player in ipairs(game.Players:GetPlayers()) do
				if player.MapVote.Value == "" then
					allVoted = false
					break
				end
			end
			if allVoted or #GameLib.GetQueuedPlayers() == 0 or NextMapOverride.Value ~= "" then
				break
			end
		end
	end
	
	-- Tally map votes.
	local votes = {}
	if GameConfig.MapVotingEnabled.Value then
		for i, player in ipairs(game.Players:GetPlayers()) do
			local vote = player.MapVote.Value
			if vote ~= "" then
				table.insert(votes, vote)
			end
			player.MapVote.Value = ""
		end
	end
	
	-- Choose a map to do next.
	local selectionName = "_Random"
	if NextMapOverride.Value == "" then
		if #votes > 0 then
			math.randomseed(tick())
			selectionName = votes[math.random(1, #votes)]
		end
	else
		selectionName = NextMapOverride.Value
	end
	if selectionName == "_Random" then
		local mapList = MapsFolder:GetChildren()
		if #mapList > 0 then
			local mapPrefab = mapList[math.random(1, #mapList)]
			selectionName = mapPrefab.Name
		else
			warn("The game cannot start because there is no map to play.")
			selectionName = "_None"
		end
	end
	
	return selectionName
end
function DoIntermissionPhase(mapName)
	-- Start Intermission
	GameState.Value = "Intermission"
	NextMapName.Value = mapName
	
	-- Load the map into ReplicatedStorage during Intermission to give clients time to download the map.
	local map = MapsFolder:FindFirstChild(mapName):Clone()
	map.Name = "Map"
	local mapInfo = MapBehaviors.PrepareMapObjects(map)
	map.Parent = game.ReplicatedStorage
	
	-- Intermission Countdown
	local timeLeft = IntermissionTime
	while timeLeft > 0 do
		wait(0.1)
		timeLeft = timeLeft - 0.1
		TimerAlpha.Value = timeLeft / IntermissionTime
	end
	
	return mapInfo
end
function DoPlayingPhase(mapInfo)
	local map = mapInfo.Map
	
	-- Teleport everyone playing to a safe spot.
	for i, player in ipairs(GameLib.GetQueuedPlayers()) do
		player.PlayState.Value = "Waiting"
		TeleportPlayer(player, HumanoidStoragePlate)
		
	end
	
	-- Replace the old map with the new map.
	if CurrentMap.Value ~= nil then
		CurrentMap.Value:Destroy()
	end
	CurrentMap.Value = map
	
	-- Run the map?
	if #GameLib.GetQueuedPlayers() > 0 then
		-- Game State Management
		GameState.Value = "Playing"
		ExitOpen.Value = false
		CurrentMap.Value = map
			
		-- Integrate the map into the game world.
		MapValues = {
			Map = map,
			Script = MapScriptLib,
			Button = OnButton.Event,
			btnFuncs = {},
		}
		MultiplayerContainer.GetMapVals.OnInvoke = GetMapVals
		NextButtonID.Value = 1
		map.Name = "Map"
		map.Parent = MultiplayerContainer
		
		-- Handle buttons
		CurrentMapButtons = mapInfo.Buttons
		for i, button in ipairs(CurrentMapButtons) do
			button._ButtonState.Changed:Connect(function(buttonState)
				if buttonState == "Pressed" then
					local touchors = button._GetTouchedPlayers:Invoke()
					OnButtonPress(#touchors == 1 and touchors[1] or nil, i)
				end
			end)
		end
		UpdateButtonStates()
		
		-- Remember ExitRegions
		CurrentMapExitRegions = mapInfo.ExitRegions
		
		wait(0.1)
		
		-- Teleport everyone to the map.
		for i, player in ipairs(GameLib.GetQueuedPlayers()) do
			player.PlayState.Value = "Playing"
			TeleportPlayer(player, map.Spawn)
			OnEcoSpawned:FireClient(player, map.Spawn)
			local skyEvent = game.ReplicatedStorage:WaitForChild("skyEvent")
			skyEvent:FireClient(player)
		end
		
		-- Keep group buttons from having a higher press count requirement than there are living players.
		local keepLoopAlive = true
		spawn(function(...)
			while keepLoopAlive do
				local playerCount = #GameLib.GetPlayersWithPlayState("Playing")
				for i, button in ipairs(CurrentMapButtons) do
					button._BashCountNeeded.Value = math.max(1, math.min(button._BashCountNeeded.Value, playerCount))
				end
				
				wait(1)
			end
		end)
		
		wait(GameLib.MapBehaviorStartDelay)
		
		-- Run map code.
		EventStringRunner.Disabled = true
		EventStringRunner.Disabled = false
		local eventStringObj = map:FindFirstChild("EventString")
		local eventScript = map:FindFirstChild("EventScript")
		if eventStringObj == nil and eventScript ~= nil and eventScript:IsA("Script") then
			eventScript.Disabled = false
		end
		
		-- Wait until either the players escape or a countdown ends.
		local timeLeft = MaxMapTime
		TimerAlpha.Value = 1
		while timeLeft > 0 and #GameLib.GetPlayersWithPlayState("Playing") > 0 do
			wait(1)
			timeLeft = timeLeft - 1
			TimerAlpha.Value = timeLeft / MaxMapTime
		end
		
		-- End the game and kill all players' Humanoids still in the map.
		for i, player in ipairs(GameLib.GetPlayersWithPlayState("Playing")) do
			local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
			if humanoid ~= nil then
				humanoid.Health = 0
			end
			player.PlayState.Value = "None"
		end
		keepLoopAlive = false
		
		TimerAlpha.Value = 0
		GameState.Value = "Idle"
	end
end
function RunGameLoop()
	if not IsGameLoopRunning then
		IsGameLoopRunning = true
		
		while #GameLib.GetQueuedPlayers() > 0 do
			local mapName =
				DoMapChoosingPhase()
			if mapName == "_None" then
				break
			end
			local mapInfo =
				DoIntermissionPhase(mapName)
			DoPlayingPhase(mapInfo)
		end
		
		IsGameLoopRunning = false
	end
end
function TeleportPlayer(player, locationBase)
	assert(typeof(player) == "Instance" and player:IsA("Player"))
	assert(typeof(locationBase) == "Instance" and locationBase:IsA("BasePart"))
	
	local torso = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if torso ~= nil and torso:IsA("BasePart") then
		-- Figure out a random location on the plate.
		local newX = (math.random() - 0.5) * (locationBase.Size.X * 3 / 4)
		local newZ = (math.random() - 0.5) * (locationBase.Size.Z * 3 / 4)
		
		-- Teleport the character.
		torso.CFrame = locationBase.CFrame * CFrame.new(newX, locationBase.Size.Y / 2 + 3, newZ)
	end
end
function UpdateButtonStates()
	ExitOpen.Value = NextButtonID.Value > #CurrentMapButtons
	for i, button in ipairs(CurrentMapButtons) do
		local buttonState = "Inactive"
		if i == NextButtonID.Value then
			local groupButtonMark = button:FindFirstChild("Group")
			-- Maybe support NumberValues in the future?
			if groupButtonMark ~= nil then
				buttonState = "ActiveGroup"
				button._BashCountNeeded.Value = math.ceil(GameLib.GroupButtonPlayerPercentage * #GameLib.GetPlayersWithPlayState("Playing"))
			else
				buttonState = "Active"
			end
		elseif i < NextButtonID.Value then
			buttonState = "Pressed"
		end
		button._ButtonState.Value = buttonState
	end
end
function OnButtonPress(player, buttonId)
	local button = CurrentMapButtons[buttonId]
	if NextButtonID.Value == buttonId then
		NextButtonID.Value = buttonId + 1
		UpdateButtonStates()
		
		-- Trigger everything in the map with special tags.
		MapBehaviors.TriggerEvents(CurrentMap.Value, buttonId)
		
		-- Let the map's EventScript know a button was pressed.
		OnButton:Fire(player, buttonId)
	end
end
function GetMapVals()
	return MapValues
end
function PlayerVoteForMap(player, mapName)
	assert(typeof(mapName) == "string")
	assert(MapsFolder:FindFirstChild(mapName) ~= nil or mapName == "_Random") -- Is the map installed?
	
	player.MapVote.Value = mapName
end

-- Event Connections
script.RunGameLoop.OnInvoke = RunGameLoop
GameFolder.VoteForMap.OnServerInvoke = PlayerVoteForMap
game.Players.PlayerAdded:Connect(function(player)
	local playState = Instance.new("StringValue") -- Can be set to "None", "Waiting", "WaitingInLift", or "Playing".
	playState.Name = "PlayState"
	playState.Value = "None"
	playState.Parent = player
	local mapVote = Instance.new("StringValue")
	mapVote.Name = "MapVote"
	mapVote.Value = ""
	mapVote.Parent = player
	
	-- When a player dies while in the game, set their PlayState to None.
	player.CharacterRemoving:Connect(function(...)
		if playState.Value == "Playing" or playState.Value == "Waiting" or playState.Value == "WaitingInLift" then
			playState.Value = "None"
		end
	end)
end)
RunService.Heartbeat:Connect(function(deltaTime)
	if GameState.Value == "Playing" and ExitOpen.Value then
		for i, player in ipairs(GameLib.GetPlayersWithPlayState("Playing")) do
			local torso = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if torso ~= nil then
				for i, exit in ipairs(CurrentMapExitRegions) do
					if GameLib.IsLocationWithinBlock(exit, torso.Position) then
						player.PlayState.Value = "Waiting"
						OnPlayerSurvived:FireClient(player)
					end
				end
			end
		end
	end
end)
