-- Provides a generic log object that functions can use to output a variety of messages in one go.
-- 
-- ForbiddenJ

local LogServerMessage = game.ServerScriptService.ServerConsole.LogMessage

local mod = {}

function mod.new()
	local self = {}
	
	self.Log = {}
	self.IsErrorFree = true
	self.ClassName = "LogHolder"
	
	self.LogInfo = mod.LogInfo
	self.LogMessage = mod.LogMessage
	self.LogOutput = mod.LogOutput
	self.LogWarning = mod.LogWarning
	self.LogError = mod.LogError
	self.BulkLog = mod.BulkLog
	self.SendToServerLog = mod.SendToServerLog
	
	return self
end

function mod:LogMessage(message, messageType)
	assert(typeof(message) == "string")
	assert(typeof(messageType) == "EnumItem" and messageType.EnumType == Enum.MessageType)
	
	if messageType == Enum.MessageType.MessageError then
		self.IsErrorFree = false
	end
	
	table.insert(self.Log, {message = message, messageType = messageType})
end
function mod:LogInfo(message)
	return self:LogMessage(message, Enum.MessageType.MessageInfo)
end
function mod:LogOutput(message)
	return self:LogMessage(message, Enum.MessageType.MessageOutput)
end
function mod:LogWarning(message)
	return self:LogMessage(message, Enum.MessageType.MessageWarning)
end
function mod:LogError(message)
	return self:LogMessage(message, Enum.MessageType.MessageError)
end
function mod:BulkLog(messageEntries)
	for i, entry in ipairs(messageEntries) do
		self:LogMessage(entry.message, entry.messageType)
	end
end
function mod:SendToServerLog()
	for i, entry in ipairs(self.Log) do
		LogServerMessage:Invoke(entry.message, entry.messageType)
	end
end

return mod
