local Characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-={}|[]`~'
local CharTable = {}
for c in Characters:gmatch"." do
    table.insert(CharTable, c)
end

return function(Modules, ReplicatedModules)
    local public = {}
    local private = {}

    -- If the key shouldn't be used multiple times (for example a unique name), we will store it here
    local UsedList = {}

    function public.Get(length)
        local randomString = ''

        for i = 1, length do
            randomString = randomString .. CharTable[math.random(1, #CharTable)]
        end
    
        return randomString
    end

    function public.GetUnique(length)
        local randomString = ''
    
        repeat
            for i = 1, length do
                randomString = randomString .. CharTable[math.random(1, #CharTable)]
            end
        until not UsedList[randomString]
        UsedList[randomString] = true
    
        return randomString
    end

    return public
end