local function tables_exist()
	if sql.TableExists("g_jailbans") then
		Msg("Jailban already existing !")
	else
        query = "CREATE TABLE g_jailbans ( steamid64 INTEGER NOT NULL PRIMARY KEY, time INTEGER, unbantime INTEGER,reason TEXT)"
        result = sql.Query(query)

        if (sql.TableExists("g_jailbans")) then
            Msg("Succes ! Jailban table created \n")
        else
            Msg("Something went wrong with the g_jailbans query ! \n")
            Msg( sql.LastError( result ) .. "\n" )
        end	
	end
end

local function player_isbanned( ply )
    if ply:IsBot() then return false end
	local steamID64 = ply:SteamID64()
	result = sql.Query("SELECT steamid64 FROM g_jailbans WHERE steamid64 = '" .. steamID64 .. "'")
	if result then return true end
    return false
end

GJailBan.sql_allbaninfo = function() 
    result = sql.Query("SELECT steamid64, time, unbantime, reason FROM g_jailbans")
	if result then return result end
    return nil
end

GJailBan.sql_ban_player = function(steamid, time, unbantime, reason)
    local r = sql.SQLStr(reason)
    sql.Query(
		"REPLACE INTO g_jailbans ( steamid64 , time , unbantime ,reason) " ..
		string.format( "VALUES (%s, %i, %i, %s)",
			util.SteamIDTo64(steamid),
			time,
			unbantime,
            r
		)
	)
end

GJailBan.sql_unban_player = function(steamid)
    sql.Query("DELETE FROM g_jailbans WHERE steamid64=" .. util.SteamIDTo64( steamid ))
end

GJailBan.sql_baninfo = function(steamid)
	result = sql.QueryRow("SELECT steamid64, time, unbantime, reason FROM g_jailbans WHERE steamid64 = " .. util.SteamIDTo64( steamid ))
	if result then return result end
    return nil
end

local function checkJailBan ( ply )
    if ply.jailBanned then
        GJailBan.banRespawn(ply)
    else
        timer.Simple(1, function()
            ply.jailBanned = false
            if player_isbanned( ply ) then
                local banInfo = GJailBan.sql_baninfo(ply:SteamID())
                GJailBan.banAction(ply, tonumber(banInfo.time),tonumber(banInfo.unbantime), banInfo.reason) 
            end
        end)
    end
end

hook.Add( "Initialize", "CheckJailban", tables_exist)
hook.Add( "Initialize", "LoadJailbans", GJailBan.refreshBansInMemory)
hook.Add( "PlayerSpawn", "JailbanPlayerCheck", checkJailBan)

