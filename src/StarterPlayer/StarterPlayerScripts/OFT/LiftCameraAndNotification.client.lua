-- Moves the camera when the player gets into the lift.
-- 
-- Will not do anything if the camera is wathcing another player, however.
-- 
-- ForbiddenJ

script.Parent.DependencyWaiter.Wait:Invoke()

TweenLib = require(game.ReplicatedStorage.TweenLib)

MaxCameraAnimateDistance = 64

Player = game.Players.LocalPlayer
PlayState = Player.PlayState
Camera = workspace.CurrentCamera
SpawnNotificationFunction = game.ReplicatedStorage.ClientStorage.SpawnNotification
LiftCameraPart = workspace.Lift.WaitingCamera
MapList = game.ReplicatedStorage.InstalledMapInfo

IsLiftCamActive = false

function UpdateCamera()
	local humanoid = Player.Character and Player.Character:FindFirstChildWhichIsA("Humanoid")
	local newActive = PlayState.Value == "WaitingInLift" and Camera.CameraSubject == humanoid
	if IsLiftCamActive ~= newActive then
		IsLiftCamActive = newActive
		
		if IsLiftCamActive then
			-- Move the camera to a fixed location.
			TweenLib.StopTween(Camera, "LiftCameraTween")
			Camera.CameraType = Enum.CameraType.Scriptable
			if (Camera.CFrame.Position - LiftCameraPart.Position).Magnitude <= MaxCameraAnimateDistance then
				-- Transition the camera over to the fixed location.
				TweenLib.TweenObject(
					Camera,
					TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{CFrame = LiftCameraPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.pi * 0.01 * (math.random() * 2 - 1))},
					"LiftCameraTween",
					function(state)
						-- Then do a slow animation of some kind.
						if state == Enum.PlaybackState.Completed then
							TweenLib.TweenObject(
								Camera,
								TweenInfo.new(8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, math.huge, true),
								{CFrame = Camera.CFrame * CFrame.new(0, 0, 1)},
								"LiftCameraTween")
						end
					end)
			else
				Camera.CFrame = LiftCameraPart.CFrame
			end
		else
			-- Free the camera.
			Camera.CameraType = Enum.CameraType.Custom
			TweenLib.StopTween(Camera, "LiftCameraTween")
		end
	end
end

PlayState.Changed:Connect(function(value)
	if value == "WaitingInLift" then
		if #MapList:GetChildren() > 0 then
			SpawnNotificationFunction:Invoke("You will join the next round.")
		else
			SpawnNotificationFunction:Invoke("The game cannot start because no maps are loaded.", Color3.new(1, 0.3, 0.1))
		end
	end
	UpdateCamera()
end)
Camera:GetPropertyChangedSignal("CameraSubject"):Connect(UpdateCamera)
