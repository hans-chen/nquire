--
-- Copyright © 2007 All Rights Reserved.
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

prefixes = {
   { name = "Code128",               prefix_2d = "j", prefix_1d = "j", prefix_out = "#"   },
   { name = "UCC/EAN-128",           prefix_2d = "J", prefix_1d = "u", prefix_out = "P", cmd = "0004030" },
   { name = "EAN-8",                 prefix_2d = "d", prefix_1d = "g", prefix_out = "FF", },
   { name = "EAN-13",                prefix_2d = "D", prefix_1d = "d", prefix_out = "F", cmd = "0004050" },
   { name = "UPC-E",                 prefix_2d = "c", prefix_1d = "h", prefix_out = "E"  },
   { name = "UPC-A",                 prefix_2d = "C", prefix_1d = "c", prefix_out = "A", cmd = "0004070" },
   { name = "Interleaved 2 of 5",    prefix_2d = "e", prefix_1d = "i", prefix_out = "i"  },
   { name = "Code39",                prefix_2d = "b", prefix_1d = "b", prefix_out = "*"  },
   { name = "Codabar",               prefix_2d = "a", prefix_1d = "a", prefix_out = "%"  },
   { name = "Code93",                prefix_2d = "i", prefix_1d = "y", prefix_out = "c"  },
   { name = "PDF417",                prefix_2d = "r", prefix_1d = "?", prefix_out = "r"  },
   { name = "QR Code",               prefix_2d = "s", prefix_1d = "?", prefix_out = "s"  },
   { name = "Aztec",                 prefix_2d = "z", prefix_1d = "?", prefix_out = "z"  },
   { name = "DataMatrix",            prefix_2d = "u", prefix_1d = "?", prefix_out = "u"  },
   { name = "Chinese-Sensible",      prefix_2d = "h", prefix_1d = "?", prefix_out = "h"  },
   { name = "GS1 Databar",           prefix_2d = "R", prefix_1d = "R", prefix_out = "R"  },
   { name = "ISBN",                  prefix_2d = "?", prefix_1d = "B", prefix_out = "B"  },
   { name = "Code 11",               prefix_2d = "?", prefix_1d = "z", prefix_out = "Z"  },
   { name = "2/5 Matrix",            prefix_2d = "?", prefix_1d = "v", prefix_out = "v"  },
   { name = "ITF14",                 prefix_2d = "?", prefix_1d = "q", prefix_out = "q"  },
   { name = "MSI Plessey",           prefix_2d = "?", prefix_1d = "m", prefix_out = "m"  },

	{ name = "Plessey",               prefix_2d = "?", prefix_1d = "p", prefix_out = "n"  },
	{ name = "2/5 Standard",          prefix_2d = "?", prefix_1d = "s", prefix_out = "o"  },

}

-- vi: ft=lua ts=3 sw=3
   
