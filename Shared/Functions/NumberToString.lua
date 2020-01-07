--[[return function(n)
	if not n then return "" end

	local f,k = n
	while (true) do
		f,k = string.gsub(f,"^(-?%d+)(%d%d%d)","%1,%2")
		if (k == 0) then break end
	end
	return f
end]]

return function(n, cleaner)
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
