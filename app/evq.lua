--
-- Copyright © 2008 All Rights Reserved.
--

module("Evq", package.seeall)

local lgid = "evq"

--
-- Merge function implementing a skew heap. The result is written to r.right.          
-- 
-- Skew heaps have an amortized complexity of O(log n) and are simple to
-- implement. The data structure is a heap-ordered binary tree. The basic
-- operation is the merge operation which merges two heaps into one. 
-- 

local function skew_merge(a, b, r) 
	if not b then 
		r.right = a 
	else 
		while a do 
			if a.when <= b.when then 
				r.right, r = a, a 
				a.left, a = a.right, a.left 
			else 
				r.right, r = b, b 
				b.left, a, b = b.right, b.left, a 
			end 
		end 
		r.right = b 
	end 
end 

--
-- Push a new event on the event queue. The delay parameter indicates when the
-- event should be emitted, if not given or 0, the event is handled as soon as
-- possible.
-- @param delay	the delay in seconds. The event is handles direct without queing
--                when delay==-1
--

local function push(evq, type, data, delay)
	--logf(LG_DBG,lgid, "Pushing event %s with delay %d" , type, delay or 0)

	-- Create new event
	
	delay = delay or 0
	local event = {
		type = type,
		data = data,
		delay = delay,
		when = sys.hirestime() + delay,
	}
	
	if delay == -1 then
		-- handle direct
		--logf(LG_DBG,lgid, "Direct handling event %s" , type)
		evq:handle( event )
	else
		-- Insert the event in the event queue
		skew_merge(evq.queue.right, event, evq.queue)
	end

end


--
-- 'handle' the event, that is call all registered handlers
-- that match the event type
--

local function handle(evq, event)
	local type = event.type
	if not evq.handler_list[type] then return end

	local requeue = false
	for _, handler in pairs(evq.handler_list[type]) do
		local rv = handler.fn(event, handler.udata)
		if rv then requeue = true end
	end

	-- Requeue the event if one of the handlers requested
	
	if requeue and event.delay > 0 then
		event.when = event.when + event.delay
		skew_merge(evq.queue.right, event, evq.queue)
	end
end


--
-- Register a handler for the given event type. The given 'fn' will be called
-- for every event with the given type.
--

local function register(evq, type, fn, udata)

	if not type then logf(LG_FTL, lgid, "No event type given") end
	if not fn then 
		print(debug.traceback())
		logf(LG_FTL, lgid, "No callback function given")
	end

	--print("DEBUG: evq:register(type='" .. type .. "')")
	evq.handler_list[type] = evq.handler_list[type] or {}
	table.insert(evq.handler_list[type], {
		type = type,
		fn = fn,
		udata = udata
	})
end


--
-- Unregister a handler for the given event type. 
--

local function unregister(evq, type, fn, udata)

	if evq.handler_list[type] then
		for i,h in pairs(evq.handler_list[type]) do
			if h.type == type and h.fn == fn and h.udata == udata then
				table.remove(evq.handler_list[type], i)
				return
			end
		end
	end
	logf(LG_DBG, lgid, "Trying to unregister non-existing event handler for %s", type)
end


--
-- Add a file descriptor for the event queue to watch
--

local function fd_add(evq, fd, what)
	what = what or "r"
	if not evq.fd_list[what] then
		logf(LG_FTL, lgid, "Illegal fd type %s, use (r)ead (w)rite or (e)rror", what)
	end
	evq.fd_list[what][fd] = true
end


--
-- Remove filedescriptor from the list
--

local function fd_del(evq, fd, what)
	what = what or "r"
	if not evq.fd_list[what] then
		logf(LG_FTL, lgid, "Illegal fd type %s, use (r)ead (w)rite or (e)rror", what)
	end
	evq.fd_list[what][fd] = nil
end


--
-- Add a signal for the event queue to watch
--

local function signal_add(evq, signal)
	sys.signal(signal, true)
end


--
-- Remove a signal from the event queue 
--

local function signal_del(evq, signal)
	sys.signal(signal, false)
end


--
-- Call given function for each event in the queue
--

local function map(evq, fn)

	local function visit(event, fn)
		if event and event.type then fn(event) end
		if event.right then visit(event.right, fn) end
		if event.left then visit(event.left, fn) end
	end

	visit(evq.queue, fn)
end


--
-- Return and handle one event from the event queue.
--
-- parameters:
--   wait:  if set to true, the function blocks until an event is ready, 
--          otherwise returns right away
--
-- returns:
--   an event from the queue, or nil if no event available
--

local function pop(evq)
	
	local timeout 

	while true do

		-- Peek at first event in queue

		local now = sys.hirestime()
		local event = evq.queue.right

		if event then

			-- If event is due, remove from queue, handle and return
			
			if now >= event.when then
				skew_merge(event.left, event.right, evq.queue)                                                                                 
				event.left, event.right = nil, nil  
				evq:handle(event)
				return event
			end

			-- If event is not due, calculate the time to sleep

			timeout = event.when - now
			if timeout < 0  then timeout = 0 end

		else
			timeout = nil
		end

		-- Call select function to watch fd's and sleep for the required timeout

		local fds_out = sys.select(evq.fd_list, timeout)

		-- Generate events for all ready file descriptors 

		if fds_out then
			for what, fds in pairs(fds_out) do
				if fds then
					for fd, has_data in pairs(fds) do
						evq:push("fd", { fd = fd, what = what }, 0)
					end
				end
			end
		end
	end
end


--
-- Handle events from the queue until the queue is empty
--

local function flush(evq)

	while true do
		local ev = pop(evq, false)
		if not ev then break end
	end

end




--
-- Sleep, but keep handling the event queue
--

local function sleep(evq, delay)

	local sleeping = true

	local function wakeup()
		sleeping = false
	end

	evq:register("sleep", wakeup)
	evq:push("sleep", nil, delay)

	while sleeping do
		pop(evq, true)
	end

end


--
-- Create new event queue
--

function new()

	local evq = {

		-- data
	
		queue = {},
		handler_list = {},
		fd_list = { r = {}, w = {}, e = {}},
		
		-- methods
		
		register = register,
		unregister = unregister,
		push = push,
		pop = pop,
		map = map,
		fd_add = fd_add,
		fd_del = fd_del,
		signal_add = signal_add,
		signal_del = signal_del,
		handle = handle,
		sleep = sleep,
		flush = flush,
	}

	-- Create a pipe for the general signal handler to write to when a signal
	-- arrives. This pipe is added to the evq's fd list and will be handler by
	-- the select() call. (see http://cr.yp.to/docs/selfpipe.htmlThis )
	
	local fd_rx, fd_tx = sys.pipe()
	sys.signal_set_fd(fd_tx)
	evq.fd_signal = fd_rx
	evq:fd_add(fd_rx)
	evq:register("fd", 
		function(event, evq)
			local fd = event.data.fd
			if fd ~= evq.fd_signal then return end
			local signals = sys.read(evq.fd_signal, 32)
			for signal in signals:gmatch("([^\n]+)") do
				evq:push("signal", { signal = signal }, 0)
			end
		end, 
		evq
	)
	
	return evq
end

-- vi: ft=lua ts=3 sw=3

