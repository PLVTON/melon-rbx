--[[

	CreateClientRemote(tag, (optional) func):
		Creates a secured connection between the client and the server. Never trust the client still applies.

	BindClientRemote(tag, func):
		Binds a function to fire when the event is invoked.

	CreateRemote(tag):
		Creates a remote for obligatory use from server to client.

	FireRemote(tag, player, ...):
		Fires a server remote to a specific player, with additional parameters.

	FireRemoteAll(tag, ...):
		Fires a server remote to ever player, with additional parameters.

--]]

local required = false

return function(Modules, ReplicatedModules)
	local public = {}
	local private = {}
	public.Enabled = true

	local Connections = {}
	local ClientRemotes = {}
	local ServerRemotes = {}
	local PlayersRemotes = {}

	local RemoteClass = {}
	RemoteClass.__index = RemoteClass

	function RemoteClass:New(owner)
		local o = {}
		o.Owner = owner
		o.Key = Modules.Functions.RandomKey(15)
		o.Functions = {}
		o.RemoteFunction = Instance.new("RemoteFunction")
		o.RemoteFunction.Name = Modules.Functions.RandomKey(15)
		o.RemoteFunction.Parent = game.ReplicatedStorage.Remotes

		o.RemoteFunction.OnServerInvoke = function(player, key, ...)
			if player == o.Owner and o:Verify(key) then
				local ret
				for _, func in pairs(o.Functions) do
					local temp = func(player, ...)
					if temp then ret = temp end -- don't replace something with nil
				end
				return o.Key, ret
			else
				Modules.ServerSafety.WarnPlayer(player)
			end
		end

		setmetatable(o, self)
		return o
	end

	function RemoteClass:Verify(key)
		local r = self.Key == key
		self.Key = Modules.Functions.RandomKey(15)
		return r
	end

	function public.CreateClientRemote(tag, func)
		if not ClientRemotes[tag] then
			ClientRemotes[tag] = {Tag = tag, Functions = {}}
			if func then
				table.insert(ClientRemotes[tag].Functions, func)
			end
		else
			error("Remote index already in use")
		end
	end

	function public.BindClientRemote(tag, func)
		if ClientRemotes[tag] then
			table.insert(ClientRemotes[tag].Functions, func)
		else
			error("Remote cannot be bind because it doesn't exist")
		end
	end

	function public.CreateRemote(tag)
		if not ServerRemotes[tag] then
			local NewRemote = Instance.new("RemoteEvent")
			NewRemote.Name = Modules.Functions.RandomKey(15)
			NewRemote.Parent = game.ReplicatedStorage.Remotes
			NewRemote.OnServerEvent:Connect(function(player)
				player:Kick("404 not found")
			end)
			ServerRemotes[tag] = {
				RemoteEvent = NewRemote
			}
		else
			error("Remote has already been created")
		end
	end

	function public.FireRemote(tag, player, ...)
		if ServerRemotes[tag] then
			ServerRemotes[tag].RemoteEvent:FireClient(player, ...)
		else
			error("Remote can't be fired because it's index is inexistant")
		end
	end

	function public.FireRemoteAll(tag, ...)
		if ServerRemotes[tag] then
			ServerRemotes[tag].RemoteEvent:FireAllClients(...)
		else
			error("Remote can't be fired because it's index is inexistant")
		end
	end

	function public.YieldToConnection(player, timeout)
		local current = 0
		repeat wait()
			current = current + 1
		until Connections[player] or current > timeout and timeout or 600
	end

	game.ReplicatedStorage.Remotes.Connect.OnServerEvent:Connect(function(player, confirm)
		if not Connections[player] then
			if confirm then
				print("player confirmed")
				Connections[player] = true
			else
				local PlayerRemotes = {}

				for index, data in pairs(ClientRemotes) do
					PlayerRemotes[index] = RemoteClass:New(player)
					PlayerRemotes[index].Functions = data.Functions
				end

				PlayersRemotes[player] = PlayerRemotes

				game.ReplicatedStorage.Remotes.Connect:FireClient(player, PlayerRemotes, ServerRemotes)
			end
		else
			player:Kick("403 access token is not valid")
		end
	end)

	game.Players.PlayerRemoving:Connect(function(player)
		if PlayersRemotes[player] then
			for _, remote in pairs(PlayersRemotes[player]) do
				if remote.RemoteFunction then
					remote.RemoteFunction:Destroy()
				end
			end
		end
		PlayersRemotes[player] = nil
	end)

	return public
end
