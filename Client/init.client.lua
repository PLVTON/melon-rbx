--[[

	Client Packager.

	Methods:
		public.Awake
			Performs on pre-startup. Useful to load things that will be needed in Init.
		public.Init
			Performs on startup.
		public.EarlyUpdate(float deltaTime)
			Performs every render update as first. Use carefully.
		public.Update(float deltaTime)
			Performs every render update. Use carefully.
		public.LateUpdate(float deltaTime)
			Performs every render update as last. Use carefully.

	Properties:
		public.Enabled (bool)
			This will determine if the Start function will fire when playing.


	NOTE: Replicated Modules will awake and initialize before Client Modules.

--]]
local ClientModules = {}
ClientModules.Functions = {}
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
		ClientModules[module.Name] = require(module)(ClientModules, ReplicatedModules)
	end
end
-- Add the client functions
for _, func in pairs(script.Functions:GetChildren()) do
	ClientModules.Functions[func.Name] = require(func)
end

-- Run the awake code
for _, module in pairs(ReplicatedModules) do
	if module.Awake then
		module.Awake()
	end
end
-- Run the awake code
for _, module in pairs(ClientModules) do
	if module.Awake then
		module.Awake()
	end
end

-- Run the init code
for _, module in pairs(ReplicatedModules) do
	if module.Init then
		module.Init()
	end
end
for _, module in pairs(ClientModules) do
	if module.Init then
		module.Init()
	end
end

-- BindToRenderStep before anything
for name, module in pairs(ClientModules) do
	if module.EarlyUpdate then
		game:GetService("RunService"):BindToRenderStep(name .. "_EU", Enum.RenderPriority.First.Value, module.EarlyUpdate)
	end
end
-- BindToRenderStep after input
for name, module in pairs(ClientModules) do
	if module.Update then
		game:GetService("RunService"):BindToRenderStep(name .. "_U", Enum.RenderPriority.Input.Value + 1, module.Update)
	end
end
-- BindToRenderStep as last
for name, module in pairs(ClientModules) do
	if module.LateUpdate then
		game:GetService("RunService"):BindToRenderStep(name .. "_LU", Enum.RenderPriority.Last.Value, module.LateUpdate)
	end
end
