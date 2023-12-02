local Lib = workspace.Multiplayer.GetMapVals:Invoke() --Has: Map, Script, Button, btnFuncs
Lib.Button:connect(function(p, bNo) if Lib.btnFuncs[bNo] then Lib.btnFuncs[bNo](bNo, p) end end)

local FloodHeight = 0

local function ChangeFloodHeight(newFloodHeight, duration)
	Lib.Script.moveWater(script.Parent._Water1, Vector3.new(0, newFloodHeight - FloodHeight, 0), duration, true)
	FloodHeight = newFloodHeight
	
	if newFloodHeight > 0 then
		delay(2, function(...)
			for i, lantern in ipairs(Lib.Map.Intro:GetChildren()) do
				if lantern.Name == "Lantern" then
					lantern.Fire.Enabled = false
					lantern.PointLight.Enabled = false
				end
			end
		end)
	end
end
--local function DropWall(wall)
--	local tween = game.TweenService:Create(
--		wall,
--		TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
--		{CFrame = wall.CFrame * CFrame.new(0, -wall.Size.Y, 0)})
--	tween.Parent = wall
--	tween.Completed:Connect(function(...)
--		return tween:Destroy()
--	end)
--	tween:Play()
--end

Lib.btnFuncs[1] = function()
--	DropWall(script.Parent.Barrier1)
	ChangeFloodHeight(32, 5)
end
Lib.btnFuncs[2] = function()
--	DropWall(script.Parent.Barrier2)
	ChangeFloodHeight(64, 4)
end

wait(60)
ChangeFloodHeight(64, 4)
wait(45)
Lib.Script.setWaterState(script.Parent._Water1, "acid")