--
-- Copyright � 2007 All Rights Reserved.
--
--
-- The barcode which gets sent to the server needs to have a prefix character
-- compatible with the original product we're mimicing. We can not program the
-- required prefixes into the scanner module, because of the limitation which
-- is in the scanner: each prefix should be in the set [a-zAZ]. For some
-- barcodes we need other prefixes however (%, *, FF), which can not be
-- programmed. Another problem is that the default prefixes as defined in the
-- scanner do not differentiate between each barcode type, for example CODE128
-- and EAN128 have the same prefix, as do EAN8 and EAN13 and UPC-E and UPC-A.
--
-- As a workaround:
--
-- * The non-unique barcodes are assigned an unique id (uppercase of the original)
--
-- * this prefix is replaced by the definitive prefix in the barcode before it
-- is sent to the server (prefix_out)
--
-- If an entry has a 'cmd' field this is used to program the given prefix into
-- the internal scanner. Fields without 'cmd' do not need to be (re)programmed
--
-- id's are the names used in the database for enabling or disabling the code
-- when no id is specified the name is used for database identification

local lgid = "scanner"

-- Note that the default prefixed for:
-- prefix_hid id's are the HR100 factory defaults (hr100 user manual 'Code ID List', 
-- page 122), extended with some 2d codes. This means that a HR200 should have 
-- extensive configuration (easy using 1 big barcode).
prefixes = {
   { name = "Code128",            prefix_2d = "j", prefix_1d = "j", prefix_hid = "j", prefix_out = "#"  },
   { name = "UCC_EAN-128",        prefix_2d = "J", prefix_1d = "u", prefix_hid = "u", prefix_out = "P", cmd_HR200 = "0004030" },
   { name = "EAN-8",              prefix_2d = "d", prefix_1d = "g", prefix_hid = "g", prefix_out = "FF" },
   { name = "EAN-13",             prefix_2d = "D", prefix_1d = "d", prefix_hid = "d", prefix_out = "F", cmd_HR200 = "0004050" },
   { name = "UPC-E",              prefix_2d = "c", prefix_1d = "h", prefix_hid = "h", prefix_out = "E"  },
   { name = "UPC-A",              prefix_2d = "C", prefix_1d = "c", prefix_hid = "c", prefix_out = "A", cmd_HR200 = "0004070" },
   { name = "Interleaved-2_of_5", prefix_2d = "E", prefix_1d = "e", prefix_hid = "e", prefix_out = "i", cmd_HR200 = "0004080" },
   { name = "Code39",             prefix_2d = "b", prefix_1d = "b", prefix_hid = "b", prefix_out = "*"  },
   { name = "Codabar",            prefix_2d = "a", prefix_1d = "a", prefix_hid = "a", prefix_out = "%"  },
   { name = "Code93",             prefix_2d = "i", prefix_1d = "y", prefix_hid = "y", prefix_out = "c"  },
   { name = "PDF417",             prefix_2d = "r", prefix_1d = "?", prefix_hid = "r", prefix_out = "r", layout="2D" },
   { name = "QR_Code",            prefix_2d = "s", prefix_1d = "?", prefix_hid = "S", prefix_out = "s", layout="2D" },
   { name = "Aztec",              prefix_2d = "z", prefix_1d = "?", prefix_hid = "Z", prefix_out = "z", layout="2D" },
   { name = "DataMatrix",         prefix_2d = "u", prefix_1d = "?", prefix_hid = "U", prefix_out = "u", layout="2D" },
   { name = "Chinese-Sensible",   prefix_2d = "h", prefix_1d = "?", prefix_hid = "H", prefix_out = "h", layout="2D" },
   { name = "GS1_Databar",        prefix_2d = "R", prefix_1d = "R", prefix_hid = "R", prefix_out = "R"  },
   { name = "ISBN",               prefix_2d = "B", prefix_1d = "B", prefix_hid = "B", prefix_out = "B"  },
   { name = "Code-11",            prefix_2d = "H", prefix_1d = "z", prefix_hid = "z", prefix_out = "Z"  },
   { name = "2_5-Matrix",         prefix_2d = "v", prefix_1d = "v", prefix_hid = "v", prefix_out = "v"  },
   { name = "ITF14",              prefix_2d = "e", prefix_1d = "q", prefix_hid = "q", prefix_out = "q"  },
   { name = "MSI-Plessey",        prefix_2d = "m", prefix_1d = "m", prefix_hid = "m", prefix_out = "m"  },
   { name = "Plessey",            prefix_2d = "n", prefix_1d = "p", prefix_hid = "p", prefix_out = "n"  },
   { name = "2_5-Standard",       prefix_2d = "f", prefix_1d = "s", prefix_hid = "s", prefix_out = "o"  },
   { name = "2_5-Industrial",     prefix_2d = "I", prefix_1d = "i", prefix_hid = "i", prefix_out = "o"  },

   -- event prefixes (prefix_out) that are also reserved
   --{ name = "USB",                when "/dev/extscanner/raw = true", usb event are send prefixed with this charracter
   --{ name = "mifare",             prefix_out = "MF" },
   --{ name = "timeout",            prefix_out = "T" }, -- in response to \e\fb.....\x03
   --{ name = "touch16",            prefix_out = config:get("/dev/touch16/prefix") }, -- default = "K"
   --{ name = "gpio",               prefix_out = config:get("/dev/gpio/prefix") }, -- default = "I"
   --{ name = "warning",            prefix_out = "W" }, -- some kind of warning about the state of the nquire (eg fs low)
   --{ name = "status",             prefix_out = "NS" }, -- the (volatile status of the nquire)
   --{ name = "info",               prefix_out = "NI" }, -- (discovery) info as a message (reply in escape cmd \x1b\xfc
   --{ name = "offlinedb",          prefix_out = "ND" }, -- database event
}

-- codes to turn on and off scanner codes
-- turning off a code improves performance.
-- only the supported codes are in the list

-- HR100 scanner codes
enable_disable_HR100 = {
   { name = "Code128",            default="on" }, -- Code128 should never be disabled
   { name = "UCC_EAN-128",        default="on", off="99910101" },
   { name = "EAN-8",              default="on", off="99910401" },
   { name = "EAN-13",             default="on", off="99910501" },
   { name = "UPC-E",              default="on", off="99911001" },
   { name = "UPC-A",              default="on", off="99911101" },
   { name = "Interleaved-2_of_5", default="on", off="99911201", on="99911202" },
   { name = "2_5-Matrix",         default="on", off="99912001", on="99912002" },
   { name = "Code39",             default="on", off="99912401" },
   { name = "Codabar",            default="on", off="99912501" },
   { name = "Code93",             default="on", off="99912601" },
   { name = "ISBN",               default="off", on="99910702" },
   { name = "Code-11",            default="on", off="99912701", on="99912702" },
   { name = "ITF14",              default="off", off="99911401", on="99911403" },
   { name = "MSI-Plessey",        default="on", off="99913101", on="99913102" },
   { name = "Plessey",            default="on", off="99913001", on="99913002" },
   { name = "2_5-Standard",       default="on", off="99912201", on="99912202" },
   { name = "2_5-Industrial",     default="on", off="99912101", on="99912102" },
}

-- HR 200 scanner codes:
enable_disable_HR200 = {
   { name = "Code128",            default="on" }, -- Code128 should never be disabled
   { name = "UCC_EAN-128",        default="on",  off="0412010" },
   { name = "EAN-8",              default="on",  off="0401010" },
   { name = "EAN-13",             default="on",  off="0402010" },
   { name = "UPC-E",              default="on",  off="0403010" },
   { name = "UPC-A",              default="on",  off="0404010" },
   { name = "Interleaved-2_of_5", default="on",  off="0405010" },
   { name = "ITF14",              default="off", on ="0405090" },
   { name = "Code39",             default="on",  off="0408010" },
   { name = "Codabar",            default="on",  off="0409010" },
   { name = "Code93",             default="off", off="0410010", on="0410020" },
   { name = "PDF417",             default="on",  off="0501010" },
   { name = "QR_Code",            default="on",  off="0502010", on="0502020" },
   { name = "Aztec",              default="on",  off="0503010" },
   { name = "DataMatrix",         default="on",  off="0504010", on="0504020" },
   { name = "Chinese-Sensible",   default="on",  off="0508010" },
   { name = "GS1_Databar",        default="on",  off="0413010", on="0413020", firmware_min="3.06.004" },
   { name = "Code-11",            default="on",  off="0415010", on="0415020", firmware_min="3.06.004" },
}

function find_by_name( table, name )
	for _,rec in ipairs( table ) do
		if rec.name==name then
			return rec
		end
	end
	return nil
end

-- Return true when the layout of a code is 2d
function is_2d_code(name)
	for _,record in ipairs(prefixes) do
		if record.name == name then
			return record.layout and record.layout=="2D"
		end
	end
	return false;
end

--
-- find the prefix definition for code type "name"
-- return: prefix_def
--         nil when not found
function find_prefix_def( name )
	return find_by_name( prefixes, name )
end

-- @param: code - record in enable_disable_HR200 or enable_disable_HR100
function does_firmware_support( code )
	if code.firmware_min then
		local major_req, minor_req, nn_req = string.match( code.firmware_min, "(%d+).(%d+).(%d+)" )
		if major_req and minor_req and nn_req then
			local major, minor, nn = string.match( config:get("/dev/scanner/version"), "fw:(%d+).(%d+).(%d+)" )
			if major and minor and nn then
				if		major<major_req or 
						major==major_req and minor<minor_req or
						major==major_req and minor==minor_req and nn<nn_req then
					return false
				end
			end
		end
	end
	return true
end


-- vi: ft=lua ts=3 sw=3

