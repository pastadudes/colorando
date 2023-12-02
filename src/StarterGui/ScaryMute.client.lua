local sound = game:GetService("SoundService"):WaitForChild("SoundFX")
local remoteEvent = game.ReplicatedStorage:WaitForChild("Muter")

local function onNotifyPlayer(maxPlayers, respawnTime)
	wait(5)
	for i = 1,10 do
		sound.Volume -= 0.05
		wait(0.15)
	end
	
	wait(22)
	
	for i = 1,10 do
		sound.Volume += 0.05
		wait(0.15)
	end
end


remoteEvent.OnClientEvent:Connect(onNotifyPlayer)