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
				reference[obj.Name] = require(obj)(ClientModules, ReplicatedModules)
				table.insert(AllModules, reference[obj.Name])
			end
		else
			error("There already is an instance of " .. obj.Name)
		end
	end
end

recursiveTree(game.ReplicatedStorage.Modules:GetChildren(), ReplicatedModules)
recursiveTree(script:GetChildren(), ClientModules)

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

-- BindToRenderStep before anything
for name, module in pairs(AllModules) do
	if module.EarlyUpdate then
		game:GetService("RunService"):BindToRenderStep(name .. "_EU", Enum.RenderPriority.First.Value, module.EarlyUpdate)
	end
end
-- BindToRenderStep after input
for name, module in pairs(AllModules) do
	if module.Update then
		game:GetService("RunService"):BindToRenderStep(name .. "_U", Enum.RenderPriority.Input.Value + 1, module.Update)
	end
end
-- BindToRenderStep as last
for name, module in pairs(AllModules) do
	if module.LateUpdate then
		game:GetService("RunService"):BindToRenderStep(name .. "_LU", Enum.RenderPriority.Last.Value, module.LateUpdate)
	end
end
