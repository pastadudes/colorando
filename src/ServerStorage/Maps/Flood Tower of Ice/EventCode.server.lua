local Lib = workspace.Multiplayer.GetMapVals:Invoke() --Has: Map, Script, Button, btnFuncs
Lib.Button:connect(function(p, bNo)
	if Lib.btnFuncs[bNo] then
		Lib.btnFuncs[bNo](bNo, p)
	end
end)

wait(10)
Lib.Script.moveWater(Lib.Map._Water1, Vector3.new(0, 240, 0), 80, true)
wait(40)
Lib.Script.setWaterState(Lib.Map._Water1, "acid")
--Lib.Script.setWaterState(Lib.Map._Water1, "lava")
--wait(3)
