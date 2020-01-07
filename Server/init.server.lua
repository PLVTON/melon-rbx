--[[

	Server Packager.

	public.Awake
		Performs on pre-startup. Useful to load things that will be needed in Init.
	public.Init
		Performs on startup.

	Note: Replicated Modules will awake and initialize before Server Modules.

--]]

local ServerModules = {}
ServerModules.Functions = {}
local ReplicatedModules = {}
ReplicatedModules.Functions = {}

math.randomseed(tick())

-- Adding all replicated modules
for _, module in pairs(game.ReplicatedStorage.Modules:GetChildren()) do
	if module:IsA("ModuleScript") then
		ReplicatedModules[module.Name] = require(module)(ReplicatedModules)
	end
end
-- Add the replicated functions
for _, func in pairs(game.ReplicatedStorage.Modules.Functions:GetChildren()) do
	ReplicatedModules.Functions[func.Name] = require(func)
end

-- Adding all public tables into the AllModules table
for _, module in pairs(script:GetChildren()) do
	if module:IsA("ModuleScript") then
		ServerModules[module.Name] = require(module)(ServerModules, ReplicatedModules)
	end
end
-- Add the server functions
for _, func in pairs(script.Functions:GetChildren()) do
	ServerModules.Functions[func.Name] = require(func)
end

-- Run the awake code
for _, module in pairs(ReplicatedModules) do
	if module.Awake then
		module.Awake()
	end
end
-- Run the awake code
for _, module in pairs(ServerModules) do
	if module.Awake then
		module.Awake()
	end
end
-- Run the init code
for _, module in pairs(ReplicatedModules) do
	if module.Init and module.Enabled then
		module.Init()
	end
end
for _, module in pairs(ServerModules) do
	if module.Init and module.Enabled then
		module.Init()
	end
end
