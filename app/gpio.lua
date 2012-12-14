module("Gpio", package.seeall)

-- This module is able to write various gpio
-- It also is able to read the external gpio in ports
-- On change of gpio in (or just on a regular basis) it sends "gpio" events with:
-- 	event.data = { [5|7]={ value=0|1,count=n } }

local lgid = "gpio"

local function read_gpi( self )
	if self.fd_gpi then
		sys.rewind(self.fd_gpi)
	
		local ftxt = sys.read( self.fd_gpi, 512 );
		logf(LG_DBG,lgid,"/tmp/gpi='%s'", ftxt or "nil")

		for i,pin in ipairs({5,7}) do
			local v,c = ftxt:match("GPI " .. pin .. " ([01]) (%d+)")
			self.last_gpi[pin].value = tonumber(v)
			self.last_gpi[pin].count = tonumber(c)
		end
		return true
	end
	return false
end

local function on_fd_gpi( event, self )

	if event.data.fd ~= self.fd_gpi_inotify then
		return
	end

	logf(LG_EVT,lgid,"GPI event detected for wd=%d", self.wd_gpi)

	-- the event is alway a change event on /tmp/gpi, so we only have to clear the buffer:
	local wd, err
	wd = 1
	while wd 
	do
		wd,err = sys.inotify_read_event( self.fd_gpi_inotify )
		if err then
			logf(LG_WRN,lgid,"inotify read error: %s", err or "Unknown error")
			return
		end
		if wd then
			logf(LG_DBG,lgid,"inotify read event for wd=%d", wd)
		end
	end

	local count = {}
	count[5] = self.last_gpi[5].count
	count[7] = self.last_gpi[7].count

	if self:read_gpi() then
		for pin,curr in pairs(self.last_gpi) do
			if count[pin]~=curr.count then
				logf( LG_DBG,lgid,"pin%d = {value=%d, count=%d}", pin, curr.value, curr.count )
				evq:push("gpio", { [pin] = { value=curr.value, count=curr.count } } )
			end
		end	
	end
end

local function open(self)
	if not self.fd then
		self.fd = sys.open( "/dev/gpio", "rw" )

		self.fd_gpi, errstr = sys.open( "/tmp/gpi", "r" )
		if self.fd_gpi == nil then
			logf(LG_WRN,lgid,"Failed to open general purpose input: %s", errstr or "unknown error" )
			self.fd_gpi = nil
		end

		self.fd_gpi_inotify, err_inotify_init = sys.inotify_init();
		if self.fd_gpi_inotify == nil then
			logf(LG_WRN,lgid,"Failed to init watch for gpi events: %s", err_inotify_init or "unknown error" )
			self.fd_gpi = nil
		end

		self.wd_gpi, err_inotify_add_watch = sys.inotify_add_watch( self.fd_gpi_inotify, "/tmp/gpi" )
		if self.wd_gpi == nil then
			logf(LG_WRN,lgid,"Failed to watch gpi events: %s", err_inotify_add_watch or "unknown error" )
			self.fd_gpi = nil
		end
		
		-- program port for output just by setting:
		self:set_pin( 1, 0 )
		self:set_pin( 3, 0 )

		logf(LG_INF,lgid,"gpio opened")
	end
end

local function close(self)
	if self.fd then
		self:disable() -- just in case

		sys.inotify_rm_watch( self.fd_gpi_inotify, self.wd_gpi )
		self.wd_gpi = nil
		
		sys.close( self.fd_gpi_inotify )
		self.fd_gpi_inotify = nil

		sys.close(self.fd_gpi)
		self.fd_gpi = nil

		sys.close(self.fd)
		self.fd = nil
		logf(LG_INF,lgid,"gpio closed")
	end
end

local function enable(self)
	if self.fd_gpi == nil then
		logf(LG_WRN,lgid,"gpi not opened" )
	else
		self:read_gpi() -- prevent sending both inputs the first time
		evq:fd_add( self.fd_gpi_inotify )
		evq:register( "fd", on_fd_gpi, self )
		logf(LG_INF,lgid,"gpio enabled")
	end
end

local function disable(self)
	if self.fd_gpi ~= nil then
		evq:unregister( "fd", on_fd_gpi, self )
		evq:fd_del( self.fd_gpi_inotify )
		logf(LG_INF,lgid,"gpio disabled")
	end
end

-- return: { value=0|1 , count=evt_counter }
local function get_pin( self, pin_offset )
	-- read /tmp/gpi
	if self:read_gpi() then
		return self.last_gpi[pin_offset]
	else
		return nil
	end
end

local function set_pin(self, pin_offset, value)
	if self.fd then
		local result, err = sys.ioctl_gpio_set( self.fd, pin_offset, value )
		if not result then
			logf(LG_WRN, lgid, "GPIO set error: %s", err)
		end
		return result, err
	else
		return nil, "Device not opened"
	end
end

local function backlight( self, on )
	if self.fd then
		--#define LCD_BACKLIGHT_ON          0x5506  /* Lcd back light on */
		--#define LCD_BACKLIGHT_OFF         0x5507  /* Lcd back light off */
		--ioctl(fd, LCD_BACKLIGHT_ON, 0);   -->Turn backlight on
		--ioctl(fd, LCD_BACKLIGHT_OFF,0);   -->Turn backlight off
		--PS:HW version v1.3 or later version	
		sys.ioctl( self.fd, on and 0x5506 or 0x5507, 0 )
	end
end

local function scan_1d_led( self, on )
	if self.fd then
		--#define 	SCAN1D_LED_ON   0x5518
		--#define 	SCAN1D_LED_OFF   0x5517
		sys.ioctl( self.fd, on and 0x5518 or 0x5517, 0 )
	end
end

function new()
	local self = {
		-- private data:
		fd = nil,
		fd_gpi = nil,
		fd_gpi_inotify = nil,
		wd_gpi = nil,
		
		pin5 = nil,
		pin7 = nil,
		last_gpi = { [5]={value=0,count=0}, [7]={value=0,count=0} },

		read_gpi = read_gpi,
		
		-- public methods:
		open = open,
		close = close,
		enable = enable,
		disable = disable,
		
		set_pin = set_pin,
		get_pin = get_pin,
		backlight = backlight,
		scan_1d_led = scan_1d_led,
	}

	return self
end

