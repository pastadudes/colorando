local db = false
local baseCol = script.Parent.Color

function Touched(part)
	if db then return end
	db = true
	script.Parent.Color = Color3.new(0.87451, 0.113725, 0.12549)
	local parent = part.Parent

	if game.Players:FindFirstChild(parent.Name) then
	
		game.ReplicatedStorage.AntiGrav:FireClient(game.Players:GetPlayerFromCharacter(parent))
	end
	wait(1)
	db = false
	script.Parent.Color = baseCol
end

script.Parent.Touched:Connect(Touched)
