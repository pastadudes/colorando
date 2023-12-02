-- Provides a log that the GUI can get messages from.
-- 
-- ForbiddenJ

LogMessageBindable = game.ReplicatedStorage.ClientStorage.Console.LogMessage
GetMessageLogBindable = game.ReplicatedStorage.ClientStorage.Console.GetMessageLog
OnMessageLogged = game.ReplicatedStorage.ClientStorage.Console.OnMessageLogged
OnMessageLoggedRemote = game.ReplicatedStorage.Game.Console.OnMessageLogged
GetMessageLogRemote = game.ReplicatedStorage.Game.Console.GetMessageLog

MessageLog = {}

function LogMessage(message, messageType)
	assert(typeof(message) == "string", "Parameter 1 must be a string.")
	assert(
		(typeof(messageType) == "EnumItem" and messageType.EnumType == Enum.MessageType) or messageType == nil,
		"Parameter 2 must be an Enum.MessageType or nil.")
	messageType = messageType or Enum.MessageType.MessageOutput
	
	-- Do message things.
	local t = {
		messageType = messageType,
		message = message,
	}
	table.insert(MessageLog, t)
	OnMessageLogged:Fire(message, messageType)
end
function GetMessageLog()
	return MessageLog
end

LogMessageBindable.OnInvoke = LogMessage
GetMessageLogBindable.OnInvoke = GetMessageLog

-- Do client things.
for i, entry in ipairs(GetMessageLogRemote:InvokeServer()) do
	LogMessage(entry.message, entry.messageType)
end
OnMessageLoggedRemote.OnClientEvent:Connect(LogMessage)

LogMessage("Listening for server errors...", Enum.MessageType.MessageInfo)
--if game.CreatorType == Enum.CreatorType.User and game.Players.LocalPlayer.UserId == game.CreatorId then
--	LogMessage("To see additional messages, type '/console' into chat.", Enum.MessageType.MessageInfo)
--end
