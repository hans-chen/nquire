
module("Config", package.seeall)

require "config_node"
require "typecheck"

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
		logf(LG_FTL, "config", "Could not load schema from %s: %s", config.fname_schema, err)
	end

	setfenv(chunk, env)

	local ok, db = pcall(chunk)
	if not ok then
		logf(LG_FTL, "config", "Error loading schema %q: %s", config.fname_schema, db)
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
		logf(LG_WRN, "config", "Could not open config db %s: %s", config.fname_db, err)
		return
	end

	for l in fd:lines() do

		if l:match("^#") then l = "" end

		local fid, value = l:match("(%S+) = (.*)")
		if fid and value then
			local node = config:lookup(fid)
			if node then
				if type_check(node.type, node.range, value) then
					node:set(value)
				end
			end
		end
	end

	fd:close()

	local s = sys.lstat(config.fname_db)
	config.mtime = s.mtime
end



--
-- Save config database to file
--

local function save_db(config, fname_db)

	logf(LG_DBG, "config", "Saving configuration to %s", config.fname_db)

	local function s(fd, node, prefix)
			
		if node:is_persistent() then

			if node:has_data() then
				local prefix2 = prefix:gsub("^%.", "")
				fd:write(prefix2 .. "/" .. node.id .. " = " .. node.value .. "\n")
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
		logf(LG_WRN, "Could not write to config db %s: %s", fname_tmp, err)
		return
	end

	s(fd, config.db, "")

	fd:write("\n")
	fd:write("# End\n")
	fd:write("\n")
	fd:close()

	-- Rename temporaty file to new file name (atomic)
	
	local ok, err = os.rename(fname_tmp, config.fname_db)
	if not ok then
		logf(LG_WRN, "config", "Could not rename %s to %s: %s", fname_tmp, config.fname_db, err)
	end
	
	-- Create a copy of the configuration in /home/ftp to allow backup/restore
	
	os.execute("rm -f /home/ftp/%s" % config.fname_db)
	os.execute("cp %s /home/ftp/" % config.fname_db)
	os.execute("chown ftp.ftp /home/ftp/%s" % config.fname_db)

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
		logf(LG_WRN, "config", "Trying to get unknown node %q", fid)
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
		logf(LG_WRN, "config", "Trying to set unknown node %q", fid)
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
		logf(LG_WRN, "config", "Trying to register unknown node %q", fid)
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

	logf(LG_INF, "config", "Restoring factory defaults")
	setdef(config.db)
	config:save_db(config.fname_db)
end


--
-- Check if configfile changed and reread
--

local function on_config_timer(event, config)

	-- Check mtime of main config file
	
	local s = sys.lstat(config.fname_db)

	if not s or s.mtime ~= config.mtime then
		logf(LG_DBG, "config", "Config file was modified, rereading")
		config:load_db(config.fname_db)
		config:save_db(config.fname_db)
	end

	-- Check mtime of config file in /home/ftp
	
	local s = sys.lstat("/home/ftp/cit.conf")

	if s and s.mtime ~= config.mtime then
		logf(LG_DBG, "config", "FTP Config file was modified, rereading")
		config:load_db("/home/ftp/cit.conf")
		config:save_db(config.fname_db)
	end

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
		lookup = lookup,
		set = set,
		get = get,
		restore_defaults = restore_defaults,
		add_watch = add_watch,
	}

	config.db = config:load_schema(fname_schema)
	config:load_db(config.fname_db)
	config:save_db(config.fname_db)

	evq:register("timer_1hz", on_config_timer, config)

	config:add_watch("//", "set", 
		function(node, config)
			config:save_db(config.fname_db)
		end,
		config
	)

	return config
end


-- vi: ft=lua ts=3 sw=3

