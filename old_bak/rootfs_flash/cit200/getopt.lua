
--
-- Copyright © 2007 All Rights Reserved.
--


function getopt(arg, optstring)

	local opt = {}
	local i = 1 

	while arg[1] do
		local char, val = string.match(arg[1], "^-(.)(.*)") 
		if char then 
			local found, needarg = string.match(optstring, "(" ..char .. ")(:?)") 
			if not found then 
				print("Invalid option '%s'\n" % char)
				return nil
			end 
			if needarg == ":" then 
				if not val or string.len(val)==0 then 
					val = arg[2] 
				end 
				if not val then 
					print("option '%s' requires an argument\n" % char)
					return nil
				end 
			else
				val = true
			end 
			opt[char] = val
			table.remove(arg, 1)
		else
			break
		end 
	end 
	return opt, arg
end 

-- vi: ft=lua ts=3 sw=3
