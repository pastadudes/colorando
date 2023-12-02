ThirdPartyAssets = require(game.ReplicatedStorage.GameInfo.AssetList)
AvatarThumnailURL = "https://www.roblox.com/headshot-thumbnail/image?userId=%i&width=100&height=100&format=png"
AssetThumbnailURL = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=150&height=150&assetId=%i"

UIPadding = script.Parent.UIPadding
ServerOwnerHeader = script.Parent.Block01
ServerOwnerTile = script.Parent.Block02
AssetTilePrefab = script.Parent.Block06

-- Populate the third-party asset list.
AssetTilePrefab.Parent = nil
local i = 6
for _, assetInfo in ipairs(ThirdPartyAssets) do
	local tile = AssetTilePrefab:Clone()
	tile.Thumbnail.Image = AssetThumbnailURL:format(assetInfo.AssetID)
	tile.AssetName.Text = assetInfo.AssetName
	tile.CreatorName.Text = assetInfo.CreatorName
	tile.AssetID.Text = assetInfo.AssetID
	tile.Name = string.len(i) == 1 and "Block0" .. i or "Block" .. i
	tile.Parent = script.Parent
	i = i + 1
end

-- Show the server owner name?
if game.CreatorId ~= 0 and game.CreatorId ~= 59846333 and game.CreatorType == Enum.CreatorType.User then
	ServerOwnerTile.ImageLabel.Image = AvatarThumnailURL:format(game.CreatorId)
	ServerOwnerTile.TextLabel.Text = game.Players:GetNameFromUserIdAsync(game.CreatorId)
else
	ServerOwnerHeader.Visible = false
	ServerOwnerTile.Visible = false
end

-- Calculate the height
local canvasHeight = UIPadding.PaddingTop + UIPadding.PaddingBottom
for i, item in ipairs(script.Parent:GetChildren()) do
	if item:IsA("GuiObject") and item.Visible then
		canvasHeight = canvasHeight + item.Size.Y
	end
end
script.Parent.CanvasSize = UDim2.new(UDim.new(0, 0), canvasHeight)
