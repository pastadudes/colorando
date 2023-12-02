local ChatService = game:GetService("Chat")
local choice
local part = Instance.new("Part")
part.Anchored = true
part.Parent = game.Workspace.lobby:WaitForChild("sus dude")
part.Position = game.Workspace.lobby:WaitForChild("sus dude"):WaitForChild("Head").Position
part.Transparency = 1
part.CanCollide = false
while wait (10) do
	choice = math.random(1,24) --having a higher number makes it possible to alter the odds of getting a certain dialog, for example, borgir dialog has a 50% percent chance atm
	if choice <= 16 and choice > 4 then
	ChatService:Chat(part, "eat those hamborgirs")
	wait(2)
	ChatService:Chat(part, "im not sus")
	wait(1)
		ChatService:Chat(part, "the sign is lying to you")
	end
	if choice <= 4 then
		ChatService:Chat(part, "stay away from the hall of the sacreds")
	end
	if choice >= 1 then
		--insert chat here
	end
	if choice >= 1 then
		--insert chat here
	end
	
	wait(3)
end

