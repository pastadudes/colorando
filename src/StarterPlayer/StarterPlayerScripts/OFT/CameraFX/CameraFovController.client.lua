-- Controls the field-of-view of the camera depending on the player's setting.
-- 
-- ForbiddenJ

NormalFov = 70
WideFov = 85

Camera = workspace.CurrentCamera
FovSetting = game.ReplicatedStorage.ClientConfig.WideFOV

function Update()
	Camera.FieldOfView = FovSetting.Value and WideFov or NormalFov
end

FovSetting:GetPropertyChangedSignal("Value"):Connect(Update)

Update()
