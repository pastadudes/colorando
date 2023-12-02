-- Automatically installs user-added maps on server start.
-- 
-- ForbiddenJ

LogHolder = require(game.ServerScriptService.LogHolder)

MapWorkspace = workspace.MapWorkspace
OwnerMapInstallFolder = game.ServerStorage.Maps

function InstallMap(map)
	local success, messages = script.Parent.InstallMap:Invoke(map)
	local log = LogHolder.new()
	log:BulkLog(messages)
	log:SendToServerLog()
end

-- Pull maps from MapWorkspace.
for i, map in ipairs(workspace.MapWorkspace:GetChildren()) do
	InstallMap(map)
end

-- Pull maps from Maps.
for i, map in ipairs(OwnerMapInstallFolder:GetChildren()) do
	InstallMap(map)
end
OwnerMapInstallFolder.ChildAdded:Connect(function(map)
	wait()
	InstallMap(map)
end)
