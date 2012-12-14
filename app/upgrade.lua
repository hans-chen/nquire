--
-- Copyright © 2007 All Rights Reserved.
--
-- Images have the filename <product>-<component>-<version>-<md5sum>.image
--
-- * periodically check if any files are on /home/ftp which match the above filename schema
-- * check the file size
-- * if the file size has not changed for 5 seconds, assume the upload has completed
-- * after upload is complete, verify the md5 sum of the contents of the image with the md5 sum in the filename
-- * if both are the same, image will be flashed
-- * if they fail, the image might not yet be complete, wait for 10 seconds and try again
-- * if the image is older then 5 minutes and the checksum is not ok, the image is removed


module("Upgrade", package.seeall)


local path_upgrade_dir = "/home/ftp"
local path_upgrade_script = "/bin/target_unpack_tar.sh"
local max_age_cleanup = 5 * 60

local component_list = {
	kernel = { option = "-k" },
	app = { option = "-s" },
	rootfs = { option = "-r" },
	logo = { option = "-l" },
	firmware = { option = "-f" },
}

upgrade_busy = false

local function on_upgrade_timer()

	local files, err = sys.readdir(path_upgrade_dir)
	if not files then
		logf(LG_WRN, "upgrade", "Could not read directory %s: %s", path_upgrade_dir, err)
		return true
	end

	if upgrade_busy then
		logf(LG_INF, "upgrade", "Upgrade in progress")
		return
	end

	local now = os.time()

	for _, file in ipairs(files) do

		file = path_upgrade_dir .. "/" .. file
		
		-- Check if this is a regular file, not a directory or symlink

		local stat = sys.lstat(file)
		
		if stat.isreg then
		
			-- Calculate how long the file has not been modified

			local age = os.time() - stat.mtime
	
			-- Check if this is a image file

			local product, component, version, md5sum = file:match(".+/(.-)%-(.-)%-(.-)%-(.-)%.image")

			if product and component and version and md5sum and age > 5 then

				if component_list[component] then
				
					logf(LG_INF, "upgrade", "Found %s image file %s, veryfing md5 sum", component, file)

					-- Calculate MD5 checksum

					local real_md5sum = ""
					local fd, err = io.popen("md5sum " .. file)
					if fd then
						local tmp = fd:read("*a")
						tmp = tmp:match("(%S+)")
						if tmp then real_md5sum = tmp end
						fd:close()
					else
						logf(LG_WRN, "upgrade", "Could not calculate md5 sum: %s", err)
					end

					-- Checksum ok, start upgrade

					if md5sum == real_md5sum then
						logf(LG_INF, "upgrade", "MD5 sum verified and correct, initiating upgrade")
						scanner:disable()
				
						local cmd = "/bin/target_unpack_tar.sh %s %s" % { component_list[component].option, file } 
						logf(LG_DBG, "upgrade", "Running command %q", cmd);
	
						display:set_font( nil, 18, nil )
						display:show_message("Upgrading", "firmware", "", "DON'T", "DISCONNECT", "THE POWER")
						logf(LG_INF, "upgrade", "Starting upgrade")

						upgrade_busy = true

						runbg(cmd, function(rv)
							if rv == 0 then
								os.execute("sync")
								sys.sleep(2)
								logf(LG_INF, "upgrade", "Upgrade successfull")
								display:set_font( nil, 18, nil )
								display:show_message("", "Upgrade ok", "", "rebooting")
								os.remove(file)
								os.execute("reboot")
							else
								logf(LG_WRN, "upgrade", "Upgrade failed")
								upgrade_busy = false
							end

						end)

					else
						logf(LG_WRN, "upgrade", "Checksum mismatch (%s != %s), can not upgrade", md5sum, real_md5sum)
					end

				else
					logf(LG_WRN, "upgrade", "Unknown component %q, can not upgrade", component)
				end

				-- Check the file is older then 5 minutes. If so, clean it up

				if age > max_age_cleanup then
					logf(LG_INF, "Found stale file %s which is older then %d seconds, cleaning up", file, max_age_cleanup)
					local ok, err = os.remove(file)
					if not ok then
						logf(LG_WRN, "Could not erase %s: %s", file, err)
					end
				end
			end
		end
	end

	return true
end


--
-- Constructor
--

function new(device, baudrate)

	-- Register a periodic timer to check for upgrades
	
	evq:register("upgrade_timer", on_upgrade_timer)
	evq:push("upgrade_timer", nil, 10.0)

end

-- vi: ft=lua ts=3 sw=3
	
