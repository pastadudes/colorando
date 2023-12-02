local Lib = workspace.Multiplayer.GetMapVals:Invoke() --Has: Map, Script, Button, btnFuncs
Lib.Button:connect(function(p, bNo) if Lib.btnFuncs[bNo] then Lib.btnFuncs[bNo](bNo, p) end end)

Lib.Script.setWaterState(Lib.Map.Intro._Water1, "acid")
wait(24)
Lib.Script.setWaterState(Lib.Map.Intro._Water1, "lava")
Lib.Script.moveWater(Lib.Map.Intro._Water1, Vector3.new(0, 30, 0), 10, true)
wait(28)
Lib.Script.moveWater(Lib.Map.Intro._Water1, Vector3.new(0, 36, 0), 10, true)
wait(34)
Lib.Script.moveWater(Lib.Map.Intro._Water1, Vector3.new(0, 100, 0), 30, true)