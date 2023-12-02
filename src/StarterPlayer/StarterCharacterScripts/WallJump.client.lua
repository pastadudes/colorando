-- Makes the player's character able to grab walls and jump.
--
-- The script can be used without other scripts. It should be
-- left as a child of StarterCharacterScripts for best results.
-- 
-- By ForbiddenJ

local RunService = game:GetService("RunService")

local WallJumpSoundURL = "rbxasset://sounds/action_jump.mp3"
local WallAttachSoundURL = "rbxasset://sounds/action_jump_land.mp3"
local WallGripDuration = 1
local JumpCooldown = 0.1
local GrabCooldown = 0.1

local Humanoid = script.Parent.Humanoid
local RootPart = Humanoid.RootPart
local RootAttachment = RootPart.RootAttachment
local AnimateScript = script.Parent:WaitForChild("Animate")
local WallJumpAnim = game.ReplicatedStorage.AnimationStorage.WallJump
local WallJumpAnimTrack = nil

local WallGripLeft = 0 -- To make players fall off eventually.
local JumpWait = 0 -- To prevent accidental auto-jumping.
local GrabWait = 0 -- To prevent players grabbing the wall forever with shift-lock.
local CurrentConstraint = nil
local CurrentAttachment = nil
local OldWalkspeed = 0
local GripLookVector = Vector3.new(0, 0, -1)

local WallJumpSound = Instance.new("Sound")
WallJumpSound.Name = "WallJumpSound"
WallJumpSound.SoundId = WallJumpSoundURL
WallJumpSound.Volume = 4
WallJumpSound.Parent = RootPart

local function LoseGrip()
	WallGripLeft = 0
	GrabWait = GrabCooldown
	Humanoid.WalkSpeed = OldWalkspeed
	CurrentConstraint:Destroy()
	CurrentConstraint = nil
	CurrentAttachment:Destroy()
	CurrentAttachment = nil
	WallJumpAnimTrack:Stop()
	Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
end

RunService.Heartbeat:Connect(function(deltaTime)
	if CurrentConstraint == nil and GrabWait <= 0 and Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
		-- When the character is falling in front of a wall, attach it to the wall.
		local ray = Ray.new(RootPart.Position, RootPart.CFrame.LookVector * 1.7)
		local hit, point, normal = workspace:FindPartOnRay(ray, script.Parent)
		local hitTag = hit and hit:FindFirstChild("_Wall")
		if hitTag then
			-- Temporarily attach the Humanoid to the wall.
			local normalCFrame = hit.CFrame:ToObjectSpace(CFrame.new(Vector3.new(0, 0, 0), normal))
			normalCFrame = normalCFrame - normalCFrame.Position
			local offsetCFrame = CFrame.new((hit.CFrame:inverse() * RootPart.CFrame).Position)
			local newCFrame = hit.CFrame * offsetCFrame * normalCFrame
			
			RootPart.CFrame = newCFrame
			GripLookVector = newCFrame.LookVector
			OldWalkspeed = Humanoid.WalkSpeed
			Humanoid.WalkSpeed = 0
			
			CurrentAttachment = Instance.new("Attachment")
			CurrentAttachment.Name = "WallJumpAttachment"
			CurrentAttachment.CFrame = offsetCFrame * normalCFrame
			CurrentAttachment.Parent = hit
			CurrentConstraint = Instance.new("BallSocketConstraint")
			CurrentConstraint.Attachment0 = CurrentAttachment
			CurrentConstraint.Attachment1 = RootAttachment
			CurrentConstraint.Name = "WallWeld"
			CurrentConstraint.Parent = RootPart
			game.Debris:AddItem(CurrentAttachment, WallGripDuration + 1)
			game.Debris:AddItem(CurrentConstraint, WallGripDuration + 1)
			
			WallJumpSound.SoundId = WallAttachSoundURL
			WallJumpSound:Play()
			WallJumpAnimTrack:Play()
			
			WallGripLeft = WallGripDuration
			JumpWait = JumpCooldown
		end
	elseif CurrentConstraint ~= nil then
		-- When the character holds on to the wall for too long, make it lose hold.
		WallGripLeft = math.max(0, WallGripLeft - deltaTime)
		if WallGripLeft <= 0 then
			LoseGrip()
		end
	end
	JumpWait = math.max(0, JumpWait - deltaTime)
	GrabWait = math.max(0, GrabWait - deltaTime)
end)
Humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
	-- When the character jumps and they're attached to a wall, propel them away from it.
	if CurrentConstraint ~= nil and Humanoid.Jump and JumpWait <= 0 then
		LoseGrip()
		
		-- Propel the character away from the wall.
		WallJumpSound.SoundId = WallJumpSoundURL
		WallJumpSound:Play()
		RootPart.Velocity =
			RootPart.Velocity +
			Vector3.new(0, Humanoid.JumpPower * 1.1, 0) +
			(GripLookVector * Humanoid.JumpPower)
	end
end)

WallJumpAnimTrack = Humanoid:LoadAnimation(WallJumpAnim)
WallJumpAnimTrack.Priority = Enum.AnimationPriority.Movement
