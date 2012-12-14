
module("Config", package.seeall)

require "config_node"
require "typecheck"

local lgid="config"

--
-- Load schema from file. The lua parser itself is used for parsing the
-- configuration file, using a environment with only a few functions for
-- definging groups and objects.
--

local function load_schema(config, fname)

	-- Schema parser functions, these are the only functions available
	-- in the environment when the schema file is parsed

	local env = {

		-- Create group node

		group = function(def)
			local node = Config_node.new(config, def)
			for i,c in ipairs(def) do
				node:add_child(c)
			end
			return node
		end,

		-- Create object node
		
		object = function(def)
			local node = Config_node.new(config, def)
			node.value = node.default
			return node
		end,

		-- Include file

		include = function(fname)
			return load_schema(config, fname)
		end
	}

	local env_meta = {
		__index = function(_, key)
			error("Unknown keyword '" .. key .. "'", 2)
		end
	}

	setmetatable(env, env_meta)

	-- Load config file and parse in protected mode

	local chunk,err = loadfile(fname)
	if not chunk then
		logf(LG_FTL, lgid, "Could not load schema from %s: %s", config.fname_schema, err)
	end

	setfenv(chunk, env)

	local ok, db = pcall(chunk)
	if not ok then
		logf(LG_FTL, lgid, "Error loading schema %q: %s", config.fname_schema, db)
	end

	-- Traverse generated tree to force inheritance of some attributes
	
	local function inherit(node, keys)
		for child in node:each_child() do
			for _, key in pairs(keys) do
				child[key] = child[key] or node[key]
			end
			inherit(child, keys)
		end
	end

	inherit(db, { "prio", "mode" })
	
	return db

end



--
-- Load config database from file
--

local function load_db(config, fname_db)

	local fd, err = io.open(fname_db, "r")
	if not fd then
		return
	end
	logf(LG_INF, lgid, "Loading config file %s", fname_db)

	for l in fd:lines() do
		config:set_config_item( l:gsub("\r$","") )
	end

	fd:close()

	local s = sys.lstat(fname_db)
	config.mtime = s.mtime

	return true
end

--
-- set a config item from a cit.conf formatted line
-- TODO: Note that, because this line can also be read from a barcode, it can
-- actually contain multiple definitions like:
-- /nodename = "value x" /group/name2 = y
-- or:
-- /nodename = "value x" ; /group/name2 = y
--
local function set_config_item( config, l )

	if l:match("^#") then 
		return 
	end
	while l and #l>0 do
		local fid, rest = l:match("[;%s]*(%S+)%s*=%s*(.*)")
		local next_tv = ""
		if not fid then
			logf(LG_WRN,lgid,"Could not read line '%s'" , l )
			return
		else
			local node = config:lookup(fid)
			if node then
				local is_string = node.options and node.options:find("b") or 
						node.type == "enum" and (not node.config_type or node.config_type ~= "number") or 
						node.type == "string" or 
						node.type == "password" or 
						node.type == "pattern" 
				local value
				value, next_tv = fetch_value( rest, is_string )
				--logf(LG_DMP,lgid,"read: l='%s', fid='%s', value='%s', rest='%s'" , l, fid or "nil", value or "nil", (next_tv or "nil"))
				if value then
					local vvalue = value
					if node.options and node.options:find("b") or node.type == "string" then
						vvalue = escapes_to_binstr( value, "\"" )
					end
					if type_check(node.type, node.range, vvalue) then
						node:set(vvalue)
					else
						logf(LG_WRN,lgid,"Incorrect type for node %s with value '%s'", fid, vvalue )
					end
				else
					logf(LG_WRN,lgid,"Could not read value for node %s", fid)
				end
			else
				logf(LG_WRN,lgid,"Unrecognized node %s", fid )
			end
		end
		l = next_tv
	end
	
end

--
-- Save config database to file
--

local function save_db(config, fname_db)

	logf(LG_DBG, lgid, "Saving configuration to %s", fname_db)

	local function s(fd, node, prefix)
			
		if node:is_persistent() then

			if node:has_data() then
				local prefix2 = prefix:gsub("^%.", "")
				if node.options and node.options:find("b") then
					fd:write(prefix2 .. "/" .. node.id .. " = \"" .. binstr_to_escapes(node.value,nil,nil,"\"") .. "\"\n")
				elseif node.type == "string" or (node.type == "enum" and node.config_type ~= "number") or node.type == "password" or node.type == "pattern" then
					-- TODO: check whether this also works with high utf8 charracters
					fd:write(prefix2 .. "/" .. node.id .. " = \"" .. binstr_to_escapes(node.value, 32, 256, "\"" ) .. "\"\n")
				else
					fd:write(prefix2 .. "/" .. node.id .. " = " .. node.value .. "\n")
				end
			end

			if node:has_children() then
				fd:write("\n# " .. (node.label or "") .. "\n\n")
				for node_child in node:each_child() do
					local newprefix = prefix
					if node_child:has_children() then
						newprefix = prefix .. "/" .. node_child.id
					end
					s(fd, node_child, newprefix)
				end
			end
		end
	end

	local fname_tmp = fname_db .. ".tmp"
	local fd, err = io.open(fname_tmp, "w")
	if not fd then
		logf(LG_WRN,lgid, "Could not write to config db %s: %s", fname_tmp or "nil", err or "nil")
		return
	end

	s(fd, config.db, "")

	fd:write("\n")
	fd:write("# End\n")
	fd:write("\n")
	fd:close()

	-- Rename temporary file to new file name (atomic)
	
	local ok, err = os.rename(fname_tmp, fname_db)
	if not ok then
		logf(LG_WRN, lgid, "Could not rename %s to %s: %s", fname_tmp, fname_db, err)
	end
	
	-- Create a copy of the configuration in /home/ftp to allow backup/restore
	
	os.execute("rm -f /home/ftp/%s" % fname_db)
	os.execute("cp -a %s /home/ftp/" % fname_db)
	os.execute("chown ftp.ftp /home/ftp/%s" % fname_db)
	os.execute("chmod 664 /home/ftp/%s" % fname_db)

	-- Remember the mtime of the config file for automatic reloading
	
	local s = sys.lstat(config.fname_db)
	if s then
		config.mtime = s.mtime
	else
		config.mtime = os.time()
	end

	
end



--
-- Get config node by full id
--

local function lookup(config, fid)
	return config.db:lookup(fid)
end


--
-- Get node value 
--

local function get(config, fid)
	local node = config:lookup(fid)
	if node then
		return node:get()
	else
		logf(LG_WRN, lgid, "Trying to get unknown node %q", fid)
		return ""
	end
end


--
-- Set node value 
--

local function set(config, fid, value, now)
	local node = config:lookup(fid)
	if node then
		return node:set(value, now)
	else
		logf(LG_WRN, lgid, "Trying to set unknown node %q", fid)
		return false
	end
end


--
-- Register callback on node set or get
--

local function add_watch(config, fid, action, fn, fndata)
	local node = config:lookup(fid)
	if node then
		return node:add_watch(action, fn, fndata)
	else
		logf(LG_WRN, lgid, "Trying to register unknown node %q", fid)
		return false
	end
end


--
-- Restore factory defaults
--

local function restore_defaults(config)

	local function setdef(node)
		if node.default then
			node:set(node.default)
		else
			for child in node:each_child() do
				setdef(child)
			end
		end
	end

	logf(LG_INF, lgid, "Restoring factory defaults")
	setdef(config.db)
	config:save_db(config.fname_db)
end


--
-- Check if configfile changed and reread
--

local function on_config_timer(event, config)

	-- Check mtime of main config file
	
	local s = sys.lstat(config.fname_db)

	if not s or s.mtime > config.mtime then
		logf(LG_DBG, lgid, "Config file was modified, rereading")
		config:load_db(config.fname_db)
		config:save_db(config.fname_db)
	end

	-- Check mtime of config file in /home/ftp
	
	local s = sys.lstat("/home/ftp/" .. config.fname_db)

	if s and s.mtime > config.mtime then
		logf(LG_DBG, lgid, "FTP Config file was modified, rereading")
		config:load_db("/home/ftp/" .. config.fname_db)
		config:save_db(config.fname_db)
	end

	-- rescedule the event:
	return true
end



-- 
-- Constructor
--

function new(fname_schema, fname_db)

	local config = {

		-- data
		
		db = {},
		fname_schema = fname_schema,
		fname_db = fname_db,

		-- methods

		load_schema = load_schema,
		load_db = load_db,
		save_db = save_db,
		set_config_item = set_config_item,

		lookup = lookup,
		set = set,
		get = get,
		restore_defaults = restore_defaults,
		add_watch = add_watch,
	}

	-- load defaults:
	config.db = config:load_schema(fname_schema)

	-- than load config from file:
	-- first try to load the 'reset configfile'
	if not config:load_db("/mnt/" .. config.fname_db) then
		-- than try to load the configfile made just before an upgrade:
		if config:load_db("/mnt/" .. config.fname_db .. ".bkup") then
			os.remove("/mnt/" .. config.fname_db .. ".bkup")
		else
			-- than try to load the work-configfile:
			if not config:load_db(config.fname_db) then
				logf(LG_WRN, lgid, "No config file found. Using defaults.")
			end
		end
	end
	config:save_db(config.fname_db)

	evq:register("config_timer", on_config_timer, config)
	evq:push("config_timer", nil, 1.0)

	config:add_watch("//", "set", 
		function(node, config)
			config:save_db(config.fname_db)
		end,
		config
	)

	return config
end


-- vi: ft=lua ts=3 sw=3

