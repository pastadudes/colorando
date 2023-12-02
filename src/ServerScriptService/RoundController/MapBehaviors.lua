-- A section of the RoundController dedicated to map behaviors.

local GameLib = require(game.ReplicatedStorage.GameLib)

local ButtonScriptPrefab   = game.ReplicatedStorage.Prefabs.ButtonScriptPrefab
local PressSoundPrefab     = game.ReplicatedStorage.Prefabs.PressSoundPrefab

local module = {}

function module.PrepareButton(button)
	local buttonScript = ButtonScriptPrefab:Clone()
	buttonScript.Name = "_ButtonScript"
	buttonScript.Disabled = false
	buttonScript.Parent = button
	local pressSound = PressSoundPrefab:Clone()
	pressSound.Name = "_PressSound"
	pressSound.Parent = button.Hitbox
	local buttonState = Instance.new("StringValue")
	buttonState.Name = "_ButtonState"
	buttonState.Value = "Inactive" -- Pressed, Active, ActiveGroup, or Inactive
	buttonState.Parent = button
	local bashCount = Instance.new("IntValue")
	bashCount.Name = "_BashCount"
	bashCount.Value = 0
	bashCount.Parent = button
	local bashCountNeeded = Instance.new("IntValue")
	bashCountNeeded.Name = "_BashCountNeeded"
	bashCountNeeded.Value = 1
	bashCountNeeded.Parent = button
	local getTouchedPlayersBindable = Instance.new("BindableFunction")
	getTouchedPlayersBindable.Name = "_GetTouchedPlayers"
	getTouchedPlayersBindable.Parent = button
end
function module.PrepareMapObjects(map)
	-- Disable EventScript temporarily.
	local eventScript = map:FindFirstChild("EventScript")
	if eventScript ~= nil and eventScript:IsA("Script") then
		eventScript.Disabled = true
	end
	
	-- Figure out the buttons.
	local mapButtons = {}
	for i, item in pairs(map:GetDescendants()) do
		local isButton, nameExtension = GameLib.IsButton(item)
		if isButton then
			local id = tonumber(nameExtension)
			if id ~= nil and id == math.floor(id) then -- Is this an integer?
				mapButtons[id] = item
			end
		end
	end
	for i, button in ipairs(mapButtons) do
		module.PrepareButton(button)
	end
	
	-- Hide things with _Appear tags and add State tags to water.
	for i, item in pairs(map:GetDescendants()) do
		local parent = item.Parent
		if string.sub(item.Name, 1, 7) == "_Appear" then
			if parent:IsA("BasePart") then
				parent.CanCollide = false
				parent.Transparency = 1
			else
				for i2, item2 in pairs(parent:GetDescendants()) do
					if item2:IsA("BasePart") then
						item2.CanCollide = false
						item2.Transparency = 1
					end
				end
			end
		elseif string.sub(item.Name, 1, 6) == "_Water" then
			local waterStateTag = item:FindFirstChild("State")
			if waterStateTag == nil then
				waterStateTag = Instance.new("StringValue")
				waterStateTag.Name = "State"
				waterStateTag.Value = "water"
				waterStateTag.Parent = item
			end
		end
	end
	
	-- Figure out where the ExitRegions are.
	local exitRegions = {}
	for i, item in pairs(map:GetChildren()) do
		if item.Name == "ExitRegion" and item:IsA("BasePart") then
			table.insert(exitRegions, item)
		end
	end
	
	return {Map = map, Buttons = mapButtons, ExitRegions = exitRegions}
end
function module.TriggerEvents(map, buttonId)
	assert(typeof(map) == "Instance" and (map:IsA("Model") or map:IsA("Folder")), "Argument 1 must be a Model!")
	assert(typeof(buttonId) == "number", "Argument 2 must be a number!")
	
	for i, item in pairs(map:GetDescendants()) do
		local name = item.Name
		local parent = item.Parent
		-- Checking for an underscore speeds item searching and management.
		if string.sub(name, 1, 1) == "_" then
			local tag = item
			
			local delayTime = 0
			local delayTag = tag:FindFirstChild("_Delay")
			if delayTag and delayTag:IsA("NumberValue") then
				delayTime = delayTag.Value
			end
			
			delay(delayTime, function(...)
				if name == "_Fall" .. buttonId and (parent:IsA("BasePart") or parent:IsA("Model")) then
					if parent:IsA("BasePart") then
						parent.Anchored = false
						parent:BreakJoints()
					else
						for i2, item2 in pairs(parent:GetDescendants()) do
							if item2:IsA("BasePart") then
								item2.Anchored = false
								item2:BreakJoints()
							end
						end
					end
					game.Debris:AddItem(parent, 5)
				elseif name == "_Fade" .. buttonId and (parent:IsA("BasePart") or parent:IsA("Model")) then
					parent:Destroy()
				elseif name == "_Appear" .. buttonId and (parent:IsA("BasePart") or parent:IsA("Model")) then
					if parent:IsA("BasePart") then
						parent.CanCollide = true
						parent.Transparency = 0
					else
						for i2, item2 in pairs(parent:GetDescendants()) do
							if item2:IsA("BasePart") then
								item2.CanCollide = true
								item2.Transparency = 0
							end
						end
					end
				elseif name == "_Sound" .. buttonId and tag:IsA("Sound") then
					tag:Play()
				end
			end)
		end
	end
end

return module
