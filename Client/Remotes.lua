--[[

	Bind(tag, func):
		Binds a function to fire when the event is fired.

	Fire(tag, ...):
		Fires the according event to the server. Won't fire if already fired.

	FireQueued(tag, ...):
		Fires the according event to the server. Will not return but will queue in order to send all data. Mostly used as a remote

--]]

local required = false

return function(Modules, ReplicatedModules)
	if not required then
		required = true
		local public = {}
		local private = {}

		-- Will throttle firing the same Remote twice while it's busy
		local FireRequests = {}
		local FireQueue = {}
		local BusyQueuing = false

		function public.Awake()
			game.ReplicatedStorage.Remotes.Connect:FireServer()
			private.Index, private.Server = game.ReplicatedStorage.Remotes.Connect.OnClientEvent:Wait()
		end

		function public.Start()
			game.ReplicatedStorage.Remotes.Connect:FireServer(true)
		end

		function public.Bind(tag, func)
			if private.Server[tag] then
				private.Server[tag].RemoteEvent.OnClientEvent:Connect(func)
			end
		end

		function public.Fire(tag, ...)
			local extraData
			if private.Index[tag] and not FireRequests[tag] then
				FireRequests[tag] = true
				private.Index[tag].Key, extraData = private.Index[tag].RemoteFunction:InvokeServer(private.Index[tag].Key, ...)
				FireRequests[tag] = false
			end
			return extraData
		end

		function public.FireQueued(tag, ...)
			if not FireQueue[tag] then FireQueue[tag] = {} end
			table.insert(FireQueue[tag], {...})

			if not BusyQueuing then
				spawn(function()
					BusyQueuing = true
					while #(FireQueue[tag]) > 0 do
						if private.Index[tag] then
							private.Index[tag].Key = private.Index[tag].RemoteFunction:InvokeServer(private.Index[tag].Key, unpack(FireQueue[tag][1]))
							table.remove(FireQueue[tag], 1)
						end
					end
					BusyQueuing = false
				end)
			end
		end

		return public
	else
		while true do
			-- im sorry
		end
	end
end