local clickDetector = workspace.ColorandoShirt.Prompt.ClickDetector
local clickDetector2 = workspace.ColorandoPants.Prompt.ClickDetector

function onMouseClick()
	print("You clicked me!")
	game:GetService("MarketplaceService"):PromptPurchase(game.Players.LocalPlayer, 9890943165)
end

clickDetector.MouseClick:connect(onMouseClick)

function onMouseClick2()
	print("You clicked me!")
	game:GetService("MarketplaceService"):PromptPurchase(game.Players.LocalPlayer, 9891365059)
end

clickDetector2.MouseClick:connect(onMouseClick2)