-- This script provides a framework for the installation of maps.
-- 
-- ForbiddenJ

MapIntegrityWatchdog = require(script.MapIntegrityWatchdog)
LogHolder = require(game.ServerScriptService.LogHolder)

InstalledMapsFolder = game.ServerStorage.InstalledMaps
InstalledMapInfoFolder = game.ReplicatedStorage.InstalledMapInfo
RejectedMapsFolder = game.ServerStorage.RejectedMaps
GameConfig = game.ReplicatedStorage.Config

function InstallMap(map)
	assert(
		typeof(map) == "Instance" and map.Parent ~= InstalledMapsFolder,
		"Map parameter must be a map Model that is not already installed.")
	
	-- Sanity check the map.
	local log = LogHolder.new()
	
	if InstalledMapsFolder:FindFirstChild(map.Name) ~= nil then
		log:LogError("Cannot install " .. map.Name .. " because another map has the same name.")
	end
	local r2 = nil
	if log.IsErrorFree then
		local r1
		r1, r2 = MapIntegrityWatchdog.CheckMapIntegrity(map)
		if #r2 > 0 then
			log:LogInfo("=== Issues found in " .. map.Name .. " ===")
			log:BulkLog(r2)
			log:LogInfo("--- End of issues --- ")
		end
	end
	
	-- Move the map where it belongs.
	if log.IsErrorFree or not GameConfig.MapIntegrityChecksEnabled.Value then
		-- Add the map to the InstalledMaps folder.
		map.Parent = InstalledMapsFolder
		
		-- Copy the Settings folder of the map to InstalledMapInfo.
		local mapInfoRoot = Instance.new("Model")
		mapInfoRoot.Name = map.Name
		local settingsClone = map.Settings:Clone()
		settingsClone.Parent = mapInfoRoot
		mapInfoRoot.Parent = InstalledMapInfoFolder
		
		-- Log the event.
		log:LogMessage(
			"'" .. map.Name .. "' loaded.",
			Enum.MessageType.MessageInfo)
	else
		-- Add the map to the RejectedMaps folder.
		map.Parent = RejectedMapsFolder
		game.ReplicatedStorage.Game.MapsWereRejected.Value = true
		
		-- Log the event.
		log:LogError(
			"Failed to load '" .. map.Name .. "'.")
	end
	
	return log.IsErrorFree, log.Log
end
function UninstallMap(map)
	assert(
		typeof(map) == "Instance" and map.Parent == InstalledMapsFolder,
		"Map parameter must be a map Model that is already installed.")
	
	InstalledMapInfoFolder:FindFirstChild(map.Name):Destroy()
	map.Parent = nil
	
	return true
end

script.InstallMap.OnInvoke = InstallMap
script.UninstallMap.OnInvoke = UninstallMap
