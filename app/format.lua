
--
-- Copyright © 2007 All Rights Reserved.
--

--
-- Create a '%' operator on strings for ruby- and python-like formatting
-- 

getmetatable("").__mod = function(a, b)
	if not b then
		return a
	elseif type(b) == "table" then
		return string.format(a, unpack(b))
	else
		return string.format(a, b)
	end
end


--
-- Everybody loves printf
--

function printf(fmt, ...)
	io.write(fmt % {...})
end


function fprintf(f, fmt, ...)
	f:write(fmt % {...})
end


function errorf(fmt, ...)
	error(fmt % {...} , 2)
end


function assertf(e, fmt, ...)
	if(not e) then
		log(LG_FTL, "assert", fmt % {...}, 2)
	end
end



-- vi: ft=lua ts=3 sw=3

