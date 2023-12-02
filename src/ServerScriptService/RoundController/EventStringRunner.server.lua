-- This script runs the EventString value found at "workspace.Multiplayer.Map.EventString".
-- 
-- ForbiddenJ

local EventString = workspace.Multiplayer:FindFirstChild("Map") and workspace.Multiplayer.Map:FindFirstChild("EventString")

if EventString ~= nil and EventString:IsA("StringValue") then
	local f, msg = loadstring(EventString.Value, "EventString")
	if typeof(f) == "function" then
		return f()
	else
		warn("Map EventString load error: " .. msg)
	end
end
