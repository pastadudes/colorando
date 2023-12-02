-- Handles server-side logging.
-- 
-- ForbiddenJ

MaxStoredMessages = 200

LogMessageBindable = script.LogMessage
GetMessageLogBindable = script.GetMessageLog
OnMessageLogged = script.OnMessageLogged
GetMessageLogRemote = game.ReplicatedStorage.Game.Console.GetMessageLog
OnMessageLoggedRemote = game.ReplicatedStorage.Game.Console.OnMessageLogged

MessageLog = {}
PendingBlackholing = {} -- List of messages to not repeat from LogService.

function LogMessage(message, messageType)
	return LogMessageInternal(message, messageType, true)
end
function LogMessageInternal(message, messageType, shouldRepeat)
	assert(typeof(message) == "string", "Parameter 1 must be a string.")
	assert(
		(typeof(messageType) == "EnumItem" and messageType.EnumType == Enum.MessageType) or messageType == nil,
		"Parameter 2 must be an Enum.MessageType or nil.")
	messageType = messageType or Enum.MessageType.MessageOutput
	
	-- Purge stored messages as necessary.
	while #MessageLog > MaxStoredMessages do
		table.remove(MessageLog, 1)
	end
	
	-- Censor the message if it contains the phrase 'Error filtering message'
	if string.match(message, 'Error filtering message') then
		message = string.rep('#', message:len())
	end
	
	-- Do message things.
	local entry = {
		messageType = messageType,
		message = message,
	}
	table.insert(MessageLog, entry)
	OnMessageLogged:Fire(message, messageType)
	OnMessageLoggedRemote:FireAllClients(message, messageType)
	
	-- Repeat to LogService.
	if shouldRepeat then
		local s = messageType.Name:sub(8) .. ": " .. message
		print(s)
		table.insert(PendingBlackholing, s)
	end
end
function GetMessageLog()
	return MessageLog
end

LogMessageBindable.OnInvoke = LogMessage
GetMessageLogBindable.OnInvoke = GetMessageLog
function GetMessageLogRemote.OnServerInvoke(player)
	return GetMessageLog()
end

-- Listen for messages from LogService and log them as well.
LoggerConnection = game.LogService.MessageOut:Connect(function(message, messageType)
	-- Don't repeat messages that originally came from this script.
	local blackholeSlot = table.find(PendingBlackholing, message)
	if blackholeSlot ~= nil then
		table.remove(PendingBlackholing, blackholeSlot)
		return
	end
	
	-- Do messaging.
	local success, msg = pcall(LogMessageInternal, message, messageType, false)
	if not success then
		LoggerConnection:Disconnect()
		warn("The link to LogService was broken due to error: " .. msg)
	end
end)
