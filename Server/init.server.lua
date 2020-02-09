--[[

	Server Packager.

	public.Awake
		Performs on pre-startup. Useful to load things that will be needed in Init.
	public.Init
		Performs on startup.

	Note: Replicated Modules will awake and initialize before Server Modules.

--]]

local ServerModules = {}
local ReplicatedModules = {}

local AllModules = {}

math.randomseed(tick())

local function recursiveTree(instance, reference)
	for _, obj in pairs(instance) do
		if not reference[obj.Name] then
			if obj:IsA("Folder") then
				reference[obj.Name] = {}
				recursiveTree(obj:GetChildren(), reference[obj.Name])
			elseif obj:IsA("ModuleScript") then
				reference[obj.Name] = require(obj)(ServerModules, ReplicatedModules)
				table.insert(AllModules, reference[obj.Name])
			end
		else
			error("There already is an instance of " .. obj.Name)
		end
	end
end

recursiveTree(game.ReplicatedStorage.Modules:GetChildren(), ReplicatedModules)
recursiveTree(script:GetChildren(), ServerModules)

-- Run the awake code
for _, module in pairs(AllModules) do
	if module.Awake then
		module.Awake()
	end
end
-- Run the init code
for _, module in pairs(AllModules) do
	if module.Init and module.Enabled then
		module.Init()
	end
end
