return function(Modules, ReplicatedModules)
	local public = {}
	local private = {}
	public.Enabled = true
	
	local PlayerLeaderstats = {}
	local Stats = {}
	
	function public.Init()
		private.AddStat("Cash", "Cash", "NumberValue", private.OutValue)
		
		Modules.DataManager.BindToPlayerAdded(private.PlayerJoined)
	end
	
	function public.UpdateStats(player)
		if PlayerLeaderstats[player] then
			local playerData = Modules.DataManager.GetPlayerData(player)
				
			for tag, data in pairs(Stats) do
				PlayerLeaderstats[player]:FindFirstChild(data.Name).Value = data.Function(playerData[data.BindData])
			end
		end
	end
	
	function private.AddStat(name, bindData, dataType, func)
		Stats[name] = {Name = name, BindData = bindData, DataType = dataType, Function = func}
	end
	
	function private.PlayerJoined(player)
		local leaderstats = Instance.new("IntValue")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
		PlayerLeaderstats[player] = leaderstats
		
		for tag, data in pairs(Stats) do
			local stat = Instance.new(data.DataType)
			stat.Name = data.Name
			stat.Parent = leaderstats
		end
	end
	
	function private.OutValue(value)
		return tostring(value)
	end
	
	return public
end