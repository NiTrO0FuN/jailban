function ulx.jailban(calling_ply, target_ply, minutes, reason)

	local time = "for #s"
	if minutes == 0 then time = "permanently" end
	local str = "#A jail-banned #T " .. time
	if reason and reason ~= "" then str = str .. " (#s)" end
	ulx.fancyLogAdmin(calling_ply, str, target_ply, minutes ~= 0 and ULib.secondsToStringTime( minutes * 60 ) or reason, reason )
	-- Delay by 1 frame to ensure any chat hook finishes with player intact. Prevents a crash.
	ULib.queueFunctionCall( GJailBan.jailban, calling_ply, target_ply, minutes, reason, calling_ply)
end

function ulx.jailbanid(calling_ply, target_steamid, minutes, reason)

	if not ULib.isValidSteamID( target_steamid ) then
		ULib.tsayError( calling_ply, "Invalid steamid." )
		return
	end

	local time = "for #s"
	if minutes == 0 then time = "permanently" end
	local str = "#A jail-banned #s " .. time
	if reason and reason ~= "" then str = str .. " (#s)" end
	ulx.fancyLogAdmin(calling_ply, str, target_steamid, minutes ~= 0 and ULib.secondsToStringTime( minutes * 60 ) or reason, reason )
	-- Delay by 1 frame to ensure any chat hook finishes with player intact. Prevents a crash.
	ULib.queueFunctionCall( GJailBan.jailbanid, calling_ply, target_steamid, minutes, reason, calling_ply)
end

local ban = ulx.command( "Utility", "ulx jailban", ulx.jailban, "!jailban", false, false, true )
ban:addParam{ type=ULib.cmds.PlayerArg }
ban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
ban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
ban:defaultAccess( ULib.ACCESS_ADMIN )
ban:help( "Jailbans target." )

local banid= ulx.command( "Utility", "ulx jailbanid", ulx.jailbanid, "!jailbanid", false, false, true )
banid:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
banid:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
banid:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
banid:defaultAccess( ULib.ACCESS_ADMIN )
banid:help( "Jailbans steamid." )

function ulx.unjailban( calling_ply, target_steamid )
	ulx.fancyLogAdmin( calling_ply, "#A unjail-banned #s", target_steamid )
	-- Delay by 1 frame to ensure any chat hook finishes with player intact. Prevents a crash.
	ULib.queueFunctionCall( GJailBan.unjailban, target_steamid)
end

local unban = ulx.command( "Utility", "ulx unjailban", ulx.unjailban, "!unjailban", false, false, true )
unban:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
unban:defaultAccess( ULib.ACCESS_ADMIN )
unban:help( "Unjailbans target." )
