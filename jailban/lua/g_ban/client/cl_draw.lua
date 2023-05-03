local function RespX(x)
	return x/1920 * ScrW()
end
local function RespY(y)
	return y/1080 * ScrH()
end

local function formatTime(time)
    local formatedTime = string.FormattedTime( time)
    local hours = formatedTime.h % 24
    local days = (formatedTime.h - hours) / 24
    
    return  days .. GJailBan.getPhrase("gjailban.client.d") .. string.format("%02d", hours) .. "h " .. string.format("%02d", formatedTime.m) .. "m " .. string.format("%02d", formatedTime.s) .. "sec"
end

surface.CreateFont( "CalibriResp", {
	font		= "Calibri",
	size		= RespY(30),
	weight		= 500,
	antialias = true,
	extended = true,
} )

surface.CreateFont( "Trebuchet18Bold", {
	font		= "Trebuchet",
	size		= 20,
	weight		= 700,
	antialias = true,
	extended = true,
} )


GJailBan.color_background_black = Color(20,20,20,220)
GJailBan.color_black = Color(20,20,20,255)
GJailBan.color_white = Color(255,255,255,255)
GJailBan.color_green = Color(20,200,20,255)
GJailBan.color_text_red = Color(255,20,20)
GJailBan.color_text_reason = Color(255,255,255)

local blur = Material( "pp/blurscreen" )
local function BlurMenu( panel, alpha )
    -- Its a scientifically proven fact that blur improves a script
    local x, y = panel:LocalToScreen( 0, 0 )

    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetMaterial( blur )

    for i = 1, 5 do
        blur:SetFloat( "$blur", ( i / 4 ) * 4 )
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
    end
end 


GJailBan.drawBox = function(p1, p2)
    local origin = p1
    local max = p2 - p1
    
    hook.Add( "PostDrawTranslucentRenderables", "GJailbanBox", function()  
        render.SetColorMaterial() -- white material for easy coloring
    
        cam.IgnoreZ( true ) -- makes next draw calls ignore depth and draw on top
        render.DrawBox( origin, Angle(0,0,0), Vector(0,0,0), max, Color( 255, 255, 255,50 ) )
        render.DrawWireframeBox( origin, Angle(0,0,0), Vector(0,0,0), max, Color(34, 120, 24), false )
        cam.IgnoreZ( false ) -- disables previous call
    end )
end

GJailBan.unDrawBox = function()
    hook.Remove("PostDrawTranslucentRenderables", "GJailbanBox")
end

GJailBan.drawBannedTextBox = function()
    if IsValid(GJailBan.BannedTextFrame) then return end
    GJailBan.BannedTextFrame = vgui.Create("DFrame")
    GJailBan.BannedTextFrame:SetPos(ScrW()/2-RespX(300), ScrH()-RespY(200))
    GJailBan.BannedTextFrame:SetSize(RespX(600),RespY(150))
    GJailBan.BannedTextFrame:SetTitle("")
    if not GJailBan.config.allowedToCloseInfo then GJailBan.BannedTextFrame:ShowCloseButton(false) end
    function GJailBan.BannedTextFrame:Paint(w,h)
        draw.RoundedBox(10, 0, 0, w, h, GJailBan.color_background_black)
        draw.SimpleText(GJailBan.getPhrase("gjailban.client.youarebanned"), "CalibriResp", w/2, RespY(20), GJailBan.color_text_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(LocalPlayer():GetNWString("jailbanReason", ""), "CalibriResp", w/2, RespY(60), GJailBan.color_text_reason, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        if LocalPlayer():GetNWInt("jailbanTimeleft", -1) == -1 then
            draw.SimpleText(GJailBan.getPhrase("gjailban.client.permaban"), "CalibriResp", w/2, RespY(100), GJailBan.color_text_reason, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        else
            draw.SimpleText(GJailBan.getPhrase("gjailban.client.banlength") .. formatTime(LocalPlayer():GetNWInt("jailbanTimeleft")), "CalibriResp", w/2, RespY(100), GJailBan.color_text_reason, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end        
    end
end

local function refreshMenuPanel()
    GJailBan.JailbanMenu.scrollPanel:Clear()

    for k, banInfo in ipairs(GJailBan.currentBans) do
        local bantime = banInfo.time
        local unbantime = banInfo.unbantime
        local bannedPly = player.GetBySteamID64( banInfo.steamid64 )
        local name = tostring(banInfo.steamid64)
        if bannedPly then name = bannedPly:GetName() .. " : " .. name end

        local plyPanel = GJailBan.JailbanMenu.scrollPanel:Add( "DPanel" )
        plyPanel:SetHeight(70)
        plyPanel:Dock( TOP )
        plyPanel:DockMargin( 0, 0, 0, 5 )
        local smoothed_width = (RespY(800)-160)*(unbantime-os.time())/(unbantime-bantime)
        function plyPanel:Paint(w,h)
            draw.RoundedBox(5, 0, 0, w, h, GJailBan.color_background_black)
            draw.SimpleText(name, "Trebuchet24", 80, 10, GJailBan.color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.RoundedBox(3, 80, h-30, RespY(800)-160, 20, GJailBan.color_white)
            if bantime == unbantime then
                draw.RoundedBox(3, 80, h-30, RespY(800)-160, 20, GJailBan.color_green)
                draw.SimpleText(GJailBan.getPhrase("gjailban.client.permabanlist"), "Trebuchet18Bold",w/2, h-20, GJailBan.color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                smoothed_width = Lerp(2 * FrameTime(), smoothed_width, (RespY(800)-160)*(unbantime-os.time())/(unbantime-bantime))
                draw.RoundedBox(3, 80, h-30,smoothed_width , 20, GJailBan.color_green)
                draw.SimpleText(GJailBan.getPhrase("gjailban.client.banlength") .. formatTime(unbantime-os.time()), "Trebuchet18Bold",w/2, h-20, GJailBan.color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        plyPanel:SetTooltip(banInfo.reason)

        local plyAvatar = vgui.Create("AvatarImage", plyPanel)
        plyAvatar:SetSize(64,64) -- Must not be Resp !
        plyAvatar:SetPos(3,3) 
        if bannedPly then plyAvatar:SetPlayer(bannedPly, 64) end

        if ULib.ucl.query(LocalPlayer(), "ulx unjailban") then
            local unbanButton = vgui.Create("DButton", plyPanel)
            unbanButton:SetText(GJailBan.getPhrase("gjailban.client.unbanaction"))
            unbanButton:SetPos(RespX(800)-RespX(200),RespY(10))
            unbanButton:SetSize(RespX(150),RespY(20))
            function unbanButton:DoClick()
                RunConsoleCommand("ulx", "unjailban", util.SteamIDFrom64(banInfo.steamid64))
            end
        end
        
    end
end

GJailBan.drawJailbanMenu = function()
    if IsValid(GJailBan.JailbanMenu) then return end
    GJailBan.JailbanMenu = vgui.Create("DFrame")
    GJailBan.JailbanMenu:SetSize(RespX(800),RespY(800))
    GJailBan.JailbanMenu:Center()
    GJailBan.JailbanMenu:SetTitle(GJailBan.getPhrase("gjailban.client.menutitle"))
    GJailBan.JailbanMenu:SetBackgroundBlur( true )
    GJailBan.JailbanMenu:MakePopup()
    function GJailBan.JailbanMenu:Paint(w,h)
        BlurMenu(self,255)
    end

    GJailBan.JailbanMenu.scrollPanel = vgui.Create( "DScrollPanel", GJailBan.JailbanMenu )
    GJailBan.JailbanMenu.scrollPanel:Dock( FILL )

    refreshMenuPanel()
    
end

net.Receive("gjailban.banned", function()
    local com = net.ReadString()
    if com == "draw" then
        local p1 = net.ReadVector()
        local p2 = net.ReadVector()
        GJailBan.drawBox(p1, p2)
    elseif com == "undraw" then
        GJailBan.unDrawBox()
    elseif com == "drawText" then
        timer.Simple(0, GJailBan.drawBannedTextBox)
    elseif com == "undrawText" then
        if IsValid(GJailBan.BannedTextFrame) then GJailBan.BannedTextFrame:Close() end
    else
    end
end)

net.Receive("gjailban.menu", function()
    local com = net.ReadString()
    if com == "open" then
        GJailBan.currentBans = net.ReadTable()
        GJailBan.drawJailbanMenu()
    elseif com == "update" then
        GJailBan.currentBans = net.ReadTable()
        if IsValid(GJailBan.JailbanMenu) then refreshMenuPanel() end
    else
    end
end)

