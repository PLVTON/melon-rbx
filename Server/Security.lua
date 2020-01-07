return function(Modules, ReplicatedModules)
	local public = {}
	public.Enabled = true

	local PlayerWarnings = {}

	local MAX_WARNINGS = 3

	function public.Init()

	end

	function public.WarnPlayer(player)
		warn("Warning ", player.Name)
		PlayerWarnings[player] = 1 + (PlayerWarnings[player] or 0)

		if PlayerWarnings[player] >= MAX_WARNINGS then
			player:Kick("OOOOF")
		end
	end

	return public
end
