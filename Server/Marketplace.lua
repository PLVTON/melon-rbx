return function(Modules, ReplicatedModules)
	local public = {}
	local private = {}
	public.Enabled = true

	local MarketplaceService = game:GetService("MarketplaceService")

	local FunctionBindings = {}

	function public.Init()
		Modules.DataManager.BindToPlayerAdded(private.PlayerJoined)
	end

	function private.PlayerJoined(player)
		local playerData = Modules.DataManager.GetPlayerData(player)

		for _, gamePassInfo in pairs(game.ServerStorage.ServerData.GamePasses:GetChildren()) do
			if not playerData:OwnsGamePass(gamePassInfo.Name) then
				if MarketplaceService:UserOwnsGamePassAsync(player.UserId, tonumber(gamePassInfo.Name)) then
					playerData:AddGamePass(gamePassInfo.Name)
					if FunctionBindings[tostring(gamePassInfo.Name)] then
						FunctionBindings[tostring(gamePassInfo.Name)](player)
					end
				end
			else
				if FunctionBindings[tostring(gamePassInfo.Name)] then
					FunctionBindings[tostring(gamePassInfo.Name)](player)
				end
			end
		end
	end

	function private.BindGamePass(id, initFunc)
		FunctionBindings[id] = initFunc
	end

	function MarketplaceService.ProcessReceipt(receiptInfo)
		local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if player and game.ServerStorage.ServerData.DevProducts:FindFirstChild(tostring(receiptInfo.ProductId)) then
			local playerData = Modules.DataManager.GetPlayerData(player)
			if playerData then
				playerData:AddCash(game.ServerStorage.ServerData.DevProducts:FindFirstChild(tostring(receiptInfo.ProductId)).Amount.Value)
				playerData:AddRobuxSpent(receiptInfo.CurrencySpent)
				Modules.DataManager.UpdateStats(player, {"Cash"})
				Modules.Remotes.FireRemote("Notifications", player, "you have received your coins! thank you for your purchase!")
				Modules.Remotes.FireRemote("GameEffects", player, "product")

				spawn(function() Modules.DataManager.SaveData(player) end)
			end
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, purchaseSuccess)
		local gamePass = game.ServerStorage.ServerData.GamePasses:FindFirstChild(tostring(gamePassId))
		if purchaseSuccess and gamePass then
			Modules.DataManager.GetPlayerData(player):AddGamePass(gamePassId)
			Modules.Remotes.FireRemote("GameEffects", player, "product")
			if FunctionBindings[tostring(gamePassId)] then
				FunctionBindings[tostring(gamePassId)](player)
			end
		end
	end)
	
	return public
end
