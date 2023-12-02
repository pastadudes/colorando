local Seat =  script.Parent -- Path to seat
local chair = Seat.Parent.Parent
local prime = Seat.Parent
chair.PrimaryPart = prime
local StringToDetect = "Take me to chadland";
local String2 = "take me to chadland";
local String3 = "take me to Chadland";
local String4 = "Take me to Chadland";
local door = game.Workspace:WaitForChild("SecretDoor")
local chatFunk
local sneaky = script.Parent.Secret
sneaky.Disabled = false
local sneaky3 = script.Parent.Secret3
sneaky3.Disabled = false

local function chatDetect()
	chatFunk = player.Chatted:Connect(function(message)



		print("talked")

		if message == message == StringToDetect or message == String2 or message == String3 or message == String4 then
			sneaky.Disabled = true
			sneaky3.Disabled = true
			wait(2) 



			if Seat.Occupant ~= nil then


				plr.JumpPower = 0


				for i = 1,40 do
					wait(0.01)

					door.Position -= Vector3.new(0, 0.25, 0)

				end


				for i = 1,320 do
					wait(0.01)
					chair:SetPrimaryPartCFrame(CFrame.new(prime.Position.X + 0.25, prime.Position.Y, prime.Position.Z))

				end





				wait(3)


				for i = 1,40 do
					wait(0)
					chair:SetPrimaryPartCFrame(CFrame.new(prime.Position.X - 2, prime.Position.Y, prime.Position.Z))

				end
				local bv = Instance.new("BodyVelocity")
				bv.P = 1250
				bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
				bv.Parent = plr.Parent.HumanoidRootPart
				plr.JumpPower = 50
				plr.Jump = true
				wait(0.1)
				plr.Jump = false
				plr.JumpPower = 0
				plr.Sit = true
				bv.Velocity = Vector3.new(-90, 0, 0)
				wait(0.05)
				bv:Destroy()
				plr.JumpPower = 0
				for i = 1,40 do
					wait(0.01)

					door.Position += Vector3.new(0, 0.25, 0)

				end


				plr.JumpPower = 50
				sneaky.Disabled = false
				sneaky.Disabled = false
				chatFunk:Disconnect()

			end
		end
	end)

end

Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
	if Seat.Occupant == nil then chatFunk:Disconnect() end
	if Seat.Occupant ~= nil then






		
		plr = Seat.Occupant
		wait(0.1)
		if plr.Sit == true then
			player = game.Players:GetPlayerFromCharacter(plr.Parent)
		end

		print(plr.Name)

		chatDetect()


	end
end)



