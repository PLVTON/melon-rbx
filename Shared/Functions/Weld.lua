return function(a, b, c0)
	local w = Instance.new("Weld")
	w.Part0 = a
	w.Part1 = b
	w.C0 = c0 or CFrame.new()
	w.C1 = CFrame.new()
	w.Parent = a
	return w
end
