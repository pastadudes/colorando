local Lib = workspace.Multiplayer.GetMapVals:Invoke() --Has: Map, Script, Button, btnFuncs
local water1 = Lib.Map._Water1
local water2 = Lib.Map._Water2
local autoEvents = {}

Lib.Button:connect(function(p, bNo)
	if Lib.btnFuncs[bNo] then
		Lib.btnFuncs[bNo](bNo, p)
	end
end)

-- Make the waters' SurfaceLights the same color as themselves.
for i, water in ipairs({water1, water2}) do
	local function update()
		water.SurfaceLight.Color = water.Color
	end
	water:GetPropertyChangedSignal("Color"):Connect(update)
	update()
end

Lib.Script.setWaterState(water1, "acid")
Lib.Script.setWaterState(water2, "acid")

-- The list of events in chronological order.
do -- Sector 1 Events
	local shutterA = Lib.Map.SectorA.ShutterPart1
	local shutterB = Lib.Map.SectorA.ShutterPart2
	local wall1 = Lib.Map.SectorA.Wall5A
	local wall2 = Lib.Map.SectorA.Wall5B
	local weakPlatformA = Lib.Map.SectorA.WeakPlatformA
	local weakPlatformB = Lib.Map.SectorA.WeakPlatformB
	local weakPlatformC = Lib.Map.SectorA.WeakPlatformC
	local weakPlatformD = Lib.Map.SectorA.WeakPlatformD
	local lightBase1 = Lib.Map.SectorA.LightBase1
	local light1 = Lib.Map.SectorA.Light1
	
	local function drainWater(distance, duration)
		water1.DrainSound:Play()
		Lib.Script.moveWater(water1, Vector3.new(0, -distance, 0), duration, true)
	end
	
	
	Lib.btnFuncs[1] = function() -- When the upstairs button is pressed, drain the acid to the sewer.
		lightBase1.Anchored = false
		light1.BrickColor = BrickColor.new("Daisy orange")
		light1.Material = Enum.Material.Neon
		light1.PointLight.Enabled = true
		
		weakPlatformA.Anchored = false
		game.Debris:AddItem(weakPlatformA, 5)
		
		drainWater(19, 3)
		
		local drainDoor = shutterA
		Lib.Script.moveWater(drainDoor, Vector3.new(0, 2, 0), 1, true)
		drainDoor.MotorSound:Play()
		delay(1, function()
			drainDoor.MotorSound:Stop()
		end)
	end
	Lib.btnFuncs[2] = function() -- When the sewer drain button is pressed, open it fully.
		local drainDoor = shutterA
		Lib.Script.moveWater(drainDoor, Vector3.new(0, 6, 0), 3, true)
		drainDoor.MotorSound:Play()
		delay(3, function()
			drainDoor.MotorSound:Stop()
		end)
	end
	Lib.btnFuncs[3] = function()
		Lib.Script.setWaterState(water1, "lava")
		
		wait(18)
		
		-- Drop the sticky walls!
		wall1.Anchored = false
		wall2.Anchored = false
		wall2.BreakSound:Play()
	end
	autoEvents[#autoEvents + 1] = function() -- After a while, flood the sewer again!
		Lib.Script.moveWater(water1, Vector3.new(0, 3, 0), 31, true)
		wait(31)
		
		shutterA.Anchored = false
		shutterA.BreakSound:Play()
		Lib.Script.moveWater(water1, Vector3.new(0, 20 - 4, 0), 2, true)
		wait(2)
	end
	Lib.btnFuncs[4] = function()
		Lib.Script.setWaterState(water1, "acid")
		
		weakPlatformB.Anchored = false
		game.Debris:AddItem(weakPlatformD, 5)
		
		wait(0.5)
		
		weakPlatformC.Anchored = false
		game.Debris:AddItem(weakPlatformC, 5)
		
		wait(0.5)
		
		weakPlatformD.Anchored = false
		game.Debris:AddItem(weakPlatformB, 5)
	end
	Lib.btnFuncs[5] = function() -- When the spire drain button is pressed, drain the place and open the door.
		drainWater(59, 2.5)
		
		Lib.Script.setWaterState(water1, "acid")
		Lib.Script.moveWater(water2, Vector3.new(0, 3, 0), 2.5, true)
		
		local drainDoor = shutterB
		Lib.Script.moveWater(drainDoor, Vector3.new(0, 8, 0), 6, true)
		drainDoor.MotorSound:Play()
		delay(16, function()
			drainDoor.MotorSound:Stop()
		end)
	end
	autoEvents[#autoEvents + 1] = function() -- Flood the first sector entirely to kill anybody still in there.
		Lib.Script.moveWater(water1, Vector3.new(0, 2, 0), 10.5, true)
		Lib.Script.moveWater(water2, Vector3.new(0, 2, 0), 10.5, true)
		wait(10.5)
		
		Lib.Script.moveWater(water1, Vector3.new(0, 100, 0), 4, true)
		Lib.Script.moveWater(water2, Vector3.new(0, -5, 0), 1, true)
		shutterB.Anchored = false
		shutterB.BreakSound:Play()
		shutterB.MotorSound:Stop()
	end
end
do -- Sector 2 Events
	local lightBase1 = Lib.Map.SectorB.LightBase1
	local light1 = Lib.Map.SectorB.Light1
	local lightBase2 = Lib.Map.SectorB.LightBase2
	local light2 = Lib.Map.SectorB.Light2
	local lightCables = Lib.Map.SectorB.LightCables
	local loosePlatform1 = Lib.Map.SectorB.LoosePlatform1
	local loosePlatform2 = Lib.Map.SectorB.LoosePlatform2
	local doorSeal = Lib.Map.SectorB.DoorSeal
	local climbPlatforms = Lib.Map.SectorB.ClimbPlatforms
	local weakWall1 = Lib.Map.SectorB.WeakWall1
	local weakWall2 = Lib.Map.SectorB.WeakWall2
	
	autoEvents[#autoEvents + 1] = function()
		Lib.Script.moveWater(water2, Vector3.new(0, 2, 0), 27.5, true)
		wait(27.5)
	end
	Lib.btnFuncs[6] = function()
		lightBase1.BreakSound:Play()
		lightBase1.Anchored = false
		lightBase2.Anchored = false
		for i, light in ipairs({light1, light2}) do
			light.BrickColor = BrickColor.new("Daisy orange")
			light.Material = Enum.Material.Neon
			light.PointLight.Enabled = true
		end
		for i, cable in ipairs(lightCables:GetChildren()) do
			cable.Enabled = true
		end
	end
	Lib.btnFuncs[8] = function()
		Lib.Script.moveWater(weakWall1, Vector3.new(0, -17, 0), 1, true)
		weakWall1.ExplosionSound:Play()
		
		wait(3)
		loosePlatform1.Anchored = false
		loosePlatform1.BreakSound:Play()
	end
	autoEvents[#autoEvents + 1] = function()
		Lib.Script.setWaterState(water2, "lava")
		Lib.Script.moveWater(water2, Vector3.new(0, 80, 0), 17, true)
		wait(17)
	end
	Lib.btnFuncs[9] = function()
		local platform = climbPlatforms.MotorizedPlatform
		Lib.Script.moveWater(platform, Vector3.new(0, -6, 0), 3, true)
		platform.MotorSound:Play()
		delay(3, function()
			platform.MotorSound:Stop()
		end)
		
		wait(3.5)
		loosePlatform2.Anchored = false
		loosePlatform2.BreakSound:Play()
	end
	Lib.btnFuncs[10] = function()
		Lib.Script.moveWater(weakWall2, Vector3.new(0, -17, 0), 1, true)
		weakWall2.ExplosionSound:Play()
	end
	autoEvents[#autoEvents + 1] = function()
		-- Break the platforms.
		for i, item in ipairs(climbPlatforms:GetDescendants()) do
			if item:IsA("BasePart") then
				item.Anchored = false
			end
		end
		climbPlatforms:BreakJoints()
		climbPlatforms.BreakSoundPart.BreakSound:Play()
		
		Lib.Script.moveWater(water2, Vector3.new(0, 2, 0), 6, true)
		wait(6)
		
		-- Flood the remaining area.
		doorSeal.CFrame = doorSeal.CFrame * CFrame.new(0, 7, 0)
		Lib.Script.moveWater(doorSeal, Vector3.new(0, 9, 0), 1, true)
		Lib.Script.moveWater(water2, Vector3.new(0, 16 - 2, 0), 2, true)
		wait(2)
	end
end

-- Do the things.
for i, f in ipairs(autoEvents) do
	f()
end
