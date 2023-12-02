local Tool = script.Parent;

enabled = true




function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	Tool.GripForward = Vector3.new(-.981, .196, 0)
	Tool.GripPos = Vector3.new(-.5, -0.6, -1.5)
	Tool.GripRight = Vector3.new(0, -0, -1)
	Tool.GripUp = Vector3.new(0.196, .981, 0)


	Tool.Handle.DrinkSound:Play()

	wait(.8)
	
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		if (h.MaxHealth < h.Health + 101) then
			h.Health = h.Health - 100
		else	
			h.Health = h.MaxHealth
		end
	end

	Tool.GripForward = Vector3.new(-1, 0, 0)
	Tool.GripPos = Vector3.new(-.5, -.1, 0)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripUp = Vector3.new(0,1,0)


	enabled = true

end

function onEquipped()
	Tool.Handle.OpenSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
