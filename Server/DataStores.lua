return function(Modules, ReplicatedModules)
	local public = {}
	local private = {}
	public.Enabled = true

	local DataStoreService = game:GetService("DataStoreService")
	local Remotes = game.ReplicatedStorage.Remotes

	private.STUDIO_LOADS = false
	private.STUDIO_SAVES = false
	private.MAX_TRIES = 4
	private.RETRY_TIME = 5

	local LoadedDataStores = {PlayerData = DataStoreService:GetDataStore("PlayerData_alpha9")}

	function public.LoadData(index, userId)
		local tries = 0
		local success, data
		repeat
			success, data = pcall(function()
				if game:GetService("RunService"):IsStudio() and private.STUDIO_LOADS then
					return LoadedDataStores[index]:GetAsync(userId)
				elseif not game:GetService("RunService"):IsStudio() then
					return LoadedDataStores[index]:GetAsync(userId)
				end
			end)
			if not success then
				tries = tries + 1
				wait(private.RETRY_TIME ^ tries)
			end
		until success or tries >= private.MAX_TRIES
		return data
	end

	function public.SaveData(index, userId, data, raw)
		local tries = 0
		local success
		repeat
			success = pcall(function()
				if game:GetService("RunService"):IsStudio() and private.STUDIO_SAVES then
					LoadedDataStores[index]:SetAsync(userId, data)
				elseif not game:GetService("RunService"):IsStudio() then
					LoadedDataStores[index]:SetAsync(userId, data)
				end
			end)
			if not success then
				tries = tries + 1
				wait(private.RETRY_TIME ^ tries)
			end
		until success or tries >= private.MAX_TRIES or raw
	end

	return public
end
