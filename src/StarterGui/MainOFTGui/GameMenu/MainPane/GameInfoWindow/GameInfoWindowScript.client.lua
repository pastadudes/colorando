-- Manages the About window.
-- 
-- ForbiddenJ

RunService = game:GetService("RunService")
TeleportService = game:GetService("TeleportService")
MarketplaceService = game:GetService("MarketplaceService")

Player = game.Players.LocalPlayer
GameTitle = game.ReplicatedStorage.GameInfo.Title
GameVersion = game.ReplicatedStorage.GameInfo.VersionString

Title = script.Parent.Title
DonateButton1 = script.Parent.ContentPane.DonateButton1
DonateButton2 = script.Parent.ContentPane.DonateButton2
DownloadWithStudioText = script.Parent.ContentPane.DownloadWithStudioText
TeleportText = script.Parent.ContentPane.TeleportText
TeleportButton = script.Parent.ContentPane.TeleportButton

TeleportRequested = false

function OnDonateButton1Click()
	MarketplaceService:PromptPurchase(Player, 3544260696)
end
function OnDonateButton2Click()
	MarketplaceService:PromptPurchase(Player, 3590997013)
end
function TeleportToOriginalGame()
	if not TeleportRequested then
		TeleportRequested = true
		TeleportButton.Text = "Teleporting..."
		TeleportService:Teleport(2957980554)
	end
end

if RunService:IsStudio() then
	TeleportText.Visible = false
	TeleportButton.Visible = false
	DownloadWithStudioText.Visible = false
elseif game.PlaceId ~= 2957980554 then
	TeleportText.Visible = true
	TeleportButton.Visible = true
	DownloadWithStudioText.Visible = false
else
	TeleportText.Visible = false
	TeleportButton.Visible = false
	DownloadWithStudioText.Visible = true
end

Title.Value = "About " .. GameTitle.Value .. " " .. GameVersion.Value

TeleportButton.MouseButton1Click:Connect(TeleportToOriginalGame)
DonateButton1.MouseButton1Click:Connect(OnDonateButton1Click)
DonateButton2.MouseButton1Click:Connect(OnDonateButton2Click)