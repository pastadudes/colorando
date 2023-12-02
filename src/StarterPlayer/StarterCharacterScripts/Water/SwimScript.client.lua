-- Allows the humanoid's swimming behavior to be controlled by a player.
-- 
-- By ForbiddenJ

RunService = game:GetService("RunService")
ContextActionService = game.ContextActionService

SwimUpKeys = {Enum.KeyCode.Space, Enum.KeyCode.ButtonA}
SwimDownKeys = {Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonB}

Player = game.Players.LocalPlayer
Humanoid = script.Parent.Parent.Humanoid
CurrentBody = script.Parent:WaitForChild("CurrentBody")
Anims = {
	Idle = game.ReplicatedStorage.AnimationStorage.SwimIdle,
	Swim0 = game.ReplicatedStorage.AnimationStorage.Swim0,
	Swim45 = game.ReplicatedStorage.AnimationStorage.Swim45,
	Swim90 = game.ReplicatedStorage.AnimationStorage.Swim90,
	Swim135 = game.ReplicatedStorage.AnimationStorage.Swim135,
	Swim180 = game.ReplicatedStorage.AnimationStorage.Swim180,
}

HumanoidIsDead = false
IsSwimming = false
IsSwimmingUp = false
IsSwimmingDown = false
AnimState = ""
BodyWeight = 0
BodyVelocity = nil
BodyGyro = nil
AnimState = nil
AnimTracks = {
	Idle = nil,
	Swim0 = nil,
	Swim45 = nil,
	Swim90 = nil,
	Swim135 = nil,
	Swim180 = nil,
}

function SetAnimState(newState)
	assert(typeof(newState) == "string" or newState == nil, "New state must be a string or nil.")
	
	local oldState = AnimState
	if newState ~= oldState then
		local oldTrack = AnimTracks[oldState]
		local newTrack = AnimTracks[newState]
		if oldTrack ~= nil then
			oldTrack:Stop()
		end
		if newTrack ~= nil then
			newTrack:Play()
		end
		AnimState = newState
	end
end
function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end
function GetTotalWeight(Object)
	local Parts = GetAllConnectedParts(Object)
	local Mass = 0
	for i, v in pairs(Parts) do
		if v:IsA("BasePart") then
			Mass = Mass + v:GetMass()
		end
	end
	return Mass * workspace.Gravity
end
function StartSwimming()
	if not IsSwimming then
		IsSwimming = true
		
		BodyWeight = GetTotalWeight(Humanoid.RootPart)
		
		BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Name = "SwimmingVelocity"
		BodyVelocity.P = BodyWeight * 3.1
		BodyVelocity.MaxForce = Vector3.new(BodyVelocity.P, BodyVelocity.P, BodyVelocity.P)
		BodyVelocity.Velocity = Vector3.new(0, 0, 0)
		BodyVelocity.Parent = Humanoid.RootPart
		
		BodyGyro = Instance.new("BodyGyro")
		BodyGyro.Name = "SwimmingGyro"
		BodyGyro.MaxTorque = Vector3.new(math.huge, 2000, math.huge)
		BodyGyro.D = 50
		BodyGyro.P = 500
		BodyGyro.Parent = Humanoid.RootPart
		BodyGyro.CFrame = Humanoid.RootPart.CFrame
		
		Humanoid.PlatformStand = true
		
		SetAnimState("Idle")
	end
end
function StopSwimming()
	if IsSwimming then
		IsSwimming = false
		
		BodyVelocity:Destroy()
		BodyVelocity = nil
		BodyGyro:Destroy()
		BodyGyro = nil
		
		SetAnimState(nil)
		
		Humanoid.PlatformStand = false
	end
end
function ActionHandler(actionName, inputState, inputObj)
	if actionName == "Swimming_SwimUp" then
		if inputState == Enum.UserInputState.Begin then
			IsSwimmingUp = true
		elseif inputState == Enum.UserInputState.End then
			IsSwimmingUp = false
		end
	elseif actionName == "Swimming_SwimDown" then
		if inputState == Enum.UserInputState.Begin then
			IsSwimmingDown = true
		elseif inputState == Enum.UserInputState.End then
			IsSwimmingDown = false
		end
	end
	
	return (IsSwimming and inputState == Enum.UserInputState.Begin) and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
end
function OnCurrentBodyChanged(value)
	-- When the Humanoid's Head falls into the water, make it swim, and vice-versa.
	if value ~= nil and not HumanoidIsDead then
		if not Humanoid.PlatformStand then
			StartSwimming()
		end
	elseif IsSwimming then
		local wasSwimmingUp = IsSwimmingUp
		
		StopSwimming()
		
		-- Make the humanoid fly out of the water if it was swimming up.
		if wasSwimmingUp then
			local rpv = Humanoid.RootPart.Velocity -- Root Part Velocity
			Humanoid.RootPart.Velocity = Vector3.new(rpv.X, Humanoid.JumpPower * 1.2, rpv.Z)
		end
	end
end
function OnDeath()
	HumanoidIsDead = true
	StopSwimming()
end
function OnJumpChanged()
	IsSwimmingUp = Humanoid.Jump
end

for name, animation in pairs(Anims) do
	local track = Humanoid:LoadAnimation(animation)
	track.Priority = Enum.AnimationPriority.Movement
	AnimTracks[name] = track
end

CurrentBody.Changed:Connect(OnCurrentBodyChanged)
Humanoid.Died:Connect(OnDeath)
Humanoid:GetPropertyChangedSignal("Jump"):Connect(OnJumpChanged)
RunService.Heartbeat:Connect(function(deltaTime)
	-- Let the player swim around.
	if IsSwimming then
		-- In what direction is the player trying to go?
		local verticalDirection = 0
		if IsSwimmingUp then
			verticalDirection = verticalDirection + 1
		end
		if IsSwimmingDown then
			verticalDirection = verticalDirection - 1
		end
		local direction = Humanoid.MoveDirection + Vector3.new(0, verticalDirection, 0)
		local isMovingHorizontal = Humanoid.MoveDirection.Magnitude > 0.1
		
		-- Make the Humanoid move that way.
		BodyVelocity.Velocity = direction * Humanoid.WalkSpeed
		if direction.Magnitude > 0.2 then
			if isMovingHorizontal then
				if verticalDirection > 0.1 then
					SetAnimState("Swim45")
				elseif verticalDirection < -0.1 then
					SetAnimState("Swim135")
				else
					SetAnimState("Swim90")
				end
			else
				if verticalDirection < 0 then
					SetAnimState("Swim180")
				else
					SetAnimState("Swim0")
				end
			end
		else
			SetAnimState("Idle")
		end
		if isMovingHorizontal then
			BodyGyro.CFrame = CFrame.new(Vector3.new(0, 0, 0), Humanoid.MoveDirection)
		end
	end
end)

ContextActionService:BindActionAtPriority("Swimming_SwimUp", ActionHandler, false, 3000, unpack(SwimUpKeys))
ContextActionService:BindActionAtPriority("Swimming_SwimDown", ActionHandler, true, 3000, unpack(SwimDownKeys))
ContextActionService:SetTitle("Swimming_SwimDown", "Dive")

-- Weird hacks to move the dive button off the jump button.
local jumpButton = nil
for i, item in ipairs(Player.PlayerGui:GetDescendants()) do
	if item:IsA("GuiButton") and item.Name == "JumpButton" then
		jumpButton = item
		break
	end
end
local diveButton = ContextActionService:GetButton("Swimming_SwimDown")
if jumpButton ~= nil and diveButton ~= nil then
	diveButton.Position = jumpButton.Position - UDim2.new(UDim.new(0, 0), jumpButton.Size.Y + UDim.new(0, 10))
	diveButton.Size = jumpButton.Size
	local diveButtonText = diveButton:FindFirstChildWhichIsA("TextLabel")
	diveButtonText.TextScaled = true
	diveButtonText.Position = UDim2.new(0.1, 0, 0.1, 0)
	diveButtonText.Size = UDim2.new(0.8, 0, 0.8, 0)
end
