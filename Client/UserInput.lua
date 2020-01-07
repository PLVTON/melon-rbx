return function(Modules, ReplicatedModules)
	local public = {}
	local private = {}

	private.InputFunctions = {
		Vertical = {},
		Horizontal = {},
		Scrolling = {},
		Spacebar = {},
		Click = {},
		Shift = {}
	}

	local UserInputService

	function public.Init()
		UserInputService = game:GetService("UserInputService")

		UserInputService.InputBegan:Connect(private.UserInputBegan)
		UserInputService.InputEnded:Connect(private.UserInputEnded)
		UserInputService.InputChanged:Connect(private.UserInputChanged)
		UserInputService.TouchPinch:Connect(private.UserTouchPinch)
		UserInputService.TouchTapInWorld:Connect(private.TouchTapInWorld)

		if game.Players.LocalPlayer.Character then
			game.Players.LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("Jump"):Connect(private.SpacebarInput)
		end

		game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
			character:WaitForChild("Humanoid"):GetPropertyChangedSignal("Jump"):Connect(private.SpacebarInput)
		end)
	end

	function public.Bind(inputType, func)
		assert(private.InputFunctions[inputType], "InputType doesn't exist in this context")
		table.insert(private.InputFunctions[inputType], func)
	end

	function private.UserInputBegan(input, gameProcessed)
		if not gameProcessed then
			-- Horizontal & Vertical Input
			if input.KeyCode == Enum.KeyCode.W then
				for _, func in pairs(private.InputFunctions.Vertical) do
					func(1)
				end
			elseif input.KeyCode == Enum.KeyCode.S then
				for _, func in pairs(private.InputFunctions.Vertical) do
					func(-1)
				end
			elseif input.KeyCode == Enum.KeyCode.A then
				for _, func in pairs(private.InputFunctions.Horizontal) do
					func(1)
				end
			elseif input.KeyCode == Enum.KeyCode.D then
				for _, func in pairs(private.InputFunctions.Horizontal) do
					func(-1)
				end
			elseif input.KeyCode == Enum.KeyCode.O then
				for _, func in pairs(private.InputFunctions.Scrolling) do
					func(-1)
				end
			elseif input.KeyCode == Enum.KeyCode.I then
				for _, func in pairs(private.InputFunctions.Scrolling) do
					func(1)
				end
			elseif input.KeyCode == Enum.KeyCode.LeftShift then
				for _, func in pairs(private.InputFunctions.Shift) do
					func(true)
				end
			end
		end
	end

	function private.TouchTapInWorld(touchposition, gameprocessed)
		if not gameprocessed then
			-- Clicks and taps
			for _, func in pairs(private.InputFunctions.Click) do
				func()
			end
		end
	end

	function private.UserInputEnded(input, gameProcessed)
		if not gameProcessed then
			-- Horizontal & Vertical Input
			if input.KeyCode == Enum.KeyCode.W then
				for _, func in pairs(private.InputFunctions.Vertical) do
					func(UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0)
				end
			elseif input.KeyCode == Enum.KeyCode.S then
				for _, func in pairs(private.InputFunctions.Vertical) do
					func(UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
				end
			elseif input.KeyCode == Enum.KeyCode.A then
				for _, func in pairs(private.InputFunctions.Horizontal) do
					func(UserInputService:IsKeyDown(Enum.KeyCode.D) and -1 or 0)
				end
			elseif input.KeyCode == Enum.KeyCode.D then
				for _, func in pairs(private.InputFunctions.Horizontal) do
					func(UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
				end
			elseif input.KeyCode == Enum.KeyCode.LeftShift then
				for _, func in pairs(private.InputFunctions.Shift) do
					func(false)
				end
			end
			-- Clicks and taps
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				for _, func in pairs(private.InputFunctions.Click) do
					func()
				end
			end
		end
	end

	function private.UserInputChanged(input, gameProcessed)
		if not gameProcessed then
			-- Computer Scrolling
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				for _, func in pairs(private.InputFunctions.Scrolling) do
					func(input.Position.Z)
				end
			end
		end
	end

	function private.UserTouchPinch(touchPositions, scale, velocity, state, gameProcessed)
		if not gameProcessed and velocity and type(velocity*0.35) == "number" and math.abs(velocity * 0.35) > 0 then
			for _, func in pairs(private.InputFunctions.Scrolling) do
				func(velocity * 0.08)
			end
		end
	end

	function private.SpacebarInput()
		if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			for _, func in pairs(private.InputFunctions.Spacebar) do
				func(game.Players.LocalPlayer.Character.Humanoid.Jump)
			end
		end
	end

	return public
end
