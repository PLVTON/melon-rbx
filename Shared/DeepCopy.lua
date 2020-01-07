return function()
	local public = {}
	local private = {}

	function public.Copy(orig)
	    local orig_type = type(orig)
	    local copy
	    if orig_type == 'table' then
	        copy = {}
	        for orig_key, orig_value in next, orig, nil do
	            copy[public.Copy(orig_key)] = public.Copy(orig_value)
	        end
	        setmetatable(copy, public.Copy(getmetatable(orig)))
	    else -- number, string, boolean, etc
	        copy = orig
	    end
	    return copy
	end

	function public.Merge(template, updated)
		for i, v in pairs(template) do
			if updated[i] then
				template[i] = updated[i]
			end
		end
		return template
	end

	return public
end