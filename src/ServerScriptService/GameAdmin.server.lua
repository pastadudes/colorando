-- Grants the server owner some ability to manage the game.
-- 
-- ForbiddenJ

GameLib = require(game.ReplicatedStorage.GameLib)
LogHolder = require(game.ServerScriptService.LogHolder)

MapsFolder = game.ServerStorage.InstalledMaps
GameState = game.ReplicatedStorage.Game.GameState
NextMapOverride = game.ReplicatedStorage.Game.NextMapOverride
InstallMap = game.ServerScriptService.MapInstaller.InstallMap
UninstallMap = game.ServerScriptService.MapInstaller.UninstallMap
LogMessage = game.ServerScriptService.ServerConsole.LogMessage

OverrideMapVotesRemote = game.ReplicatedStorage.Game.Admin.OverrideMapVotes
UninstallMapRemote = game.ReplicatedStorage.Game.Admin.UninstallMap
InstallMapFromIDRemote = game.ReplicatedStorage.Game.Admin.InstallMapFromID

function OverrideMapVotesRemote.OnServerInvoke(player, mapName)
	assert(GameLib.HasControlPrivileges(player), player.Name .. ", you cannot use this!")
	assert(typeof(mapName) == "string")
	assert(MapsFolder:FindFirstChild(mapName) ~= nil or mapName == "_Random") -- Is the map installed?
	
	NextMapOverride.Value = mapName
end
function UninstallMapRemote.OnServerInvoke(player, mapName)
	assert(GameLib.HasControlPrivileges(player), player.Name .. ", you cannot use this!")
	assert(typeof(mapName) == "string")
	
	local map = MapsFolder:FindFirstChild(mapName)
	if map == nil then
		return false
	end
	
	UninstallMap:Invoke(map)
	LogMessage:Invoke(string.format("%s removed '%s'.", player.Name, mapName), Enum.MessageType.MessageInfo)
	
	return true
end
function InstallMapFromIDRemote.OnServerInvoke(player, mapIDText)
	assert(GameLib.HasControlPrivileges(player), player.Name .. ", you cannot use this!")
	assert(typeof(mapIDText) == "string")
	
	local log = LogHolder.new()
	local success, msg = pcall(function()
		-- Try to parse the text.
		local slashIndex = mapIDText:find("/", 1, true)
		local mapId, mapName
		if slashIndex ~= nil then
			mapId = tonumber(mapIDText:sub(1, slashIndex - 1))
			mapName = mapIDText:sub(slashIndex + 1)
		else
			mapId = tonumber(mapIDText)
			mapName = nil
		end
		
		-- Load the map.
		assert(typeof(mapId) == "number" and math.floor(mapId) == mapId and mapId >= 0, "Map ID must be a number.")
		assert(typeof(mapName) == "string" or mapName == nil)
		
		local folder = game.InsertService:LoadAsset(mapId)
		local maps
		if mapName == "*" then
			maps = folder:GetChildren()
		elseif mapName ~= nil then
			maps = {folder:FindFirstChild(mapName)}
		elseif folder:FindFirstChild("Settings") ~= nil then
			maps = {folder}
		else
			maps = folder:GetChildren()
			if #maps > 1 then
				-- Print out a message instead.
				local msg = string.format("There are %i maps in %i. Please type one of the following:\n\n", #maps, mapId)
				local countWithNamesTooLong = 0
				for i, map in ipairs(maps) do
					if map.Name:len() <= 32 then
						msg = msg .. mapId .. "/" .. map.Name .. "\n"
					else
						countWithNamesTooLong = countWithNamesTooLong + 1
					end
				end
				msg =
					msg .. "\n" ..
					"You can also type '" .. mapId .. "/*' to load all the maps."
				if countWithNamesTooLong > 0 then
					msg = msg .. "\n\nNote: " .. countWithNamesTooLong .. " maps were omitted because their names are too long."
				end
				log:LogWarning(msg)
				return
			end
		end
		
		assert(#maps > 0, "The asset was obtained, but the desired map could not be found!")
		
		for i, map in ipairs(maps) do
			map.Name = mapId .. "_" .. map.Name
			local success, messages = InstallMap:Invoke(map)
			log:BulkLog(messages)
		end
		
		-- Treat bulk map loads and single map loads differently.
		if #maps > 1 then
			if log.IsErrorFree then
				log:LogInfo(string.format("%s loaded %i maps from '%s'.", player.Name, #maps, mapIDText))
			else
				log:LogWarning(string.format("Experienced issues loading '%s' for %s.", mapIDText, player.Name))
			end
		else
			-- Remove the last log to avoid result redundancy.
			table.remove(log.Log, #log.Log) 
			
			if log.IsErrorFree then
				log:LogInfo(string.format("%s loaded '%s'.", player.Name, mapIDText))
			else
				log:LogError(string.format("Failed to load '%s' for %s.", mapIDText, player.Name))
			end
		end
	end)
	
	if not success then
		log:LogError(string.format("Failed to load '%s' for %s because of error: %s", mapIDText, player.Name, msg))
	end
	
	log:SendToServerLog()
	
	return log.IsErrorFree
end
