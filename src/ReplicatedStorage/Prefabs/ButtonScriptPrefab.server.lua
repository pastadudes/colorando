-- Manages the basic behavior of a button.
-- 
-- MapRunner works with this script to manage a button in relation to gameplay.
-- 
-- ForbiddenJ



GameLib = require(game.ReplicatedStorage.GameLib)

assert(GameLib.IsButton(script.Parent), "ButtonScript will only work in buttons.")

ButtonLightProperties = {
	Pressed = {
		Material = Enum.Material.SmoothPlastic,
		BrickColor = BrickColor.new("Crimson"),
	},
	Active = {
		Material = Enum.Material.Neon,
		BrickColor = BrickColor.new("Bright green"),
	},
	ActiveGroup = {
		Material = Enum.Material.Neon,
		BrickColor = BrickColor.new("Bright blue"),
	},
	Inactive = {
		Material = Enum.Material.Neon,
		BrickColor = BrickColor.new("Bright yellow"),
	},
}

CharactersWhoTouchedButton = {}
ChangeEventFiring = false

ButtonModel = script.Parent
Hitbox = script.Parent.Hitbox
PressSound = script.Parent.Hitbox._PressSound
ButtonState = script.Parent._ButtonState
BashCount = script.Parent._BashCount
BashCountNeeded = script.Parent._BashCountNeeded
GetTouchedPlayersBindable = script.Parent._GetTouchedPlayers

function HasTouchedButton(character)
	for i, item in ipairs(CharactersWhoTouchedButton) do
		if item == character then
			return true
		end
	end
	return false
end
function GetTouchedPlayers()
	local players = {}
	for i, character in ipairs(CharactersWhoTouchedButton) do
		local player = game.Players:GetPlayerFromCharacter(character)
		if player ~= nil then
			table.insert(players, player)
		end
	end
	return players
end
function OnTouch(otherPart)
	local character = otherPart.Parent
	local humanoid = character and character:FindFirstChild("Humanoid")
	local torso = character and character:FindFirstChild("HumanoidRootPart")
	local hitboxRadius = Hitbox.Size.Magnitude / 2 -- Reaches to corner of box.
	local distance = torso and (torso.Position - Hitbox.Position).Magnitude
	if (ButtonState.Value == "Active" or ButtonState.Value == "ActiveGroup")
		and humanoid ~= nil and humanoid:GetState() ~= Enum.HumanoidStateType.Dead
		and torso ~= nil and not HasTouchedButton(character) then
		
		if distance <= hitboxRadius + 11 then
			PressSound:Play()
			local light = ButtonModel:FindFirstChild("Light")
				light.Size -= Vector3.new(0, 0.4, 0)
			
			table.insert(CharactersWhoTouchedButton, character)
			BashCount.Value = #CharactersWhoTouchedButton
			OnPressStateChange()
		else
			warn(string.format("[%s] %s sent a touch signal, but was %i studs away!", ButtonModel.Name, character.Name, distance))
		end
	end
end
function OnPressStateChange()
	if not ChangeEventFiring then
		ChangeEventFiring = true
		
		if (ButtonState.Value == "Active" and BashCount.Value >= 1)
			or (ButtonState.Value == "ActiveGroup" and BashCount.Value >= BashCountNeeded.Value) then
			
			ButtonState.Value = "Pressed"
			CharactersWhoTouchedButton = {} -- Must be done after the change so watchers can get the list beforehand.
		elseif ButtonState.Value == "Inactive" or ButtonState.Value == "Pressed" then
			CharactersWhoTouchedButton = {}
		end
		
		ChangeEventFiring = false
	end
end

Hitbox.Touched:Connect(OnTouch)
ButtonState.Changed:Connect(function(buttonState)
	local light = ButtonModel:FindFirstChild("Light")
	if light ~= nil then
		for property, value in pairs(ButtonLightProperties[buttonState]) do
			light[property] = value
			
		end
	end
	if buttonState ~= "Active" and buttonState ~= "ActiveGroup" then
		CharactersWhoTouchedButton = {}
	end
end)
BashCountNeeded.Changed:Connect(OnPressStateChange)
GetTouchedPlayersBindable.OnInvoke = GetTouchedPlayers
