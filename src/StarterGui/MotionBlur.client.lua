local camera = workspace.CurrentCamera
local blurAmount = 5
local blurAmplifier = 10
local lastVector = camera.CFrame.LookVector

local motionBlur = Instance.new("BlurEffect", camera)

local runService = game:GetService("RunService")

workspace.Changed:Connect(function(property)
	if property == "CurrentCamera" then
		print("Changed")
		local camera = workspace.CurrentCamera
		if motionBlur and motionBlur.Parent then
			motionBlur.Parent = camera
		else
			motionBlur = Instance.new("BlurEffect", camera)
		end
	end
end)

runService.Heartbeat:Connect(function()
	if not motionBlur or motionBlur.Parent == nil then
		motionBlur = Instance.new("BlurEffect", camera)
	end

	local magnitude = (camera.CFrame.LookVector - lastVector).magnitude
	motionBlur.Size = math.abs(magnitude)*blurAmount*blurAmplifier/2
	lastVector = camera.CFrame.LookVector
end)