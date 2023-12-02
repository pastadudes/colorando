-- Manages the map list window and enables players to vote on maps.
-- 
-- ForbiddenJ

TweenService = game.TweenService

GameLib = require(game.ReplicatedStorage.GameLib)

TileSpacing = 10
TileWidth = 150
TileHeight = 150
ButtonDisabledColor = Color3.fromRGB(80, 80, 80)

Player = game.Players.LocalPlayer
MapInfoFolder = game.ReplicatedStorage.InstalledMapInfo
MapTilePrefab = game.ReplicatedStorage.Prefabs.GuiMapTile
GameState = game.ReplicatedStorage.Game.GameState
VoteForMapRemote = game.ReplicatedStorage.Game.VoteForMap
UninstallMapRemote = game.ReplicatedStorage.Game.Admin.UninstallMap
OverrideMapVotesRemote = game.ReplicatedStorage.Game.Admin.OverrideMapVotes
MapVotingEnabled = game.ReplicatedStorage.Config.MapVotingEnabled
UIScale = script:FindFirstAncestorWhichIsA("ScreenGui").UIScale
IsMenuOpen = script.Parent.Parent.Parent.IsOpen
CurrentPanelName = script.Parent.Parent.Parent.CurrentPanelName

MapListWindow = script.Parent
SearchBox = script.Parent.SearchFrame.SearchBox
SortTitleButton = script.Parent.SearchFrame.SortTitleButton
SortAuthorButton = script.Parent.SearchFrame.SortAuthorButton
SortDifficultyButton = script.Parent.SearchFrame.SortDifficultyButton
MapListFrame = script.Parent.ListFrame
LoadButton = script.Parent.ListFrame.LoadButton
RemoveButton = script.Parent.ButtonFrame.RemoveButton
OverrideButton = script.Parent.ButtonFrame.OverrideButton
VoteRandomButton = script.Parent.ButtonFrame.VoteRandomButton
VoteButton = script.Parent.ButtonFrame.VoteButton

NormalButtonColor = VoteButton.BackgroundColor3

SelectedSearchTerm = ""
SelectedSortType = 1 -- 1 = Map Title, 2 = Author, 3 = Difficulty
SelectedMapName = nil
SearchResultCache = {}
MapListUpdatesDisabled = false

function UpdateButtons()
	local function update(button, sortId)
		button.BorderSizePixel = SelectedSortType == sortId and 2 or 1
		button.BorderColor3 = SelectedSortType == sortId and Color3.new(0.2, 1, 1) or Color3.new(0, 0, 0)
	end
	
	update(SortTitleButton, 1)
	update(SortAuthorButton, 2)
	update(SortDifficultyButton, 3)
end
function UpdateSearchResults()
	local r = {}
	
	-- Sort out the matching maps.
	for i, map in ipairs(MapInfoFolder:GetChildren()) do
		if SelectedSearchTerm == "" then
			table.insert(r, map)
		else
			local mapTitle = map.Settings.MapName.Value
			local mapCreator = map.Settings.Creator.Value
			local mapDifficultyName = GameLib.DifficultyNames[map.Settings.Difficulty.Value]
			
			local titleMatches = string.find(mapTitle:lower(), SelectedSearchTerm:lower(), 1, true)
			local creatorMatches = string.find(mapCreator:lower(), SelectedSearchTerm:lower(), 1, true)
			local difficultyMatches = string.find(mapDifficultyName:lower(), SelectedSearchTerm:lower(), 1, true)
			
			if titleMatches or creatorMatches or difficultyMatches then
				table.insert(r, map)
			end
		end
	end
	
	-- Sort the maps according to the user's choice.
	if SelectedSortType == 1 then -- Alphabetical
		table.sort(r, function(mapA, mapB)
			return mapA.Settings.MapName.Value < mapB.Settings.MapName.Value
		end)
	elseif SelectedSortType == 2 then -- Creator Name
		table.sort(r, function(mapA, mapB)
			local creatorA = mapA.Settings.Creator.Value
			local creatorB = mapB.Settings.Creator.Value
			
			return creatorA < creatorB or
				(creatorA == creatorB and mapA.Settings.MapName.Value < mapB.Settings.MapName.Value)
		end)
	elseif SelectedSortType == 3 then -- Difficulty
		table.sort(r, function(mapA, mapB)
			local diffA = mapA.Settings.Difficulty.Value
			local diffB = mapB.Settings.Difficulty.Value
			
			return diffA < diffB or
				(diffA == diffB and mapA.Settings.MapName.Value < mapB.Settings.MapName.Value)
		end)
	end
	
	SearchResultCache = r
	return r
end
function UpdateMapListGui(animateTiles)
	-- Make sure all the tiles for this list are present and build a table.
	local tiles = {}
	for i, map in ipairs(SearchResultCache) do
		local tile = MapListFrame:FindFirstChild("Tile_" .. map.Name)
		
		if tile == nil then
			local mapSettings = map.Settings
			local difficulty = mapSettings and mapSettings.Difficulty.Value
			
			-- Make a new button for the map.
			tile = MapTilePrefab:Clone()
			tile.Name = "Tile_" .. map.Name
			tile.Position = UDim2.new(0, 0, 0, 0)
			tile.Parent = MapListFrame
			tile.MapTitle.Text = mapSettings.MapName.Value
			tile.MapImage.Image = "rbxassetid://" .. mapSettings.MapImage.Value
			tile.MapAuthor.Text = mapSettings.Creator.Value
			tile.MapDifficulty.BackgroundColor3 = GameLib.DifficultyColors[difficulty]
			tile.MapDifficulty.Text = GameLib.DifficultyNames[difficulty]
			
			local mapName = map.Name
			tile.MouseButton1Click:Connect(function()
				SelectedMapName = mapName
				UpdateMapSelection()
			end)
		end
		
		table.insert(tiles, tile)
	end
	
	-- Delete tiles that don't belong.
	for i, tile in ipairs(MapListFrame:GetChildren()) do
		local shouldDelete = (tile ~= LoadButton)
		if shouldDelete then
			for i2, map in ipairs(SearchResultCache) do
				if tile.Name == "Tile_" .. map.Name then
					shouldDelete = false
					break
				end
			end
		end
		if shouldDelete then
			tile:Destroy()
		end
	end
	
	-- If the LoadButton tile is visible, add it as the last element.
	if LoadButton.Visible then
		table.insert(tiles, LoadButton)
	end
	
	-- Arrange the tiles.
	local listColumnCount = math.floor((MapListFrame.AbsoluteSize.X / UIScale.Scale - TileSpacing - MapListFrame.ScrollBarThickness) / (TileWidth + TileSpacing))
	local listRowCount = math.ceil(#SearchResultCache / listColumnCount)
	local listColumn = 0
	local listRow = 1
	for i, tile in ipairs(tiles) do
		listColumn = listColumn + 1
		if listColumn > listColumnCount then
			listColumn = 1
			listRow = listRow + 1
		end
		
		local newPosition = UDim2.new(
			0, TileSpacing + (TileWidth + TileSpacing) * (listColumn - 1),
			0, TileSpacing + (TileHeight + TileSpacing) * (listRow - 1))
		if animateTiles then
			tile:TweenPosition(newPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
		else
			tile.Position = newPosition
		end
	end
	local newCanvasSize = UDim2.new(0, 0, 0, TileSpacing + listRowCount * (TileHeight + TileSpacing))
	if animateTiles then
		local tween = TweenService:Create(
			MapListFrame,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{CanvasSize = newCanvasSize})
		tween.Parent = MapListWindow
		game.Debris:AddItem(tween, 1)
		tween:Play()
	else
		MapListFrame.CanvasSize = newCanvasSize
	end
end
function UpdateMapSelection()
	for i, tile in ipairs(MapListFrame:GetChildren()) do
		if "Tile_" .. (SelectedMapName or "") == tile.Name then
			tile.BorderSizePixel = 3
			tile.BorderColor3 = Color3.new(0.2, 1, 1)
		else
			tile.BorderSizePixel = 1
			tile.BorderColor3 = Color3.new(0, 0, 0)
		end
	end
	
	RemoveButton.BackgroundColor3 = SelectedMapName ~= nil and NormalButtonColor or ButtonDisabledColor
	VoteButton.BackgroundColor3 = SelectedMapName ~= nil and NormalButtonColor or ButtonDisabledColor
	OverrideButton.BackgroundColor3 = SelectedMapName ~= nil and NormalButtonColor or ButtonDisabledColor
end
function UpdateMapList(animateTiles)
	if MapListUpdatesDisabled then
		return
	end
	
	UpdateButtons()
	UpdateSearchResults()
	UpdateMapListGui(animateTiles)
	UpdateMapSelection()
end

-- Connect all the events
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	SelectedSearchTerm = SearchBox.Text
	UpdateMapList(true)
end)
SortTitleButton.MouseButton1Click:Connect(function()
	SelectedSortType = 1
	UpdateMapList(true)
end)
SortAuthorButton.MouseButton1Click:Connect(function()
	SelectedSortType = 2
	UpdateMapList(true)
end)
SortDifficultyButton.MouseButton1Click:Connect(function()
	SelectedSortType = 3
	UpdateMapList(true)
end)
MapListFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateMapList(false)
end)
LoadButton.MouseButton1Click:Connect(function()
	CurrentPanelName.Value = "Console"
end)
RemoveButton.MouseButton1Click:Connect(function()
	if SelectedMapName ~= nil then
		UninstallMapRemote:InvokeServer(SelectedMapName)
	end
end)
OverrideButton.MouseButton1Click:Connect(function()
	if SelectedMapName ~= nil then
		IsMenuOpen.Value = false
		OverrideMapVotesRemote:InvokeServer(SelectedMapName)
	end
end)
VoteButton.MouseButton1Click:Connect(function()
	if SelectedMapName ~= nil then
		IsMenuOpen.Value = false
		VoteForMapRemote:InvokeServer(SelectedMapName)
	end
end)
VoteRandomButton.MouseButton1Click:Connect(function()
	IsMenuOpen.Value = false
	VoteForMapRemote:InvokeServer("_Random")
end)
MapInfoFolder.ChildAdded:Connect(function(mapInfo)
	-- Because the whole map info instance probably hasn't replicated yet,
	-- Disable list updates until the map info entry is replicated.
	MapListUpdatesDisabled = true
	pcall(function()
		local settingsFolder = mapInfo:WaitForChild("Settings", 2)
		settingsFolder:WaitForChild("MapName", 2)
		settingsFolder:WaitForChild("MapImage", 2)
		settingsFolder:WaitForChild("Difficulty", 2)
		settingsFolder:WaitForChild("Creator", 2)
		settingsFolder:WaitForChild("BGM", 2)
	end)
	MapListUpdatesDisabled = false
	
	return UpdateMapList(true)
end)
MapInfoFolder.ChildRemoved:Connect(function(map)
	if map.Name == SelectedMapName then
		SelectedMapName = nil
		UpdateMapSelection()
	end
	return UpdateMapList(true)
end)

do
	VoteButton.Visible = MapVotingEnabled.Value
	VoteRandomButton.Visible = MapVotingEnabled.Value
	
	local privileged = GameLib.HasControlPrivileges(Player)
	LoadButton.Visible = privileged
	RemoveButton.Visible = privileged
	OverrideButton.Visible = privileged
end

UpdateMapList()
