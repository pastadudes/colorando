game:GetService("UserInputService")
local descendants = game.Workspace:GetDescendants()
local char = script.Parent

local slideAnim = Instance.new("Animation")
slideAnim.AnimationId = "rbxassetid://9888289113" -- the animation id
local keybind = Enum.KeyCode.E -- key for slide
local canSlide = true -- disable sliding
local water = workspace:GetDescendants("water")
local acid = workspace:GetDescendants("acid")
local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input,gameprocessed)
	if gameprocessed then return end
	if not canSlide then return end
	
	

	
	if input.KeyCode == keybind then
		canSlide = false

		local playAnim = char.Humanoid:LoadAnimation(slideAnim)
		playAnim:Play()

		local slide = Instance.new("BodyVelocity")
		slide.MaxForce = Vector3.new(1,0,1) * 30000
		slide.Velocity = char.HumanoidRootPart.CFrame.lookVector * 45
		slide.Parent = char.HumanoidRootPart

		for count = 1, 8 do
			wait(0.1)
			slide.Velocity*= 0.8
		end
		playAnim:Stop()
		slide:Destroy()
		canSlide = true
		
		
	end
end)