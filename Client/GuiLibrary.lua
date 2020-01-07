return function(Modules, ReplicatedModules)
	local public = {}

	local GameGui
	local FocusData = {Enabled = false, TransitionLength = 10, DarkenTransparencyGoal = 0.5, BlurGoal = 20}
	local CenterPages = {}
	local PageSettings = {}
	local CurrentPage = nil

	function public.Awake()
		GameGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("GameGui")
	end

	function public.GetGameGui()
		repeat wait() until GameGui
		return GameGui
	end

	function public.FocusUIAction()
		FocusData.Enabled = true
		repeat wait()
			GameGui.DarkenBackground.BackgroundTransparency = math.max(GameGui.DarkenBackground.BackgroundTransparency - FocusData.DarkenTransparencyGoal / FocusData.TransitionLength, FocusData.DarkenTransparencyGoal)
			game.Lighting.UIBlur.Size = math.min(game.Lighting.UIBlur.Size + FocusData.BlurGoal / FocusData.TransitionLength, FocusData.BlurGoal)
		until (GameGui.DarkenBackground.BackgroundTransparency <= FocusData.DarkenTransparencyGoal and game.Lighting.UIBlur.Size >= FocusData.BlurGoal) or not FocusData.Enabled
	end

	function public.DefocusUIAction()
		FocusData.Enabled = false
		repeat wait()
			GameGui.DarkenBackground.BackgroundTransparency = math.min(GameGui.DarkenBackground.BackgroundTransparency + FocusData.DarkenTransparencyGoal / FocusData.TransitionLength, 1)
			game.Lighting.UIBlur.Size = math.max(game.Lighting.UIBlur.Size - FocusData.BlurGoal / FocusData.TransitionLength, 0)
		until (GameGui.DarkenBackground.BackgroundTransparency >= 1 and game.Lighting.UIBlur.Size <= 0) or FocusData.Enabled
	end

	function public.BindPageToButton(tag, button)
		button.MouseButton1Click:Connect(function()
			public.OpenPage(tag)
		end)
	end

	function public.CreateCenterPage(tag, page, goBackPageTag)
		assert(typeof(tag) == "string", "UI Page tag must be a string")
		assert(typeof(page) == "Instance" and page:IsA("GuiObject"), "UI Page must be a GuiObject")

		CenterPages[tag] = page
		if page:FindFirstChild("BackButton") then
			page.BackButton.MouseButton1Click:Connect(function()
				if goBackPageTag then
					public.OpenPage(goBackPageTag)
				else
					public.ClosePage(tag)
				end
			end)
		end
	end

	function public.OpenPage(tag)
		if CurrentPage and CurrentPage ~= CenterPages[tag] then
			CurrentPage:TweenPosition(UDim2.new(0.5, 0, -0.5, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.2, true)
		end
		if CenterPages[tag] then
			CurrentPage = CenterPages[tag]
			CenterPages[tag]:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.2, true)
			--Modules.GuiLibrary.FocusUIAction()
		end
	end

	function public.ClosePage(tag)
		CurrentPage = nil
		if tag and CenterPages[tag] then
			CenterPages[tag]:TweenPosition(PageSettings[tag] and PageSettings[tag].EndPosition or UDim2.new(0.5, 0, -0.5, 0),
				Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.2, true)
		else
			for tag, page in pairs(CenterPages) do
				page:TweenPosition(PageSettings[tag] and PageSettings[tag].EndPosition or UDim2.new(0.5, 0, -0.5, 0),
					Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.2, true)
			end
		end
	end

	function public.SetPageSettings(tag, settingsTable)
		assert(CenterPages[tag], "Page doesn't exist")
		PageSettings[tag] = settingsTable
	end

	function public.HideAllPages()
		CurrentPage = nil
		for tag, page in pairs(CenterPages) do
			page:TweenPosition(PageSettings[tag] and PageSettings[tag].EndPosition or UDim2.new(0.5, 0, -0.5, 0),
				Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.2, true)
		end
	end

	function public.CircleIn()
		GameGui.CircleZoom:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.7, true)
	end

	function public.CircleOut()
		GameGui.CircleZoom:TweenSize(UDim2.new(1.5, 0, 1.5, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.7, true)
	end

	return public
end
