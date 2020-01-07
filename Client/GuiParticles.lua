--[[
	Rewritten by Plutonem

	GuiParticles
	Used to mass handle ImageLabels to work as particles for the graphic screen.
	By Plutonem and ChemicalHex


	If you want to use some pre-written samples with parameters to simplify your task:

	ParticleService.CreateBurst(50, -- amount
		image, --baseObject
		nil, -- parentObject
		30, -- lifespan
		Vector2.new(0, 0), -- initVelocity
		10, -- circular velocity,
		0.5, -- randomness
		0, -- rotVelocity
		Vector2.new(0, 0), -- acceleration
		0, -- rotAcceleration
		0.1, -- drag
		0, -- rotDrag
		UDim2.new(0, 10, 0, 10), -- endSize
		1 -- endTransparency
	)

--]]
return function(Modules, ReplicatedModules)
	local public = {}
	local Particle = Modules.ParticleClass -- Particle object

	local Particle = {}
	Particle.__index = Particle

	local MovementType = {None = "None", TweenToMouse = "TweenToMouse"}

	local Mouse = game.Players.LocalPlayer:GetMouse()
	local udim2, vector2 = UDim2.new, Vector2.new

	local function lerp(a, b, t)
		return a * (1-t) + (b*t)
	end

	function Particle:New(baseObject, parentObject, lifespan, initVelocity, rotVelocity, acceleration, rotAcceleration, drag, rotDrag, endSize, endTransparency)
		local o = {}
		o.Object = baseObject -- Particle object
		o.Lifespan = lifespan or 500 -- keep track of when's the object been created
		o.FramesLeft = lifespan or 500 -- how many frames until death
		o.Velocity = initVelocity or vector2(0, 0, 0, 0) -- velocity of the particle
		o.RotVelocity = rotVelocity or 0 -- rotational velocity of the particle
		o.Acceleration = acceleration or vector2(0, 0, 0, 0) -- acceleration of the particle
		o.RotAcceleration = rotAcceleration or 0 -- rotational acceleration of the particle
		o.Drag = drag or 0 -- 0-1 value to slow down velocity. 1 is no drag
		o.RotDrag = rotDrag or 0 -- 0-1 value to slow down rotational velocity. 1 is no rotational drag
		o.StartSize = baseObject.Size -- original size reference
		o.EndSize = endSize or baseObject.Size -- end size to interpolate to there
		o.StartTransparency = baseObject:IsA("ImageLabel") and baseObject.ImageTransparency or baseObject.TextTransparency -- original transparency reference
		o.EndTransparency = endTransparency or baseObject.ImageTransparency -- end transparency to interpolate to there
		o.TweenInfo = nil -- tweening information for the MovementType.TweenToMouse

		o.Object.Parent = parentObject
		setmetatable(o, self)
		return o
	end

	function Particle:Update()
		-- Useful values
		local alpha = (self.Lifespan - self.FramesLeft) / self.Lifespan
		local endPosition = vector2(self.Object.Position.X.Offset, self.Object.Position.Y.Offset) + self.Velocity

		-- Updating the object
		self.Object.Position = udim2(self.Object.Position.X.Scale, endPosition.X, self.Object.Position.Y.Scale, endPosition.Y)
		self.Object.Rotation = self.Object.Rotation + self.RotVelocity
		self.Object.Size = self.StartSize:Lerp(self.EndSize, alpha)
		if self.Object:IsA("ImageLabel") then
			self.Object.ImageTransparency = lerp(self.StartTransparency, self.EndTransparency, alpha)
		elseif self.Object:IsA("TextLabel") then
			self.Object.TextTransparency = lerp(self.StartTransparency, self.EndTransparency, alpha)
		end

		-- Updating the maths
		self.Velocity = (self.Velocity + self.Acceleration) * (1 - self.Drag)
		self.RotVelocity = (self.RotVelocity + self.RotAcceleration) * (1 - self.RotDrag)

		-- Update lifetime
		self.FramesLeft = self.FramesLeft - 1
		if self.FramesLeft <= 0 then
			self.Object:Destroy()
			return true -- is ready to be deleted
		end

		return false -- can't be deleted
	end

	---You can disable creating a new Gui or just set the default holder value to a preexisting one if you don't like this.
	local holder = Instance.new("ScreenGui",game.Players.LocalPlayer:WaitForChild("PlayerGui"))
	holder.Name = "ParticleInterface"
	holder.ResetOnSpawn = false
	holder.DisplayOrder = 100

	local particleCap = 300 -- Very high values may cause the system to function improperly. 200 is very safe though
	local throttled = false -- Throttle will prevent creation of new particle if the cap is over the limit

	public.particleList = {}
	setmetatable(public.particleList, {__mode = 'k'}) -- particles that are nil will automatically be removed by the garbage collector

	local mouse = game.Players.LocalPlayer:GetMouse()

	-- CREATE SINGLE PARTICLES
	function public.CreateParticle(baseObject, parentObject, lifespan, initVelocity, rotVelocity, acceleration, rotAcceleration, drag, rotDrag, endSize, endTransparency)
		-- Return already if it's not capable of handling another particle
		if #public.particleList > particleCap and throttled then warn("Particle count is over the cap; it's been throttled") return end

		-- Creates the particle
		local p = Particle:New(baseObject, parentObject or holder, lifespan, initVelocity, rotVelocity, acceleration, rotAcceleration, drag, rotDrag, endSize, endTransparency)
		table.insert(public.particleList, p)

		-- Warn if the particle count is over the cap but it's not throttled
			-- For performance, feel free to comment this line
		if #public.particleList > particleCap then warn("Particle count is over the cap") end
	end

	-- CREATE PARTICLE BURSTS
		-- Note:
		-- circularVelocity to define the roundish velocity,
		-- randomness (0-1) will determine the scale of the random velocity in every particle
	function public.CreateBurst(amount, baseObject, parentObject, lifespan, initVelocity, circularVelocity, randomness, rotVelocity, acceleration, rotAcceleration, drag, rotDrag, endSize, endTransparency)
		for i=0, amount do
			public.CreateParticle(baseObject:Clone(), parentObject or holder, lifespan, initVelocity + (1 - math.random() * randomness) * circularVelocity * Vector2.new(math.random(-100, 100), math.random(-100, 100)).unit, rotVelocity, acceleration, rotAcceleration, drag, rotDrag, endSize, endTransparency)
		end
	end

	-- PARTICLE THROTTLING
		-- Enable or disable the particle creation throttling
		-- Setting it on will prevent particles from being created if it goes over the set cap
	function public.SetThrottling(value)
		if typeof(value) == "boolean" then
			throttled = value
		else
			warn("Tried to set particle throttling by something else than a boolean")
		end
	end

	function public.Update()
		for i, p in pairs(public.particleList) do
			-- If the particle returns true, it means it's ready to be deleted
			if p:Update() then
				-- Set the particle to nil. Garbage collector will take care of the rest.
				public.particleList[i] = nil
			end
		end
	end

	return public
end