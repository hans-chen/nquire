--
-- Copyright © 2007. All Rights Reserved.
--

-- With this module it is possible to get records from indexed dat files. The dat
-- files are formatted as simple csv files with a header.
-- It is also possible to initiate an import of csv files from a zip file (this
-- is done using background processing). These csv files can have a more 
-- flexible format than the dat files.
-- A successfull import will replace the current database, otherwise the current
-- database remains.
-- The implementation is made as simple as possible and optimized for 
-- speed of csv-import

-- Format of database import file:
--  - this is a zip file containing csv files with the names of the tables.
--  - when the csv files are not ordered, import will take longer and there will
--    be a maximum on the number of records.
-- Format csv files:
-- file ::= { comment-line <CR> }* header-line <CR> { line <CR> }+
-- comment_line ::= '#' text
-- header_line :: <collumnname> {',' <collumnname>}*
-- line ::= <value> {',' <value>}*
-- var_value ::= <txt not ','> | { '"' <txt not "> '"' }
--

module("Simpledb", package.seeall)

local lgid="simpledb"

local function get_table_size( fd_idx )
	return fd_idx:seek("end")/9
end

-- get a record from the dat file using an index (not the position!) in the idx file
-- return record[i]   (as string)
local function get_record( fd_idx, fd_dat, i )
	i=i-(i%1)
	local pos_req = 9 * i
	--logf(LG_DMP,lgid,"Getting data from index #%d (pos=%d)", i, pos_req)
	local err 
	local idx_pos
	idx_pos, err = fd_idx:seek("set",pos_req)
	if idx_pos == nil then
		logf(LG_WRN,lgid,"Could not position in index file for barcode #%d: %s", i, err)
		return nil
	end
	local dat_pos_read = fd_idx:read(8)
	if dat_pos_read == nil then
		logf(LG_WRN,lgid,"Could not read index at #%d", i)
		return nil
	end
	local dat_pos = tonumber( dat_pos_read, 16 )
	if dat_pos == nil then
		logf(LG_WRN,lgid,"Index '%s' at #%d is not a number", dat_pos, i )
		return nil
	end

	local dat_seek_result
	dat_seek_result, err = fd_dat:seek( "set", dat_pos )
	if dat_seek_result == nil then
		logf(LG_WRN,lgid,"Could not seek for #%d at %d: %s", i, dat_pos, err)
		return nil
	end
	
	local dat = fd_dat:read()
	if dat == nil then
		logf(LG_WRN,lgid,"Could not read barcode definition on position %d",dat_idx)
		return nil
	end

	logf(LG_DMP,lgid,"[%d]=%s",i,dat)

	return dat
end


-- lookup record by key (using idx and dat file)
-- return: 
--    index,         - watch out: index can also be last+1
--    data_key,      - key-collumn-value (=the first collumn)
--    record         - just the data as a string with comma seperated fields (including the key collumn)
local function find_first( fd_idx, fd_dat, first, last, key )
	
	local idx = (first+last)/2
	idx = idx - idx%1
	local record = get_record( fd_idx, fd_dat, idx )
	if record ~= nil then
		local record_key = record:match("^([^,]+)")
		if record_key ~= nil then
			if record_key == key or first == last then
				return idx, record_key, record
			elseif key > record_key then
				--logf(LG_DMP,lgid,"right: %d .. %d", idx+1, last )
				return find_first( fd_idx, fd_dat, idx+1,last, key )
			else
				--logf(LG_DMP,lgid,"left: %d .. %d", first, idx-1 )
				return find_first( fd_idx, fd_dat, first, idx, key )
			end
		end
	end

	return nil
end

-- lookup a record in a file
-- return nil|an array of variable values indexed by the variable id
local function find_record( self, tbl, key )

	local retval

	if self.tables[tbl] == nil then
		logf(LG_WRN,lgid,"Database error: No table '%s' defined", tbl)
		return
	end 

	-- open idx and dat files
	local fpath_idx = self.db_dir .. "/" .. tbl .. ".idx"
	local fd_idx = io.open(fpath_idx, "r")
	if fd_idx == nil then
		logf(LG_WRN, lgid,"Internal database error: could not open %s", fpath_idx)
	else		
		local fpath_dat = self.db_dir .. "/" .. tbl .. ".dat"
		local fd_dat = io.open(fpath_dat, "r")
		if fd_dat == nil then
			logf(LG_WRN, lgid,"Internal database error: could not open %s", fpath_dat)
		else

			local idx, data_key, data = find_first( fd_idx, fd_dat, 0, get_table_size( fd_idx ), key )
			if data_key ~= key then
				logf(LG_DBG, lgid,"'%s' not not found in %s", key, tbl)
			else
				logf(LG_DBG,lgid,"%s[%s]='%s'", tbl, key, data )

				-- then split data into parts
				-- TODO: index by var_id
				retval = {}
				local i = 1
				-- TODO: is this correct?
				data:gsub("([^,]+),-", 
					function(c) 
						retval[self.tables[tbl].collumns[i]]=c
						i=i+1
					end)

				-- DEBUG:
				for var,value in pairs(retval) do 
					logf(LG_DBG,lgid,"[%s]='%s'", var, value)
				end
			end
			fd_dat:close()
		end
		fd_idx:close()
	end
	return retval
end

local function execute_cmd( cmd, msg, callback, userdata )
	if callback then
		callback( userdata, msg )
	end
	logf(LG_DBG,lgid,"%s", cmd)
	os.execute(cmd)
end

-- create database and index files importinf from csv files
-- the callback is called to inform the client of progress:
-- callback( userdata, { ready=nil|true, error=nil|"txt..." } )
function import( self, import_dir, callback, userdata )

	if self.reloading then
		logf(LG_WRN, lgid, "Cannot import %s: already busy importing db")
		callback( userdata, { ready=true, error="busy" } )
		return
	end

	self.reloading = true
	
	logf(LG_DBG,lgid,"Start indexing simpledb csv files")
	data = {}
	callback( userdata, { part="indexing", progress=0 } )

	local csv_files=""
	for tbl_name,tbl in pairs(self.tables) do
		if tbl.raw ~= true then
			csv_files = csv_files .. " " .. import_dir .. "/" .. tbl_name .. ".csv"
		end
	end

	-- background indexing and sorting...
	runbg("nice -n 10 /cit200/offline_import_csv " .. self.db_dir .. csv_files,
		function (rv, ol)
			local ret
			if rv == 0 then
				-- good
				logf(LG_DBG,lgid,"csv-file(s) import success")
				ret = { ready=true }
			else
				-- bad
				logf(LG_WRN,lgid,"csv-file import error")
				ret = { ready=true, error="indexing error" }
			end
			if ol.callback then
				ol.callback( ol.userdata, ret )
			end
			ol.self.reloading = false
		end,
		function (data, ol)
			if data:sub(1,1) == "#" then
				local tag,n = data:match("^#(.+)%=(%d+)")
				if tag == "records" then
					ol.self.indexing_number_of_records = tonumber(n)
					logf(LG_DBG,lgid,"Total nr of records = %d", ol.self.indexing_number_of_records)
				elseif tag == "compared" and ol.self.indexing_number_of_records then
					local total = ol.self.indexing_number_of_records
					local progress = 100*n/(total * math.log(total)/math.log(2))
					logf(LG_DMP,lgid,"Progress = %d %%", progress)
					ol.callback( ol.userdata, { part="indexing", progress=progress } )
				end
			end
		end,
		{self=self,callback=callback,userdata=userdata} )

	-- rescedule the event:
	return true

end

-- read the first line of a file, expecting a comma separated list of field-names
-- return: { [1]="<collumn 1 name>", [2]="<collumn 2 name>", ... }
local function reload_collumnids( fname )
	local collumns
 
	-- the import has stripped all comment so the header line 
	-- with varids is garanteed the be the first line:
	local fd, err = io.open(fname, "r")
	if fd then
		local line = fd:read( "*line" )
		fd:close()

		if line then
			-- the collumn identifiers
			collumns = {}
			line:gsub("([^,]+),-", function(c) 
					table.insert(collumns, c) 
				end)

			-- DEBUG
			for i=1,table.getn(collumns) do 
				logf(LG_DBG,lgid,"table[%s].collumn[%d]=%s", fname, i, collumns[i])
			end
		end
	else
		logf(LG_WRN,lgid,"Could not open %s for reading collumn id's", fname)
		return nil
	end

	return collumns
end


local function open(self)
	if self.opened then
		logf(LG_DBG,lgid,"Database already opened")
		return
	end

	-- innitialize the collumns in self.tables
	for table_name,tbl in pairs(self.tables) do
		if tbl.raw ~= true then
			local table_filename = self.db_dir .. "/" .. table_name .. ".dat"
			local collumn_ids = reload_collumnids( table_filename )
			if collumn_ids then
				self.tables[table_name] = { collumns = collumn_ids }
				self.opened = true
			else
				self.tables[table_name] = {}
				logf(LG_WRN,lgid,"internal database format error: no collumn id's found for table %s", table_name, table_filename )
			end
		end
	end

end

local function close(self)
	if self.opened then
		for i,_ in pairs(self.tables) do
			self.tables[i] = {}
		end
		self.opened = false
	end
end

local function write_table( self, table, content )
	local fname = self.db_dir .. "/" .. table .. ".dat"
	local f = io.open(fname,"w")
	if not f then
		logf(LG_WRN,lgid,"Could not make %s persistent", table)
		return false
	end
	logf(LG_DMP,lgid,"Dumping to %s: '%s'", fname, content)
	f:write(content)
	f:close()
	return true
end

local function read_table( self, table )
	local f = io.open(self.db_dir .. "/" .. table .. ".dat","r")
	if not f then
		logf(LG_WRN,lgid,"Could not open table %s", table)
		return nil
	end
	local content = f:read("*all")
	f:close()
	return content
end


local function get_number_of_records( self, table )
	local f = io.open(self.db_dir .. "/" .. table .. ".idx","r")
	if not f then
		logf(LG_WRN,lgid,"Could not open index %s", table)
		return nil
	end
	local size = get_table_size( f )
	f:close()
	return size
end

--
-- Create simpledb object
--

-- @param db_dir_base    directory for expecting/storing dat and idx files
-- @param tables         empty table def, e.g.: { tbl1={[1]="barcode"}, tbl2={raw=true}, ... }
--                       the collumns will be filled in using the headers found in the dat files
function new( db_dir, tables )
	
	logf(LG_DBG,lgid,"new()")

	local obj = {
	-- private:
		-- data:
		db_dir = db_dir,
		tables = table.copy(tables,true), -- { tbl1={name[collumn_idx]="<name>", ...}, tbl2={...}, ... }
		opened = false,

	-- public:
		-- methods
		open = open,
		close = close,

		write_table = write_table, -- write the content of a complete table at once
		read_table = read_table, -- return the content of a complete table in 1 string

		import = import, -- ( import_dir, callback, userdata ) import all csv files
		find_record = find_record, -- find a record by it's key value (not for write_table tables)
		get_number_of_records = get_number_of_records, -- get the number of records of a certain table (not for write_table tables)
	}

	-- create a complete fresh (empty) database
	os.execute( "mkdir -p " .. obj.db_dir )
	for i,t in pairs(obj.tables) do
		logf(LG_DBG,lgid,"Checking table %s", i)
			
		if not sys.lstat( obj.db_dir .. "/" .. i .. ".dat" ) then
			if t.raw then
				logf(LG_INF,lgid,"Creating empty raw table %s", i)
				os.execute("touch " .. obj.db_dir .. "/" .. i .. ".dat")
			else
				logf(LG_INF,lgid,"Creating empty table %s", i)
				local collumns = ""
				local sep = ""
				for collumn_i,collumn in pairs( t ) do
					collumns = collumns .. sep .. collumn
					sep = ","
				end
				local f = io.open( obj.db_dir .. "/" .. i .. ".dat", "w" )
				if f then
					f:write( collumns )
					f:close()
				else
					logf(LG_WRN,lgid,"Could not create database (HW failure on mmc card?): replace mmc.")
					return nil
				end
			end
		end
		if not sys.lstat( obj.db_dir .. "/" .. i .. ".idx" ) then
			if t.raw ~= true then
				logf(LG_INF,lgid,"Creating empty index for %s", i)
				os.execute("touch " .. obj.db_dir .. "/" .. i .. ".idx")
			end
		end
	end

	return obj
end

