module("Gpio", package.seeall)

local lgid = "gpio"

local function on_poll_gpio( event, self )

	if config:get("/dev/gpio/method") ~= "On read GPIO" then

		local pin5 = self:get_pin( 5 )
		local pin7 = self:get_pin( 7 )
		if self.pin5 == nil then self.pin5 = pin5 end
		if self.pin7 == nil then self.pin7 = pin7 end
	
		local now = sys.hirestime()
		local send_timed = config:get("/dev/gpio/method") == "Poll" and 
			now - self.last_poll >= tonumber(config:get("/dev/gpio/poll_delay"))

		if send_timed or self.pin5 ~= pin5 then
			logf( LG_DMP,lgid,"Send gpio pin5 = %d", pin5 )
			cit:send_to_clients( config:get("/dev/gpio/prefix") .. "0" .. string.char(pin5+0x30) )
			self.last_poll = now
		end
		if send_timed or self.pin7 ~= pin7 then
			logf( LG_DMP,lgid,"Send gpio pin7 = %d", pin7 )
			cit:send_to_clients( config:get("/dev/gpio/prefix") .. "1" .. string.char(pin7+0x30) )
			self.last_poll = now
		end

		self.pin5 = pin5
		self.pin7 = pin7
	end
	
	return true
end

local function open(self)
	if not self.fd then
		self.fd = sys.open( "/dev/gpio", "rw" )
		
		-- program port for output and input just by setting and getting:
		self:set_pin( 1, 0 )
		self:set_pin( 3, 0 )
		self:get_pin( 5 )
		self:get_pin( 7 )
		
		evq:register( "gpio_poll", on_poll_gpio, self )
		evq:push("gpio_poll",nil,0.1)
	end
end

local function close(self)
	if self.fd then
		evq:unregister( "gpio_poll", on_poll_gpio, self )

		sys.close(self.fd)
		self.fd = nil
	end
end

local function enable(self)
	evq:register( "gpio_poll", on_poll_gpio, self )
end

local function disable(self)
	evq:unregister( "gpio_poll", on_poll_gpio, self )
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

local function get_pin(self, pin_offset)
	if self.fd then
		local value, err = sys.ioctl_gpio_get( self.fd, pin_offset )
		if not value then
			logf(LG_WRN, lgid, "GPIO get error: %s", err)
			return nil
		end
		return value, err
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
		
		pin5 = nil,
		pin7 = nil,
		last_poll = 0,
		
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

	evq:register( "input", 	
		function( event, gpio )
			if event.data.msg == "disable" then
				gpio:disable()
			elseif event.data.msg == "enable" then
				gpio:enable()
			end
		end, self )

	return self
end

