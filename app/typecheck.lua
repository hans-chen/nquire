

-- 
-- Check if the given number lies within the given range.
--

local function num_is_in_range(range, num)
	if not range then return true end
	num = tonumber(num)
	if not num then return false end
	for part in range:gmatch("([^,]+)") do
		local min,max = part:match("(.+):(.+)")
		if min and max then
			if num >= tonumber(min) and num <= tonumber(max) then
				return true
			end
		else
			if num == tonumber(part) then
				return true
			end
		end
	end
end


--
-- Validators for various types
--

local type_checker = {

	number = function(range, val)
		return num_is_in_range(range, val)
	end,

	string = function(range, val)
		local len = #val
		return num_is_in_range(range, len)
	end,

	password = function(range, val)
		local len = #val
		return true
	end,

	boolean = function(range, val)
		return val == "true" or val == "false"
	end,

	enum = function(range, val)
		for option in range:gmatch("([^,]+)") do
			if val == option then
				return true
			end
		end
		return false
	end,

	ip_address = function(range, val)
		local part = { val:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$") }
		if #part ~= 4 then return false end
		for _,p in pairs(part) do
			p = tonumber(p)
			if p < 0 or p > 255 then return false end
		end
		return true
	end,

	pattern = function(range, val)
		return val:match(range) 
	end,
}


--
-- Validate if value is valid for given type and range
--

function type_check(type, range, value)

	if type_checker[type] then
		local ok = type_checker[type](range, value)
		if ok then
			return true
		else
			logf(LG_WRN, "config", "Value %q is not a valid %s %s", tostring(value), type, range and "in range " .. range or "")
			return false
		end
	else
		logf(LG_WRN, "config", "Unknown type %s", type)
		return false
	end
end

-- vi: ft=lua ts=3 sw=3

