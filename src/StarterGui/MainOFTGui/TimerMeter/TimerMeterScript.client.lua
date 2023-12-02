TimerAlpha = game.ReplicatedStorage.Game.TimerAlpha

TimerMeterBar = script.Parent.Bar

function UpdateMeterBar()
	--TimerMeterBar.Size = UDim2.new(TimerAlpha.Value, 0, 1, 0)
	TimerMeterBar:TweenSize(UDim2.new(TimerAlpha.Value, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

UpdateMeterBar()

TimerAlpha.Changed:Connect(UpdateMeterBar)
