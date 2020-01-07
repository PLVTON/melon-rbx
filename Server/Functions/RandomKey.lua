local characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-={}|[]`~'
local charTable = {}
for c in characters:gmatch"." do
    table.insert(charTable, c)
end

return function(length)
	local randomString = ''
	for i = 1, length do
	    randomString = randomString .. charTable[math.random(1, #charTable)]
	end
	return randomString
end