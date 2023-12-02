-- Preloads music as a map is loading.
-- 
-- ForbiddenJ

ContentProvider = game:GetService("ContentProvider")

NextMapName = game.ReplicatedStorage.Game.NextMapName
MapInfoFolder = game.ReplicatedStorage.InstalledMapInfo

function TryPreloadNext()
	local nextMapPrefab = NextMapName.Value ~= "" and MapInfoFolder:FindFirstChild(NextMapName.Value) or nil
	local mapSettings = nextMapPrefab and nextMapPrefab.Settings
	local musicId = mapSettings and mapSettings.BGM.Value
	if musicId ~= nil then
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://" .. musicId
		sound.Name = "PreloadSound"
		sound.Parent = script
		spawn(function(...)
			ContentProvider:PreloadAsync({sound})
			sound:Destroy()
		end)
	end
end

TryPreloadNext()

NextMapName.Changed:Connect(TryPreloadNext)
