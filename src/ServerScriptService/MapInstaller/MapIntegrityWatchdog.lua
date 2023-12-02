-- This script can deep scan a map for problems.
-- 
-- ForbiddenJ

GameLib = require(game.ReplicatedStorage.GameLib)

local mod = {}

function mod.CheckMapIntegrity(map)
	assert(typeof(map) == "Instance")
	
	local r, ml = true, {} -- Result, Message List
	local errorOrWarningCount = 0
	
	-- Things fundamental to this function's workings.
	local function logMessage(message, messageType)
		assert(typeof(message) == "string")
		assert(typeof(messageType) == "EnumItem" and messageType.EnumType == Enum.MessageType)
		
		ml[#ml + 1] = {message = message, messageType = messageType}
	end
	local function throwMapError(message)
		r = false
		errorOrWarningCount = errorOrWarningCount + 1
		return logMessage(message, Enum.MessageType.MessageError)
	end
	local function throwMapWarning(message)
		errorOrWarningCount = errorOrWarningCount + 1
		return logMessage(message, Enum.MessageType.MessageWarning)
	end
	local function mustHaveOneObject(parent, objectName, classType, parentDescription, furtherCheckFunction)
		parentDescription = parentDescription or parent.Name .. " " .. parent.ClassType
		
		local multiple = false
		local object = nil
		for i, item in pairs(parent:GetChildren()) do
			if item.Name == objectName then
				if object == nil then
					object = item
				else
					multiple = true
					break
				end
			end
		end
		if object ~= nil then
			if not multiple then
				if object:IsA(classType) then
					if furtherCheckFunction ~= nil then
						furtherCheckFunction(object)
					end
				else
					throwMapError(objectName .. " is not a " .. classType .. ".")
				end
			else
				throwMapError("There is more than one object named " .. objectName .. " inside of the " .. parentDescription ..
					". This can lead to the game selecting the wrong object. Make sure there is only one here.")
			end
		else
			throwMapError("The " .. objectName .. " " .. classType .. " is nonexistent in the " ..
				parentDescription .. ". Create a " .. classType .. " Instance in there and name it \"" ..
				objectName .. "\".")
		end
	end
	local function mustBeAnchored(part)
		if not part.Anchored then
			throwMapError("The " .. part.Name .. " is not Anchored and will fall before the game starts.")
		end
	end
	
	-- Is the Map even a Model or Folder?
	if not map:IsA("Model") and not map:IsA("Folder") then
		throwMapError("The map is a " .. map.ClassName .. ". The map must be either a Model or Folder.")
	end
	
	-- Does the map name match a reserved name?
	local function mapCannotHaveName(name)
		if map.Name == name then
			throwMapError("The map's Model name is \"" .. name .. "\", which is a reserved map name. You must" ..
				" rename the Model to something else.")
		end
	end
	mapCannotHaveName("_Random")
	mapCannotHaveName("_None")
	
	-- Is the EventString there and in good order?
--	mustHaveOneObject(map, "EventString", "StringValue", "Map Model", function(eventString)
--		local f, message = loadstring(eventString.Value)
--		if f == nil then
--			throwMapError("The EventString contains Lua errors! Error Message: " .. message)
--		end
--	end)
	
	-- Is the Settings Folder there and in good order?
	mustHaveOneObject(map, "Settings", "Folder", "Map Model", function(settingsFolder)
		mustHaveOneObject(settingsFolder, "Lighting", "Folder", "Settings Folder", nil)
		mustHaveOneObject(settingsFolder, "BGM", "NumberValue", "Settings Folder", nil)
		mustHaveOneObject(settingsFolder, "Difficulty", "NumberValue", "Settings Folder", nil)
		mustHaveOneObject(settingsFolder, "MapImage", "NumberValue", "Settings Folder", nil)
		mustHaveOneObject(settingsFolder, "Creator", "StringValue", "Settings Folder", nil)
		mustHaveOneObject(settingsFolder, "MapName", "StringValue", "Settings Folder", nil)
	end)
	
	-- Is the Spawn there and in good order?
	mustHaveOneObject(map, "Spawn", "BasePart", "Map Model", function(spawnBrick)
		if spawnBrick.Size ~= Vector3.new(16, 1, 16) then
			throwMapWarning("The Spawn does not have a Size of 16 x 1 x 16, this game can " ..
				"still work with weird Sizes, but you should use that Size just to be safe.")
		end
		
		mustBeAnchored(spawnBrick)
	end)
	
	-- Is the ExitRegion there and in good order?
	mustHaveOneObject(map, "ExitRegion", "BasePart", "Map Model", function(exitRegion)
		if exitRegion.CanCollide then
			throwMapError("The ExitRegion has its CanCollide property set to true. Players won't be able to enter it.")
		end
		
		mustBeAnchored(exitRegion)
		
		if exitRegion.Transparency < 0.2 then
			throwMapWarning("The ExitRegion is opaque. This may confuse players into thinking it's a solid wall.")
		end
	end)
	
	-- Is the Intro Model there and in good order?
	--mustHaveOneObject(map, "Intro", "Model", "Map Model", nil)
	
	-- Check the integrity of buttons.
	do
		local buttons = {}
		local allButtons = {}
		local highestNumber = 0
		for i, item in pairs(map:GetDescendants()) do
			if item:IsA("Model") and string.sub(item.Name, 1, 7) == "_Button" then
				local id = tonumber(string.sub(item.Name, 8, -1))
				if id ~= nil and id == math.floor(id) then -- Is this an integer?
					if id > highestNumber then
						highestNumber = id
					end
					buttons[id] = item
					allButtons[#allButtons + 1] = item
				else
					throwMapError(item.Name .. " looks like a button without a proper integer. Name it in the format _Button{i}")
				end
			end
		end
		
		for i = 1, highestNumber do
			local button = nil
			local multiple = false
			for i2, button2 in pairs(allButtons) do
				if button2.Name == "_Button" .. i then
					if button == nil then
						button = button2
					else
						multiple = true
						break
					end
				end
			end
			
			if button ~= nil then
				if not multiple then
					mustHaveOneObject(button, "Hitbox", "BasePart", button.Name, function(hitboxPart)
						if not hitboxPart.Anchored and #hitboxPart:GetConnectedParts() == 0 then
							throwMapError(button.Name .. "'s Hitbox is not Anchored or welded and will fall before the " ..
								"game starts.")
						end
					end)
				else
					throwMapError("There are multiple buttons with the index " .. i ..
						". Please assign them different numbers")
				end
			else
				throwMapWarning("There's no button at the index " .. i .. ", but the highest button index in the map is " ..
					highestNumber .. ". The buttons must be contiguous in numbers. Non-contiguous buttons will be ignored. " ..
					"To fix, either make a new button with the name \"_Button" .. i .. "\" or change the index of other " ..
					"buttons to close the gap.")
				break
			end
		end
	end
	
	return r, ml
end

return mod
