local Seat =  script.Parent -- Path to seat
local chair = Seat.Parent.Parent
local prime = Seat.Parent
chair.PrimaryPart = prime
local StringToDetect = "Hall of the sacreds";
local String2 = "hall of the sacreds";
local String3 = "hall of the Sacreds";
local String4 = "Hall of the Sacreds";
local door = game.Workspace:WaitForChild("SecretDoor")
local chatFunk
local sneaky = script.Parent.Secret
sneaky.Disabled = false
local sneaky2 = script.Parent.Secret2
sneaky2.Disabled = false

local function chatDetect()
	chatFunk = player.Chatted:Connect(function(message)



		print("talked")

		if message == message == StringToDetect or message == String2 or message == String3 or message == String4 then
			sneaky.Disabled = true
			sneaky2.Disabled = true
			wait(2) 



			if Seat.Occupant ~= nil then


				plr.JumpPower = 0


				


				for i = 1,88 do
					wait(0.01)
					chair:SetPrimaryPartCFrame(CFrame.new(prime.Position.X, prime.Position.Y + 0.25, prime.Position.Z))

				end
				
				wait(3)

				if plr.Parent:FindFirstChild("Vial") ~= nil then
					local vial = plr.Parent:FindFirstChild("Vial")
					vial:Destroy()
					local holy = game.ReplicatedStorage:WaitForChild("Holy vial")
					local sacred = holy:Clone()
					sacred.Parent = plr.Parent
				else
					print("vialNotFound")
				end


				wait(5)


				for i = 1,88 do
					wait(0.01)
					chair:SetPrimaryPartCFrame(CFrame.new(prime.Position.X, prime.Position.Y - 0.25, prime.Position.Z))

				end
				
				
				
				
				
				
				


				plr.JumpPower = 50
				sneaky.Disabled = false
				sneaky2.Disabled = false
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



