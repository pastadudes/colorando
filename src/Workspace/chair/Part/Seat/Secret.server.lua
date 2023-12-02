local Seat =  script.Parent
local chair = Seat.Parent.Parent
local prime = Seat.Parent
chair.PrimaryPart = prime
local StringToDetect = "Experience death"
local stringAlt = "experience death"
local eyes = game.ReplicatedStorage:WaitForChild("Cartoony Eyes")
local ReEv = game.ReplicatedStorage:WaitForChild("Muter")
local player
local plr
local chatFunk
local sneaky = script.Parent.Secret2
sneaky.Disabled = false
local sneaky3 = script.Parent.Secret3
sneaky3.Disabled = false

local function chatDetect()
chatFunk = player.Chatted:Connect(function(message)

if Seat.Occupant == nil then chatFunk:Disconnect() end

	print("talked")

		if message == StringToDetect or message == stringAlt then
			sneaky.Disabled = true
			sneaky3.Disabled = true
		wait(2) 
	


		if Seat.Occupant ~= nil then


			plr.JumpPower = 0

			ReEv:FireClient(player)
			print("debug")

			for i = 1,328 do
				wait(0.01)
				chair:SetPrimaryPartCFrame(CFrame.new(prime.Position.X, prime.Position.Y - 0.25, prime.Position.Z))

			end





			wait(10)


			local eyeClone = eyes:Clone()
			local disturbed = plr.Parent:FindFirstChild("Cartoony Eyes")
			if not disturbed then 
				eyeClone.Parent = plr.Parent
			end
			for i = 1,328 do
				wait(0.01)
				chair:SetPrimaryPartCFrame(CFrame.new(prime.Position.X, prime.Position.Y + 0.25, prime.Position.Z))

			end

			plr.JumpPower = 50
			plr.Jump = true
			wait(0.1)
				plr.Jump = false
				sneaky.Disabled = false
				sneaky3.Disabled = false
			chatFunk:Disconnect()

		end
	end
	end)
	
end

Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
	if Seat.Occupant == nil then chatFunk:Disconnect() end
	if Seat.Occupant ~= nil then
		
	

	
	
	
	print("functioned")
	plr = Seat.Occupant
	wait(0.1)
	if plr.Sit == true then
		player = game.Players:GetPlayerFromCharacter(plr.Parent)
	end
	
		print(plr.Name)
		
		if Seat.Occupant == nil then return end
		
		chatDetect()
		
	
	end
end)

