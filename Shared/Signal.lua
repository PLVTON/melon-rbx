return function(ReplicatedModules)
	local public = {}
	public.__index = public

	function public:New()
		local o = {}
		o.functions = {}
		setmetatable(o, self)
		return o
	end

	function public:Connect(func)
		table.insert(self.functions, func)
	end

	function public:Fire(...)
		for _, v in pairs(self.functions) do
			v(...)
		end
	end

	return public
end
