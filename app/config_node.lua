
module("Config_node", package.seeall)

--
-- Get value from node, calling get-watches if needed
--

local function get(node)

	if node.get_watch_list then
		local now = sys.hirestime()
		if not node.cache_until or (node.cache_until and now > node.cache_until) then
			for _, watch in ipairs(node.get_watch_list) do
				local value = watch.fn(watch.node, watch.fndata)
				if value then
					node:set(value)
				end
			end
			if node.cache then
				node.cache_until = now + node.cache
			end
		end
	end

	return node.value
end


--
-- Set value on node and trigger set-watches if value changed
--

local function set(node, value, now)
	value = tostring(value)
	if type_check(node.type, node.range, value) then
		if node.value ~= value then
			node.value = value
			if node.cache then
				node.cache_until = sys.hirestime() + node.cache
			end
			if node.set_watch_list then
				for _, watch in ipairs(node.set_watch_list) do
					if now then
						watch.fn(watch.node, watch.fndata)
					else
						watch.callcount = watch.callcount + 1
						evq:push("node_set_watch", { node = node, watch = watch }, 1.0)
					end
				end
			end
		end
		return true
	else
		return false
	end
end

-- Set raw, do not call watches

local function setraw(node, value)
	node.value = value
end


--
-- Returns true if 'node' is an ancestor of 'prospect'
-- 

local function is_ancestor(node, prospect)
	if prospect then
		if prospect.parent == node then
			return true
		else
			return node:is_ancestor(prospect.parent)
		end
	else
		return false
	end
end



--
-- Child iterator function
--

local function each_child(node)
	if not node:has_children() then
		return function() end
	end
	local i = 0
	local n = #node.child_list
	return function()
		i = i + 1
		if i <= n then return node.child_list[i] end
	end
end



--
-- Get full id of node
--


local function full_id(node)
	assert(node)
	local part = {}
	while node.parent do
		table.insert(part, 1, node.id)
		node = node.parent
	end
	return "/" .. table.concat(part, "/")
end

--
-- Add child to node
--

local function add_child(node, child)
	node.child_list = node.child_list or {}
	table.insert(node.child_list, child)
	node.child_list[child.id] = child
	child.parent = node
end


--
-- Add watch to node and all of its children
--

local function add_watch(node, action, fn, fndata)

	local watch = {
		action = action,
		fn = fn,
		node = node,
		fndata = fndata,
		callcount = 0,
	}

	local function setwatch(node, watch)
		if action == "set" then
			node.set_watch_list = node.set_watch_list or {}
			table.insert(node.set_watch_list, watch)
		end
		if action == "get" then
			node.get_watch_list = node.get_watch_list or {}
			table.insert(node.get_watch_list, watch)
		end
		for child in node:each_child() do
			setwatch(child, watch)
		end
	end

	setwatch(node, watch)
end


--
-- Lookup child nodes by id
--

local function lookup(node, fid)

	if fid:match("^\/") then
		while node.parent do node = node.parent end
	end

	for id in fid:gmatch("([^/]+)") do
		if id == ".." then
			node = node.parent
		elseif node.child_list and node.child_list[id] then
			node = node.child_list[id]
		else
			node = nil
		end
		if not node then return nil end
	end
	return node
end


local function on_node_set_watch(event)
	local watch = event.data.watch
	if watch.callcount > 0 then
		watch.callcount = watch.callcount - 1
		if watch.callcount == 0 then
			watch.fn(watch.node, watch.fndata)
		end
	end
end


--
-- Check if node is visible by checking its dependencies
--

local function is_visible(node)

	local result = false
	local exp = node.depends

	if exp then

		-- Rewrite the schema's 'depend expression' to a valid lua expression:
		--   /foo/bar == value   
		-- becomes
		--   node:lookup("/foo/bar"):get() == "value"

		exp = exp:gsub("([%w%./]+)%s*([~=><]+)", "node:lookup('%1'):get() %2")
		exp = "node = ...; return " .. exp
		local chunk,err = loadstring(exp)
		if chunk then
			local ok, result = pcall(chunk, node)
			if not ok then
				logf(LG_WRN, "config", "Error in depend-expression %s: %s", exp, result)
			end
			logf(LG_DMP, "config", "Depend-expression: %s = %s", exp, tostring(result))
			return result
		else
			logf(LG_WRN, "config", "Error in depend-expression: %s", err)
		end
	else
		result = true
	end
	return result
end

--
-- Shortcuts to query node mode
--

local function is_readable(node)   if node.mode then return node.mode:find("r") else return true end end
local function is_writable(node)   if node.mode then return node.mode:find("w") else return true end end
local function is_persistent(node) if node.mode then return node.mode:find("p") else return true end end
local function has_data(node)      return node.value and true or false end
local function has_children(node)  return node.child_list and true or false end


--
-- Metatable assigned to all config nodes
--

local node_meta = {

	__index = {
		get = get,
		set = set,
		setraw = setraw,
		full_id = full_id,
		is_ancestor = is_ancestor,
		each_child = each_child,
		add_child = add_child,
		add_watch = add_watch,
		lookup = lookup,
		is_visible = is_visible,
		is_readable = is_readable,
		is_writable = is_writable,
		is_persistent = is_persistent,
		has_data = has_data,
		has_children = has_children,
	}
}

--
-- Constructor
--

local watch_registered = false


function new(config, definition)

	local node = {
		config = config,
	}

	-- Copy node properties from definition
	
	for key, val in pairs(definition) do
		if type(key) ~= "number" then
			node[key] = val
		end
	end

	-- Methods go into a metatable to save memory
	
	setmetatable(node, node_meta)

	if not watch_registered then
		evq:register("node_set_watch", on_node_set_watch)
		watch_registered = true
	end

	return node
end


-- vi: ft=lua ts=3 sw=3
