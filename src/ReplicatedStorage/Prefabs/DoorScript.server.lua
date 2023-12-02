-- Manages an OFT lobby door.
-- 
-- ForbiddenJ

TweenLib = require(game.ReplicatedStorage.TweenLib)
GameLib = require(game.ReplicatedStorage.GameLib)

OpenUpperAngle = script.Parent.OpenUpperAngle
OpenLowerAngle = script.Parent.OpenLowerAngle
ClosedAngle = script.Parent.ClosedAngle
IsOpen = script.Parent.IsOpen
IsStuck = script.Parent.IsStuck

DoorPart = script.Parent.Door
Hinge = script.Parent.Hinge
ProximityPrompt = script.Parent.Door.ProximityPrompt

InteractionCoolingDown = false

function Update(isInstant)
	if DoorPart:CanSetNetworkOwnership() then
		DoorPart:SetNetworkOwner(nil)
	end
	
	ProximityPrompt.Enabled = not IsStuck.Value
	ProximityPrompt.ActionText = IsOpen.Value and "Close" or "Open"
	
	TweenLib.StopTween(Hinge, "HingeTween")
	if isInstant then
		Hinge.UpperAngle = IsOpen.Value and OpenUpperAngle.Value or ClosedAngle.Value
		Hinge.LowerAngle = IsOpen.Value and OpenLowerAngle.Value or ClosedAngle.Value
	else
		Hinge.UpperAngle = Hinge.CurrentAngle
		Hinge.LowerAngle = Hinge.CurrentAngle
		
		TweenLib.TweenObject(
			Hinge,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				UpperAngle = IsOpen.Value and OpenUpperAngle.Value or ClosedAngle.Value;
				LowerAngle = IsOpen.Value and OpenLowerAngle.Value or ClosedAngle.Value;
			},
			"HingeTween")
	end
end
function OnInteract(player)
	if IsStuck.Value then
		return
	end
	
	local boxCFrame, boxSize = script.Parent:GetBoundingBox()
	if GameLib.GetProximity(player, boxCFrame.Position) > ProximityPrompt.MaxActivationDistance + boxSize.Magnitude / 2 then
		-- You shall not pass!
		return
	end
	
	if not InteractionCoolingDown then
		InteractionCoolingDown = true
		
		IsOpen.Value = not IsOpen.Value
		
		wait(1.2)
		InteractionCoolingDown = false
	end
end

IsOpen.Changed:Connect(function(...)
	return Update(false)
end)
ProximityPrompt.Triggered:Connect(OnInteract)

Update(true)
