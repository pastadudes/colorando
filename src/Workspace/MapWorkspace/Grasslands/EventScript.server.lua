local Lib = workspace.Multiplayer.GetMapVals:Invoke() --Has: Map, Script, Button, btnFuncs
local light = game.Lighting
Lib.Button:connect(function(p, bNo) if Lib.btnFuncs[bNo] then Lib.btnFuncs[bNo](bNo, p) end end)

wait(15)

Lib.Script.moveWater(Lib.Map._Water1, Vector3.new(0, 37.4, 0), 40, true)
	


wait(30)
Lib.Script.setWaterState(Lib.Map._Water1, "acid")


wait(5)
Lib.Script.setWaterState(Lib.Map._Water1, "lava")


wait(1)

Lib.Script.moveWater(Lib.Map._Water1, Vector3.new(0, 2, 0), 15, true)