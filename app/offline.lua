--
-- Copyright © 2007. All Rights Reserved.
--

-- This module does 2 things:
--  - observe availability of offline-database files (only when 'started'), 
--    and import them for replacing the current offline-database
--  - handling barcode requests and translate them into escape code responses
-- Format of offline database import file:
--  - the filename is should match offlinedb-<md5>.zip
-- This is a zip file containing two files: 
--    barcodes.csv
--    formats.csv
-- Format of barcodes.csv:
-- file ::= { comment-line <CR> }* barcodes_header <CR> { line <CR> }+
-- comment_line ::= '#' text
-- barcodes_header :: 'barcode,format' {',' <var>}*
-- line ::= <barcode match> ',' <format_id> {',' <var_value>}*
-- var_value ::= <txt not ','> | { '"' <txt not "> '"' }
--
-- Format of formats.csv:
-- file ::= {comment_line <CR> }* formats_header <CR> { line <CR> }+
-- formats_header := 'format,response'
-- line ::= <format_id> ',' { <escape code> | <var> } *
-- var ::= '${' <var_id> '}'
-- 
-- variable 'barcode' is always defined.
--
-- This module throws the following events (multiple times) sequential during
-- import of data:
-- offline
--    data.part          -- 'copying' | 'importing'
--    data.progress      -- the (estimated) progress in percentage
--    data.comment       -- user comment, eg 'do not remove the memory stick'
-- The client can use this to display progress and reset the watchdog every
-- time the data.progress is called.

module("Offline", package.seeall)

require "simpledb"

local lgid="offline"

local database_def = { barcodes={[1]="barcode",[2]="format"}, formats={[1]="format", [2]="response"}, md5sum = { raw = true } }

-- lookup a barcode in the database and return the proper response escape codes.
-- return nil in case the barcode or format is not found
local function get_barcode_response( self, barcode )
	logf(LG_DMP,lgid,"")

	local bcdt = self.db:find_record( "barcodes", barcode )

	if bcdt == nil then
		logf(LG_WRN,lgid,"No barcode definition found for '%s'", barcode)
	else

		if bcdt["format"] == nil then
			logf(LG_WRN,lgid,"Database error: No format collumn in barcode def")
			return
		end
		local format = self.db:find_record( "formats", bcdt["format"] )

		local response = format["response"]

		if response == nil then
			logf(LG_WRN,lgid,"No format definition found for barcode '%s' with format '%s'", barcode, bcdt["format"] )
		else
			-- merge format with variables
			-- when variables are not found, a zero length string is substituted
			logf(LG_DBG,lgid,"Response='%s'", response)

			local substituded_response = response:gsub("(${(..-)})",
				function(_,s)
					local substitute = bcdt[s] or "<nil>"
					logf(LG_DBG,lgid,"Substituting '%s' for '%s'", s, substitute)
					return substitute
				end)
			
			-- finally substitute escape codes for their hex-values
			return escapes_to_binstr( substituded_response )
		end
	end
end


local function calc_md5sum( fname )

	logf(LG_DBG, lgid, "Calculating md5-checksum for %s", fname)
	local real_md5sum = ""
	local fd, err = io.popen("md5sum " .. fname)
	if fd then
		local tmp = fd:read("*a")
		tmp = tmp:match("(%S+)")
		if tmp then real_md5sum = tmp end
		fd:close()
	else
		logf(LG_WRN, lgid, "Could not calculate md5 sum: %s", err)
		return ""
	end
	logf(LG_DBG, lgid, "done: %s", real_md5sum)
	
	return real_md5sum
end

-- get the md5 of the used importfile from the current database
local function get_md5( self )
	return self.db:read_table( "md5sum" )
end

local function execute_cmd( cmd, part, comment )
	-- copy the file
	local data = { part=part, progress=0, comment=comment }
	evq:push("offline", data, -1 )
	logf(LG_DBG,lgid,"%s", cmd)
	os.execute(cmd)
end

local function split_offlinedb_csv( f, dir )
	local linenr = 0
	local fout
	local has_barcodes = false
	local has_formats = false
	for l in f:lines() do
		linenr = linenr + 1
		if not fout then
			if l:match("^barcode,format") then
				logf(LG_DBG,lgid,"Starting barcodes on line %d", linenr)
				fout = io.open(dir .. "/barcodes.csv", "w")
				if not fout then
					logf(LG_WRN,"Could not open file %s/barcodes.csv", dir)
					return false
				end
				fout:write(l .. "\n")
				has_barcodes = true
			elseif l:match("^format,response") then
				logf(LG_DBG,lgid,"Starting formats on line %d", linenr)
				fout = io.open(dir .. "/formats.csv","w")
				if not fout then
					logf(LG_WRN,lgid, "Could not open file %s/formats.csv", dir)
					return false
				end
				fout:write(l .. "\n")
				has_formats = true
			elseif not l:match("^%s*#") and not l:match("^%s*$") then
				logf(LG_WRN,lgid,"Error on line %d", linenr)
				return false
			end
		elseif l:match("^%s*$") then
			logf(LG_DBG,lgid,"EOI on line %d", linenr)
			fout:close()
			fout = nil
		else
			fout:write( l .. "\n")
		end		
	end

	if fout then fout:close() end

	if has_barcodes and has_formats then
		return true
	else
		logf(LG_WRN,lgid,"No %s found", not has_barcodes and "barcodes" or "formats")
		return false
	end
end

local function open( self )
	self.db:open()
	logf(LG_INF,lgid,"Opened offline db %s (#barcodes=%d, #formats=%d)", self:get_md5() or "<nil>", self:get_number_of_barcodes() or 0, self:get_number_of_formats() or 0 )
end

local function close( self )
	logf(LG_INF,lgid,"Closed offline db %s", self:get_md5() or "<nil>" )
	self.db:close()
end

local function on_offline_timer( event, self )

	if not self.running then
		return false;
	end

	--logf(LG_DMP,lgid,"Checking for new database files...")

	if self.reloading then
		return true;
	end

	-- TODO: replace for system call (because this causes a SIGPIPE)
	local fd = io.popen( "ls -1 " .. self.db_import_fpattern .. " 2> /dev/null" )
	if not fd then
		logf(LG_WRN, lgid, "Could not read filepattern %s:", self.db_import_fpattern, err)
		return true;
	end

	-- only use the first file:
	local fname = fd:read()
	fd:close()
	if not fname then
		logf(LG_DMP, lgid, "No importfile found searching '%s'", self.db_import_fpattern)
		return true;
	end

	-- Check if this is a regular file, not a directory or symlink
	local stat = sys.lstat(fname)

	if not stat then
		logf(LG_WRN, lgid, "Could not get stat for file %s: skipping", fname)
		return true;
	end

	if not stat.isreg then
		logf(LG_WRN, lgid, "File %s is not a regular file: skipping", fname)
		return true;
	end

	logf(LG_DBG,lgid,"Found offline import file: %s", fname)

	local import_from_ftp = fname:match("^/home/ftp/") ~= nil

	local id, md5_newdb, ftype = fname:match("/offlinedb%-?([%w_]-)-?(%x*)%.(%w+)$")
	if md5_newdb==nil or ftype ~= "zip" and ftype ~= "csv" or import_from_ftp and #md5_newdb == 0 then
		logf(LG_WRN, lgid, "incorrect database import filename format \"%s\"", fname)
		if import_from_ftp then
			os.remove( fname )
		end
		return true;
	end		

	local md5_real = calc_md5sum( fname )

	-- check whether the md5sum is correct, possibly waiting for ftp upload completion
	self.md5_error_counter = self.md5_error_counter + 1
	if #md5_newdb > 0 and md5_newdb ~= md5_real then
		if import_from_ftp and md5_real ~= self.md5_error then
			-- file is updated, so just wait till it is finished
			logf(LG_DBG, lgid, "Waiting for file to be finished")
			self.md5_error = md5_real
			self.md5_error_counter=0
		elseif import_from_ftp and self.md5_error_counter>5 or not import_from_ftp then
			self.md5_error = nil
			self.md5_error_counter=0
			logf(LG_WRN, lgid, "md5sum error for %s: (calculated md5=%s)", fname, md5_real)
			if import_from_ftp then
				os.remove( fname )
			end
		end
		return true;
	end
	self.md5_error_counter = 0
	self.md5_error = nil

	-- check whther the uploaded db is the same as the current db
	local current_md5sum = self:get_md5()

	if current_md5sum == md5_real then
		logf(LG_INF,lgid,"Database file already imported")
		if import_from_ftp then
			os.remove( fname )
		end
		return true
	end

	logf(LG_INF, lgid, "Starting offline-db import from file %s", fname)
	evq:push("offline", { ready=false, md5sum=md5_real, fname=fname, progress=0 }, -1 )

	local dirs = self.db_dir_import .. " " .. self.db_dir_tmp
	execute_cmd("rm -rf " .. dirs .. "; mkdir -p " .. dirs, "Prepare import", "")

	if ftype == "zip" then
		execute_cmd("unzip -o " .. fname .. " barcodes.csv formats.csv offlinedb.csv -d " .. self.db_dir_import,
			"Import", "Extracting data from zip-file")
	elseif ftype == "csv" then
		execute_cmd("cp -a " .. fname .. " " .. self.db_dir_import .. "/offlinedb.csv","Import","Copying csv file")
	end

	if import_from_ftp then
		os.remove( fname )
	end

	evq:push("offline", { ready=false, progress=2 }, -1 )

	-- check for combination file and possibly split into two csv files:
	local offlinedb_csv = self.db_dir_import .. "/offlinedb.csv"
	local f_offlinedb_csv = io.open(offlinedb_csv, "r")
	if f_offlinedb_csv then
		logf(LG_INF,lgid,"Splitting offlinedb.csv file into barcodes.csv and formats.csv")
		local r = split_offlinedb_csv( f_offlinedb_csv, self.db_dir_import )
		f_offlinedb_csv:close()
		os.remove( offlinedb_csv )
		if r == false then
			local ret = { ready = true, md5sum=md5_real, error="offline.csv conversion error" }
			-- TODO: remove code duplication
			if config:get("/cit/offlinedb/failure") == "continue" then
				ret.error = "csv-file import error: continueing with offline db %s" % {self:get_md5() or "<nil>"}
				logf(LG_WRN,lgid, ret.error or "")
			else
				-- "remove"	
				close(self)
				os.execute( "rm -rf " .. self.db_dir_old )
				if not os.rename( self.db_dir, self.db_dir_old ) then
					ret.error="offlinedb.csv conversion error"
					logf(LG_WRN,lgid,"Failed to remove the old database")
				else
					ret.error="offlinedb.csv conversion error (current database removed)"
					-- and create a new db:
					self.db = Simpledb.new( self.db_dir, database_def )
					open(self)
				end
				logf(LG_WRN,lgid,ret.error )
			end
			evq:push("offline", ret, -1 )
			return true
		else	
			logf(LG_DBG,lgid,"Success splitting offlinedb.csv into barcodes and formats")
		end
	end

	self.db_tmp = Simpledb.new( self.db_dir_tmp, database_def )

	self.db_tmp:write_table("md5sum", md5_real)

	self.reloading = md5_real
	self.db_tmp:import( self.db_dir_import,
		function (self, part)
			if part.ready then
				local ret = { ready = true, md5sum=self.reloading }
				if part.error then
					-- bad
					ret.error = "indexing error, clearing db"

					-- TODO: remove code duplication
					if config:get("/cit/offlinedb/failure") == "continue" then
						logf(LG_WRN,lgid,"csv-file import error: continuing with offline db %s", self:get_md5() or "<nil>" )
					else
						-- "remove"
						logf(LG_WRN,lgid,"csv-file import error: clearing offline db content" )
						close(self)
						os.execute( "rm -rf " .. self.db_dir_old )
						os.rename( self.db_dir, self.db_dir_old )
						-- and create a new db
						self.db = Simpledb.new( self.db_dir, database_def )
						open(self)
					end
				else
					-- good
					evq:push("offline", { ready=false, progress=100 }, -1 )
					close(self)
					os.execute( "rm -rf " .. self.db_dir_old )
					os.rename( self.db_dir, self.db_dir_old )
					if os.rename( self.db_dir_tmp, self.db_dir )==nil then
						-- and ugly
						logf(LG_WRN,lgid,"Failed to activate the new database" )
						ret.error ="failed activating new database (current database removed)"
					else
						logf(LG_INF,lgid,"csv-file import success")
						open(self)
					end
				end
				self.reloading = nil
				evq:push("offline", ret, -1 )
				self.db_tmp = nil
			elseif part.progress then
				part.progress=part.progress+4
				if part.progress > 99 then
					part.progress = 99
				end
				evq:push("offline", part, -1 )
			end
		end, self )

	-- rescedule the event:
	return true

end

local function start( self )
	if not self.running then
		open(self)
		evq:register("offline_timer", on_offline_timer, self)
		evq:push("offline_timer", self, 3)
		self.running=true
	end
end


local function stop( self )
	if self.running then
		self.running=false
		evq:unregister("offline_timer", on_offline_timer, self)
		close(self)
	end
end


--
-- Create Offline service
--

function new( db_import_dirs, db_dir_base )
	
	logf(LG_DBG,lgid,"new()")

	os.execute( "mkdir -p " .. db_dir_base )

	local db_dir = db_dir_base .. "/db"

	local obj = {
		db_import_fpattern = "/udisk/offlinedb.zip /udisk/offlinedb-*.zip /home/ftp/offlinedb-*.zip /udisk/offlinedb.csv /udisk/offlinedb-*.csv /home/ftp/offlinedb-*.csv",
		db_dir_base = db_dir_base,
		db_dir = db_dir,
		db_dir_old = db_dir_base .. "/db.old",
		db_dir_import = db_dir_base .. "/import",
		db_dir_tmp = db_dir_base .. "/db.tmp",
		running = false,
		reloading = nil, -- md5 of the database that is currently beeing imported, or nil
		md5_error_counter = 0, -- for removing stale (bad) files

		db = Simpledb.new( db_dir, database_def ),

	-- public:
		start = start,
		stop = stop,
		get_barcode_response = get_barcode_response,
		get_md5 = get_md5,
		get_number_of_barcodes = function ( self ) return self.db:get_number_of_records("barcodes") end,
		get_number_of_formats = function ( self ) return self.db:get_number_of_records("formats") end,
		get_reloading_md5 = function ( self ) return self.reloading end
	}

	if obj.db==nil then
		return nil
	else
		return obj
	end
end
