return function(Modules, ReplicatedModules)
	local class = {}
	class.__index = class

	function class:New(n, k, d)
		local o = {}
		o.n = n or 0
		o.v = n or 0
		o.t = n or 0
		o.k = k or 0.1
		o.d = d or 0.1

		setmetatable(o, self)
		return o
	end

	function class:Impulse(intensity)
		if typeof(self.n) == "Vector3" then
			self.v = self.v + Vector3.new(math.random()-0.5, math.random()-0.5, 0).unit * intensity
		elseif typeof(self.n) == "number" then
			self.v = self.v + math.random() * intensity
		end
	end

	function class:Calculate()
		local x = self.t - self.n
		local f = x * self.k
		self.v = (self.v * (1 - self.d)) + f
		self.n = self.n + self.v
	end

	function class:Get()
		return self.n
	end

	return class
end