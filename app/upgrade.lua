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
--
-- This module spawns the following events:
-- "upgrade"
--       data.msg="start" : an image file is recognized, the checksum is verified and an upgrade is about to start
--       data.msg="progress" : data.comment contains the progress report (subsys: read/write x%)
--       data.msg="error" : an upgrade is failed, data.errstr gives the exact error
--       data.msg="ready" : an upgrade is ready. the unit should be booted
--         



module("Upgrade", package.seeall)

local lgid = "upgrade"

local path_upgrade_dir = "/home/ftp"
local max_age_cleanup = 5 * 60
local the_config_file = ""
local real_md5sum_mtime = 0
local progress_on_subsys = nil
local last_progress_event = 0


local component_list = {
	kernel = { option = "-k" },
	app = { option = "-s" },
	rootfs = { option = "-r" },
	logo = { option = "-l" },
	firmware = { option = "-f" },
	em2027kernel = { option = "-e", scanner_type="em2027" },
	em2027app = { option = "-m", scanner_type="em2027" },
	em1300kernel = { option = "-d", scanner_type="em1300" },
}

local upgrade_busy = false
local upgrade_file = nil

local function remove_file( f )
	local ok
	if not upgrade_busy then
		local err
		ok, err = os.remove(f)
		if not ok then
			logf(LG_WRN, lgid, "Could not erase %s: %s", f, err)
		end
	else
		logf(LG_WRN, lgid, "Not removed file %s: upgrade in progress", f or "nil")
	end
	return ok
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

local function on_upgrade_timer()

	local files, err = sys.readdir(path_upgrade_dir)
	if not files then
		logf(LG_WRN, lgid, "Could not read directory %s: %s", path_upgrade_dir, err)
		return true
	end

	if upgrade_busy then
		logf(LG_INF, lgid, "Upgrade in progress")
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

			if product and component and version and md5sum and age > 15 then

				if component_list[component] and (scanner==nil or 
						(component_list[component].scanner_type==nil or
						 scanner.type:match(component_list[component].scanner_type))) then
				
					if stat.mtime ~= real_md5sum_mtime then
						
						local real_md5sum = calc_md5sum( file )
						real_md5sum_mtime = stat.mtime
						
						-- Checksum ok ? start upgrade:
						if real_md5sum == md5sum then

							os.execute( "while killall vsftpd; do sleep 0.1; done" )
							
							-- check again to be sure the file is not changed during killing vsftpd
							real_md5sum = calc_md5sum( file )
							if real_md5sum ~= md5sum then
								logf(LG_DBG,lgid,"Checksum changed during killing of vsftpd, waiting for more...")
								os.execute("vsftpd &")
							else

								logf(LG_INF, lgid, "MD5 sum for %s verified and correct, initiating upgrade", file)

								evq:push("upgrade",{msg="start"},-1)
								upgrade_busy = true 
								upgrade_file = file

								-- watch out: no filesystems should be accessed during or after target_unpack_tar.sh
								local cmd = "/bin/target_unpack_tar.sh %s %s" % { component_list[component].option, file } 
								logf(LG_DBG, lgid, "Running command %q", cmd);
								logf(LG_INF, lgid, "Starting upgrade")

								runbg(cmd, 
									function(rv)
										if rv == 0 then
											os.execute("sync")
											evq:push("upgrade",{msg="ready"},-1)
											sys.sleep(2)
											os.execute("reboot") -- upgrade is busy until after reboot!!!
										else
											logf(LG_WRN, lgid, "Upgrade failed")
											-- try to dump diagnostic info to /mnt and reboot
											os.execute("logread > /mnt/log/upgrade_fail.log")
											os.execute("dmesg > /mnt/log/upgrade_fail.dmesg")
											os.execute("sync")
											evq:push("upgrade",{msg="error", errstr="Upgrade failed for " .. upgrade_file},0)
											upgrade_busy = false 
											progress_on_subsys = nil
											remove_file( file )
											file = nil
											os.execute( "vsftpd &" )
											
										end
									end,
									function(data)
										local subsys = data:match("NOTE:(%a+)")
										if subsys then 
											progress_on_subsys = subsys
										end
										local now = sys.hirestime()
										if progress_on_subsys and last_progress_event + 2 < now then
											last_progress_event = now
											local action, part = data:match("(%a+)%s+%%(%d+)")
											if action and part then
												evq:push("upgrade",{msg="progress", comment=progress_on_subsys .. ": " .. action .. " " .. part .. "%"},-1)
											end
										end
									end
								) -- runbg
							end -- else from not has_valid_checksum( file ))
						end -- has_valid_checksum( file )
						
					end -- stat.mtime ~= real_md5sum_mtime

				else
					logf(LG_WRN, lgid, "Unknown component %q, can not upgrade", component)
					remove_file( file )
				end

				-- Check if the file is older then 5 minutes. If so, clean it up

				if age > max_age_cleanup then
					logf(LG_INF, lgid, "Found stale file %s which is older then %d seconds, cleaning up", file, max_age_cleanup)
					remove_file( file )
				end
			end
		end
	end

	return true
end


-- for denying input and FS changes during upgrade
function busy()
	return upgrade_busy
end

--
-- Constructor
--

function new(device, baudrate, config_file)

	the_config_file = config_file
	
	logf(LG_INF,lgid,"Start upgrade service (config file: %s)", the_config_file)

	-- Register a periodic timer to check for upgrades
	evq:register("upgrade_timer", on_upgrade_timer)
	evq:push("upgrade_timer", nil, 10.0)

end

-- vi: ft=lua ts=3 sw=3
	
