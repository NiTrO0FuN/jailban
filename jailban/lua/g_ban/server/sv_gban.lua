util.AddNetworkString("gjailban.banned")
util.AddNetworkString("gjailban.menu")

GJailBan.points = {}

GJailBan.collisionSounds = {"physics/glass/glass_sheet_step1.wav",
                            "physics/glass/glass_sheet_step2.wav",
                            "physics/glass/glass_sheet_step3.wav",
                            "physics/glass/glass_sheet_step4.wav"}


local dataToRead = file.Read("g_jailban.json")

GJailBan.points = dataToRead and util.JSONToTable(dataToRead) or {}

GJailBan.resetPoints = function()
    GJailBan.points = {}
    return 0
end

GJailBan.addPoint = function(pointToAdd)
    if #GJailBan.points <2 then
        table.insert(GJailBan.points, pointToAdd)
    end
    return #GJailBan.points  
end

GJailBan.savePoints = function()
    if #GJailBan.points ~= 2 then return end
    GJailBan.recomputeMinMax()
    local dataToSave = util.TableToJSON(GJailBan.points)
    file.Write("g_jailban.json", dataToSave)
end

GJailBan.isDefined = function()
    return #GJailBan.points == 2 
end

GJailBan.drawBox = function(ply)
    if #GJailBan.points < 2 then return end
    net.Start("gjailban.banned")
        net.WriteString("draw")
        net.WriteVector(GJailBan.points[1])
        net.WriteVector(GJailBan.points[2])
    net.Send(ply)
end

GJailBan.recomputeMinMax = function()
    GJailBan.minx = math.min(GJailBan.points[1].x,GJailBan.points[2].x)
    GJailBan.miny = math.min(GJailBan.points[1].y,GJailBan.points[2].y)
    GJailBan.minz = math.min(GJailBan.points[1].z,GJailBan.points[2].z)

    GJailBan.maxx = math.max(GJailBan.points[1].x,GJailBan.points[2].x)
    GJailBan.maxy = math.max(GJailBan.points[1].y,GJailBan.points[2].y)
    GJailBan.maxz = math.max(GJailBan.points[1].z,GJailBan.points[2].z)
end

GJailBan.jailban = function(admin, ply, time, reason)
    if not IsValid(ply) then return end
    GJailBan.jailbanid(admin, ply:SteamID(), time, reason)
end

GJailBan.jailbanid = function(admin, steamid, time, reason)
    if not GJailBan.isDefined() then MsgAll(GJailBan.getPhrase("gjailban.server.nojail")) end
    local btime = os.time()
    local unbantime = btime + time * 60
    local r = GJailBan.getPhrase("gjailban.server.noreason")
    if reason and reason ~= "" then r = reason end
    GJailBan.sql_ban_player(steamid, btime, unbantime, r)

    local ply = player.GetBySteamID(steamid)
    if not IsValid(ply) then return end
    GJailBan.banAction(ply, btime,unbantime, r)
    GJailBan.refreshBansInMemory()
end


GJailBan.unjailban = function(steamid)
    GJailBan.sql_unban_player(steamid)
    GJailBan.unbanAction(steamid)
    GJailBan.refreshBansInMemory()
end

GJailBan.banAction = function(ply, bantime, unbantime, reason)
    if not GJailBan.isDefined() then return end

    if bantime ~= unbantime and os.time() > unbantime then
         GJailBan.unjailban(ply:SteamID())
         return 
    end
    ply.jailBanned = true
    ply:SetNWBool("jailBanned", true)
    ply:SetNWInt("jailbanTimeleft", unbantime - bantime == 0 and -1 or unbantime - os.time())
    ply:SetNWString("jailbanReason", reason)

    local sx = math.random(GJailBan.minx, GJailBan.maxx)
    local sy = math.random(GJailBan.miny, GJailBan.maxy)

    ply.jailbanSpawnPos = Vector(sx, sy, GJailBan.minz + 1)

    GJailBan.banRespawn(ply)
end

GJailBan.unbanAction = function(steamid)
    local ply = player.GetBySteamID(steamid)
    if not IsValid(ply) then return end
    if ply.jailBanned then
        ply.jailBanned = false
        ply:SetNWBool("jailBanned", false)
        ply:StripWeapons() -- Remove given weapon if any
        ply:Spawn()
    end

    net.Start("gjailban.banned")
        net.WriteString("undrawText")
    net.Send(ply)
end

GJailBan.banRespawn = function(ply)
    if not GJailBan.isDefined() then return end

    if DarkRP then ply:changeTeam(TEAM_CITIZEN, true, true) end 

    timer.Simple(0, function() --Because it could be overriden
        ply:ExitVehicle()
        ply:StripWeapons() -- Remove weapons
        if #GJailBan.config.weapon > 0 then
            ply:Give(GJailBan.config.weapon[math.random(#GJailBan.config.weapon)])
            ply:GetActiveWeapon():SetClip1(GJailBan.config.ammonb)
        end
        print(ply.jailbanSpawnPos)
        ply:SetPos(ply.jailbanSpawnPos) -- TP to the jail
        ply:DropToFloor()
        ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    end)

    net.Start("gjailban.banned")
        net.WriteString("drawText")
    net.Send(ply)
        
end

GJailBan.refreshBansInMemory = function()
    GJailBan.currentBans = GJailBan.currentBans or {}
    local bans = GJailBan.sql_allbaninfo()
    if bans then GJailBan.currentBans = bans 
    else  GJailBan.currentBans = {} end
    for k, ban in pairs(GJailBan.currentBans) do
        if ban.time ~= ban.unbantime and os.time() - ban.unbantime > 0 then
              GJailBan.unjailban(util.SteamIDFrom64(ban.steamid64)) -- careful can cause infinite loop
            return 
       end
    end
    for k,v in ipairs(player.GetHumans()) do
        if not ULib.ucl.query(v, "ulx jailban", true) then continue end
        net.Start("gjailban.menu")
            net.WriteString("update")
            net.WriteTable(GJailBan.currentBans)
        net.Send(v)
    end
    
end

if GJailBan.isDefined() then GJailBan.recomputeMinMax() end

hook.Add("Move", "JailbanPrisonBox", function(ply, mv)

    if ply.jailBanned then  
        -- Get some variables for easy access
        local ang = mv:GetMoveAngles()
        local pos = mv:GetOrigin()
        local oldpos = Vector(pos.x,pos.y,pos.z)

        local collision = false

        pos.x = math.Clamp(pos.x, GJailBan.minx, GJailBan.maxx)
        pos.y = math.Clamp(pos.y, GJailBan.miny, GJailBan.maxy)
        pos.z = math.Clamp(pos.z, GJailBan.minz, GJailBan.maxz)

        oldpos.z = pos.z
            
        if oldpos~=pos then
            if not ply.jailBannedsound then
                ply.jailBannedsound = true
                ply:EmitSound(GJailBan.collisionSounds[math.random(#GJailBan.collisionSounds)])
                timer.Simple(1, function() ply.jailBannedsound = false end)
            end
         end

        -- Save the calculations back into the origin
        mv:SetOrigin( pos )

        -- Don't do the default
        return false
    end
end)

-- Menu to manage bans
hook.Add("PlayerSay","JailbanMenu",function(sender, text)
    if ULib.ucl.query(sender, "ulx jailban", true) then
        if text == GJailBan.config.menucommand then
            net.Start("gjailban.menu")
                net.WriteString("open")
                net.WriteTable(GJailBan.currentBans)
            net.Send(sender)
            return ""
        end
    end
end)

-- Disallow spawing props and dealing damages when jailbanned
hook.Add("PlayerSpawnProp", "JailbanAntiprops", function( ply, model)
    if ply.jailBanned then return false end
end)

hook.Add("PlayerShouldTakeDamage", "JailbanAntidamage", function(target, attacker)
    if attacker.jailBanned and not target.jailBanned then return false end
end)

hook.Add("PlayerCanHearPlayersVoice", "JailbanTalk", function(listener, talker)
    if listener.jailBanned == not talker.jailBanned and not GJailBan.config.allowedToSpeak then return false end
end)

hook.Add("PlayerCanSeePlayersChat", "JailbanChat", function(text, teamOnly,listener, speaker)
    if IsValid(speaker) and not GJailBan.config.allowedToSpeak and listener.jailBanned == not speaker.jailBanned  then return false end
end)

-- DarkRP
local function noIfJailBanned(ply) if ply.jailBanned then return false end end

timer.Simple(0,function()
    if DarkRP then
        hook.Add("canChangeJob", "JailbanBlockJob", noIfJailBanned)
        hook.Add("canChatCommand", "JailbanBlockCommands", noIfJailBanned)
        hook.Add("canDropWeapon", "JailbanBlockDrop", noIfJailBanned)
        hook.Add("canDropWeapon", "JailbanBlockDrop", noIfJailBanned)
        hook.Add("canDemote", "JailbanBlockDemote", noIfJailBanned)
    end
end)

--
hook.Add("Tick","JailbanThink",function()
    for k,v in ipairs(player.GetHumans()) do
        if not v.jailBanned then continue end
        if v:GetNWInt("jailbanTimeleft")~=-1 then
            local newBanTime = v:GetNWInt("jailbanTimeleft")-FrameTime()
            newBanTime = math.max(0,newBanTime)
            v:SetNWInt("jailbanTimeleft",newBanTime)
            if newBanTime==0 then GJailBan.unjailban(v:SteamID()) end
        end
    end
end)