-- Lava Drain MapScript by ForbiddenJ

local Lib = workspace.Multiplayer.GetMapVals:Invoke() --Has: Map, Script, Button, btnFuncs
Lib.Button:connect(function(p, bNo) if Lib.btnFuncs[bNo] then Lib.btnFuncs[bNo](bNo, p) end end)

local Map = Lib.Map
local MainLava = Map._Water2
local TrashAreaLava = Map._Water3
local FallingPlatform1 = Map.Interactives.FallingPlatform1
local FallingPlatform2 = Map.Interactives.FallingPlatform2
local SplashEffect = Map.Interactives.SplashEffect
local TreatmentRoomPlatform = Map.Interactives.TreatmentRoomPlatform
local DrainDoor = Map.Interactives.DrainDoor

local IsTrashPitFlooded = false
local IsDrainActivated = false

-- Utility Functions
local function ActivateAlarmLight(alarm)
	alarm.Base.AlarmSound:Play()
	alarm.Light.SpotLight1.Enabled = true
	alarm.Light.SpotLight2.Enabled = true
end
local function OpenDoor(door)
	if not door.IsOpen.Value then
		door.IsOpen.Value = true
		
		door.Light1.Light.Material = Enum.Material.Neon
		door.Light1.Light.BrickColor = BrickColor.new("Lime green")
		door.Light2.Light.Material = Enum.Material.Neon
		door.Light2.Light.BrickColor = BrickColor.new("Lime green")
		door.PrimaryPart.MotorSound:Play()
		local tween = game.TweenService:Create(
			door.Door,
			TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
			{CFrame = door.PrimaryPart.OpenLocation.WorldCFrame})
		tween:Play()
		delay(2, function(...)
			door.PrimaryPart.MotorSound:Stop()
		end)
	end
end
local function BreakDoor(door)
	if door.IsOpen.Value then
		door.IsOpen.Value = false
		
		door.Light1.Light.Material = Enum.Material.Plastic
		door.Light1.Light.BrickColor = BrickColor.new("Black")
		door.Light2.Light.Material = Enum.Material.Plastic
		door.Light2.Light.BrickColor = BrickColor.new("Black")
		door.PrimaryPart.BreakSound:Play()
		local tween = game.TweenService:Create(
			door.Door,
			TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
			{CFrame = door.PrimaryPart.ClosedLocation.WorldCFrame})
		tween:Play()
	end
end
local function LightTriggerWire(wireModel)
	for i, item in ipairs(wireModel:GetChildren()) do
		if item:IsA("BasePart") and item.Name == "WirePart" then
			item.Material = Enum.Material.Neon
			local tween = game.TweenService:Create(
				item,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, math.huge, true),
				{Color = BrickColor.new("Storm blue").Color})
			tween:Play()
		end
	end
end

-- Event Functions
local function FloodIntro()
	BreakDoor(Map.Interactives.SouthDoor)
end
local function FloodTrashPit()
	if not IsTrashPitFlooded then
		IsTrashPitFlooded = true
		
		Lib.Script.moveWater(TrashAreaLava, Vector3.new(0, 32, 0), 4, true)
		BreakDoor(Map.Interactives.EastDoor)
	end
end

-- Prepare stuff.
TreatmentRoomPlatform.CFrame = TreatmentRoomPlatform.CFrame * CFrame.new(TreatmentRoomPlatform.Size.X - 1, 0, 0)
Lib.Script.setWaterState(MainLava, "lava")
Lib.Script.setWaterState(TrashAreaLava, "lava")
Lib.btnFuncs[1] = function(n, player)
	LightTriggerWire(Map.Interactives.TriggerWire1)
	delay(4, FloodTrashPit)
	delay(6, function(...)
		OpenDoor(Map.Interactives.WestDoor)
	end)
end
Lib.btnFuncs[2] = function(n, player)
	ActivateAlarmLight(Map.Interactives.AlarmLight1)
	LightTriggerWire(Map.Interactives.TriggerWire2)
	
	delay(3, function(...)
		-- The path to the treatment room collapses.
		FallingPlatform1.SoundEmitter.CreakSound:Play()
		wait(4)
		FallingPlatform1.PrimaryPart.Anchored = false
		if FallingPlatform1.PrimaryPart:CanSetNetworkOwnership() then
			FallingPlatform1.PrimaryPart:SetNetworkOwner(nil)
		end
		FallingPlatform1.SoundEmitter.Sound:Play()
		wait(0.45)
		FallingPlatform2.PrimaryPart.Anchored = false
		if FallingPlatform2.PrimaryPart:CanSetNetworkOwnership() then
			FallingPlatform2.PrimaryPart:SetNetworkOwner(nil)
		end
		FallingPlatform2.SoundEmitter.Sound:Play()
		wait(0.25)
		SplashEffect.ParticleEmitter.Enabled = true
		wait(0.70)
		SplashEffect.ParticleEmitter.Enabled = false
	end)
	delay(10, function(...)
		OpenDoor(Map.Interactives.NorthDoor)
	end)
end
Lib.btnFuncs[3] = function(n, player)
	local tween = game.TweenService:Create(
		TreatmentRoomPlatform,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		{CFrame = TreatmentRoomPlatform.CFrame * CFrame.new(-TreatmentRoomPlatform.Size.X + 1, 0, 0)})
	tween:Play()
	TreatmentRoomPlatform.MotorSound:Play()
	tween.Completed:Wait()
	TreatmentRoomPlatform.MotorSound:Stop()
end
Lib.btnFuncs[4] = function(n, player)
	IsDrainActivated = true
	ActivateAlarmLight(Map.Interactives.AlarmLight2)
	wait(1)
	Lib.Script.moveWater(MainLava, Vector3.new(0, -64, 0), 6, true)
	Lib.Script.moveWater(DrainDoor.Door, Vector3.new(0, 3, 0), 2, true)
	DrainDoor.SoundEmitter.MotorSound:Play()
	DrainDoor.SoundEmitter.DrainSound:Play()
	wait(2)
	DrainDoor.SoundEmitter.MotorSound:Stop()
	wait(4)
	DrainDoor.SoundEmitter.DrainSound:Stop()
end
Lib.btnFuncs[5] = function(n, player)
	Lib.Script.moveWater(DrainDoor.Door, Vector3.new(0, 11, 0), 4, true)
	DrainDoor.SoundEmitter.MotorSound:Play()
	wait(4)
	DrainDoor.SoundEmitter.MotorSound:Stop()
end

-- Do flooding.
Lib.Script.moveWater(MainLava, Vector3.new(0, 32, 0), 76, true)
delay(76, function(...)
	FloodIntro()
	FloodTrashPit()
	Lib.Script.moveWater(MainLava, Vector3.new(0, 16, 0), 4, true)
end)
delay(80, function(...)
	Lib.Script.moveWater(MainLava, Vector3.new(0, 20, 0), 28, true)
end)
delay(108, function(...)
	-- Give the players extra time to escape if they activated the drain.
	if IsDrainActivated then
		wait(7)
	end
	
	Lib.Script.moveWater(MainLava, Vector3.new(0, 76, 0), 5, true)
end)
