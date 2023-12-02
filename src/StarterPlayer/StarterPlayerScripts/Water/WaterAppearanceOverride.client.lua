-- Overrides the mesh of every water body so that players can see the surface of water from beneath.
-- 
-- By ForbiddenJ

WaterLib = require(game.ReplicatedStorage.WaterLib)
WaterBodyTracker = require(game.ReplicatedStorage.WaterBodyTracker)

WaterResizeHooks = {} -- Table of RbxScriptSignals indexed by the objects they are attached to.

function TryBindWater(water)
	local mesh = water:FindFirstChild("_WaterAppearanceMesh")
	if mesh == nil then
		mesh = Instance.new("SpecialMesh")
		mesh.Name = "_WaterAppearanceMesh"
		mesh.MeshType = Enum.MeshType.Brick
		mesh.Scale = Vector3.new(1, 0, 1)
		mesh.Parent = water
	end
	if mesh:IsA("SpecialMesh") then
		local function update(...)
			mesh.Offset = Vector3.new(0, water.Size.Y / 2, 0)
		end
		
		update()
		
		WaterResizeHooks[water] = water:GetPropertyChangedSignal("Size"):Connect(update)
	end
end
function TryUnbindWater(water)
	if WaterResizeHooks[water] ~= nil then
		WaterResizeHooks[water]:Disconnect()
		WaterResizeHooks[water] = nil
	end
end

for i, water in ipairs(WaterBodyTracker.WaterBodies) do
	TryBindWater(water)
end
WaterBodyTracker.OnWaterBodyAdded:Connect(TryBindWater)
WaterBodyTracker.OnWaterBodyLost:Connect(TryUnbindWater)
