return function(Modules, ReplicatedModules)
	local public = {}
	local private = {}
	public.Enabled = true

	local Codes = {}

	function public.Init()
		Modules.Remotes.CreateClientRemote("Codes")
		Modules.Remotes.BindClientRemote("Codes", private.ReceiveCode)

		private.CreateCode("sds2019", {CashReward = 50, DiamondsReward = 10, Expiration = -1})
	end

	function private.CreateCode(tag, data)
		assert(Codes[tag] == nil, "Codes already exists")

		Codes[string.upper(tag)] = data
	end

	function private.ReceiveCode(player, extraData)
		if Codes[extraData.Entry] then
			if Codes[extraData.Entry].Expiration < 0 or  Codes[extraData.Entry].Expiration > tick() then
				local playerData = Modules.DataManager.GetPlayerData(player)

				if playerData:RedeemCode(extraData.Entry) then
					if Codes[extraData.Entry].CashReward then
						playerData:AddCash(Codes[extraData.Entry].CashReward)
					end
					if Codes[extraData.Entry].DiamondsReward then
						playerData:AddDiamonds(Codes[extraData.Entry].DiamondsReward)
					end

					Modules.DataManager.UpdateLiveStats(player)
					return true
				end
			end
		end

		return false
	end

	return public
end