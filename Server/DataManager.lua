return function(Modules, ReplicatedModules)
	local public = {}
	local private = {}
	public.Enabled = true

	local MarketplaceService = game:GetService("MarketplaceService")
	
	local PlayerAddedBindings = {}
	local PlayerDatas = {}

	function public.Awake()
		Modules.Remotes.CreateRemote("UpdateStats")
		Modules.Remotes.CreateRemote("GameEffects")
		Modules.Remotes.CreateRemote("Notifications")
	end

	function public.Init()
		public.BindToPlayerAdded(private.PlayerJoined)

		game.Players.PlayerAdded:Connect(function(player)
			Modules.Remotes.YieldToConnection(player, 8000)
			wait(0.5)
			private.SetupPlayer(player)

			for _, f in pairs(PlayerAddedBindings) do
				f(player)
			end
		end)

		game.Players.PlayerRemoving:Connect(function(player)
			public.SaveData(player)
		end)

		game:BindToClose(private.ShutServer)

		spawn(private.AutoSave)
	end

	function public.BindToPlayerAdded(f)
		table.insert(PlayerAddedBindings, f)
	end

	function private.SetupPlayer(player)
		PlayerDatas[player] = Modules.PlayerData:New(player, public.LoadData(player))
		public.UpdateStats(player, {"Cash", "InventoryId", "InventoryIds", "Counter", "Rank", "GamePasses"})
	end

	function public.GetPlayerData(player, specialCase)
		if not PlayerDatas[player] then warn("Player Data doesn't exist", specialCase) end
		return PlayerDatas[player]
	end

	function public.UpdateStats(player, indexTable)
		local packedData = public.GetPlayerData(player):PackNeededData(indexTable)
		Modules.Remotes.FireRemote("UpdateStats", player, packedData)
	end

	function public.SaveData(player)
		local playerData = Modules.DataManager.GetPlayerData(player)
		if playerData then
			Modules.DataStores.SaveData("PlayerData", player.UserId, playerData:GetSaveData())
		end
	end

	function public.LoadData(player)
		return Modules.DataStores.LoadData("PlayerData", player.UserId)
	end

	function private.AutoSave()
		wait(40)
		for _, player in pairs(game.Players:GetChildren()) do
			public.SaveData(player)
			wait(5)
		end
	end

	function private.ShutServer()
		if game:GetService("RunService"):IsStudio() then
			return
		end
		wait(10)
		print("farewell my friend, its been a fun ride..")
	end

	return public
end
