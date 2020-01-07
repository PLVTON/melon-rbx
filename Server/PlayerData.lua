return function(Modules, ReplicatedModules)
	local public = {}
	public.__index = public
	public.Enabled = true

	local PlayerDataTemplate = {
		Cash = 0,
		InventoryId = 0,
		InventoryIds = {0},
		Counter = 0,
		Rank = 0,
		GamePasses = {},
		RobuxSpent = 0
	}

	function public:New(player, encodedData)
		local data = {}
		if encodedData and typeof(encodedData) == "string" then
			data = game:GetService("HttpService"):JSONDecode(encodedData)
		end

		local tempdata = ReplicatedModules.DeepCopy.Copy(PlayerDataTemplate)
		data = ReplicatedModules.DeepCopy.Merge(tempdata, data)
		data.Player = player

		setmetatable(data, self)
		return data
	end

	function public:Get(tag)
		return self[tag]
	end

	function public:AddCash(amount)
		self.Cash = self.Cash + amount
	end

	function public:CountAction()
		self.Counter = self.Counter + 1
	end

	function public:Sell()
		self:AddCash(self.Counter)
		self.Counter = 0
		return amount
	end

	function public:OwnsInventoryId(id)
		for _, v in pairs(self.InventoryIds) do
			if v == id then
				return true
			end
		end
		return false
	end
	
	function public:EquipInventoryId(id)
		if self:OwnsInventoryId(id) then
			self.InventoryId = id
			return true
		end
		return false
	end

	function public:Transaction(price, currencyType)
		assert(typeof(price) == "number", "Price must be a number")

		if currencyType == "Cash" then
			if self.Cash >= price then
				self.Cash = self.Cash - price
				return true
			end
		elseif currencyType == "Gems" then
			if self.Gems >= price then
				self.Gems = self.Gems - price
				return true
			end
		else
			error("Currency " .. currencyType .. " doesn't exist.")
		end
		return false
	end

	function public:PackNeededData(indexesWanted)
		local neededData = {}
		for _, index in pairs(indexesWanted) do
			if self[index] then
				neededData[index] = self[index]
			else
				error("Tried to pack an unexisting index")
			end
		end
		return neededData
	end

	function public:AddRobuxSpent(amount)
		self.RobuxSpent = self.RobuxSpent + amount
	end

	function public:OwnsGamePass(id)
		return self.GamePasses[tostring(id)]
	end

	function public:AddGamePass(id)
		if not self:OwnsGamePass(id) then
			self.GamePasses[tostring(id)] = true
		end
	end

	function public:RedeemCode(code)
		for _, v in pairs(self.RedeemedCodes) do
			if v == code then
				-- the code has already been used
				return false
			end
		end
		
		-- let's add the code
		table.insert(self.RedeemedCodes, code)
		return true
	end

	function public:GetSaveData()
		return game:GetService("HttpService"):JSONEncode(self)
	end

	return public
end
