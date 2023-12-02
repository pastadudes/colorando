local Lib = workspace.Multiplayer.GetMapVals:Invoke() --Has: Map, Script, Button, btnFuncs
Lib.Button:connect(function(p, bNo) if Lib.btnFuncs[bNo] then Lib.btnFuncs[bNo](bNo, p) end end)
local light = game.Lighting

wait(10)

Lib.Script.moveWater(Lib.Map._Water1, Vector3.new(0, 57.4, 0), 56, true)
	


wait(11)
Lib.Script.setWaterState(Lib.Map._Water1, "acid")


wait(20)
Lib.Script.setWaterState(Lib.Map._Water1, "lava")


wait(2)

Lib.Script.moveWater(Lib.Map._Water1, Vector3.new(0, 30, 0), 28, true)