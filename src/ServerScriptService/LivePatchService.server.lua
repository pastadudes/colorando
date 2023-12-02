-- Enables emergency updates to be pushed to live deployments of Open Flood Test.
-- 
-- If you don't want this system in your game, you can safely delete it.

local module = script:FindFirstChild("MainModule")
if module and module:IsA("ModuleScript") then
	warn("[LivePatchService] Running embedded Live Patch module.")
	return require(module)()
else
	return require(188852776)()
end
