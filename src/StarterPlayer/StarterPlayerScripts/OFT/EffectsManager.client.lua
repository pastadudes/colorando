-- Controls the general atmosphere the player experiences depending on their PlayState.
-- This does not control underwater effects, which is controlled by another script.
-- 
-- ForbiddenJ

script.Parent.DependencyWaiter.Wait:Invoke()

local Lighting = game.Lighting

local GameLib = require(game.ReplicatedStorage.GameLib)

local NeutralLighting = game.ReplicatedStorage.Game.NeutralLighting
local FallbackLighting = game.ReplicatedStorage.Game.FallbackLighting
local Player = game.Players.LocalPlayer
local PlayState = Player.PlayState
local BGM = game.SoundService.BGM
local CurrentMap = game.ReplicatedStorage.Game.CurrentMap
local MusicEnabled = game.ReplicatedStorage.ClientConfig.MusicEnabled

local BgmVolume = BGM.Volume
local LocalEventScript = nil
local PreviousPlayState = "None"

function UpdateEffects()
	if PlayState.Value == "Playing" then
		if LocalEventScript ~= nil then
			LocalEventScript:Destroy()
			LocalEventScript = nil
		end
		
		LoadInLightingSettings(FallbackLighting)
		local map = CurrentMap.Value
		LoadInLightingSettings(map.Settings.Lighting)
		
		local newSoundID = "rbxassetid://" .. map.Settings.BGM.Value
		BGM:Stop()
		BGM.SoundId = newSoundID
		delay(GameLib.MapBehaviorStartDelay, function(...)
			if BGM.SoundId == newSoundID then
				BGM:Play()
			end
			
			local localEventScript = map:FindFirstChild("LocalEventScript")
			if localEventScript ~= nil and localEventScript:IsA("LocalScript") then
				LocalEventScript = localEventScript:Clone()
				LocalEventScript.Disabled = false
				LocalEventScript.Parent = Player.PlayerScripts
			end
		end)
	elseif PlayState.Value == "None" and PreviousPlayState ~= "WaitingInLift" then
		if LocalEventScript ~= nil then
			LocalEventScript:Destroy()
			LocalEventScript = nil
		end
		
		LoadInLightingSettings(NeutralLighting)
		BGM.SoundId = GameLib.LobbyMusicURL
		BGM:Play()
	end
	
	PreviousPlayState = PlayState.Value
end
function UpdateMusicVolume()
	BGM.Volume = MusicEnabled.Value and BgmVolume or 0
end
function LoadInLightingSettings(settingsFolder)
	-- Set every setting in Lighting to match the values in this Folder.
	for i, item in ipairs(settingsFolder:GetChildren()) do
		if item:IsA("NumberValue") or item:IsA("IntValue") or
			item:IsA("Color3Value") or item:IsA("StringValue") or
			item:IsA("BoolValue") then
			
			Lighting[item.Name] = item.Value
		end
	end
	
	-- Change the sky.
	
end

UpdateEffects()
UpdateMusicVolume()

PlayState.Changed:Connect(UpdateEffects)
MusicEnabled.Changed:Connect(UpdateMusicVolume)
