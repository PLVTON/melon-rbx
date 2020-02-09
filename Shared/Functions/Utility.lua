return function(Modules, ReplicatedModules)
    local public = {}
    local private = {}

    function public.Weld(a, b, c0)
        local w = Instance.new("Weld")
        w.Part0 = a
        w.Part1 = b
        w.C0 = c0 or CFrame.new()
        w.C1 = CFrame.new()
        w.Parent = a
        return w
    end

    function public.PrintTable(tab)
        local s = "{====TABLE====}"
        for i, v in pairs(tab) do
            print(i, v)
        end
        local s = "{====END====}"
    end
    
    function public.NumberToString(n, cleaner)
        if type(n) ~= "number" then return "error" end
        if cleaner then
            if not n then return "" end
    
            local f,k = n
            while (true) do
                f,k = string.gsub(f,"^(-?%d+)(%d%d%d)","%1,%2")
                if (k == 0) then break end
            end
            return f
        else
            if n >= 10^15 then
                return string.format("%.1fQ", n / 10^15)
            elseif n >= 10^12 then
                return string.format("%.1fT", n / 10^12)
            elseif n >= 10^9 then
                return string.format("%.1fB", n / 10^9)
            elseif n >= 10^6 then
                return string.format("%.1fM", n / 10^6)
            elseif n >= 10^3 then
                return string.format("%.1fK", n / 10^3)
            else
                return tostring(n)
            end
        end
    end
    
    function public.GetDate()
        return {
            Month = os.date("!*t").month,
            Year = os.date("!*t").year,
            Week = math.floor(os.date("!*t").day/7),
            Day = os.date("!*t").day
        }
    end
    
    function public.CountDictionary(tab)
        local i = 0
        for _, v in pairs(tab) do
            i = i + 1
        end
        return i
    end

    return public
end