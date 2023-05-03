TOOL.Category = "ULX"
TOOL.Name = "Jailban placer"
TOOL.Command = nil
TOOL.ConfigName = "" 
 
local jailMat = Material("prisoner.png","ignorez")

function  TOOL:Deploy()
    if SERVER then
        if GJailBan.isDefined() then 
            self:SetStage(2) 
            GJailBan.drawBox(self:GetOwner())
        else
            GJailBan.resetPoints()
        end
    end
end
 
function TOOL:Holster()
	if CLIENT then
        GJailBan.unDrawBox()
    end
end

function TOOL:LeftClick( trace )
    if SERVER then
        if not trace.Hit then return end
        local stage = GJailBan.addPoint(trace.HitPos)
        self:SetStage(stage)
        if stage == 2 then
            GJailBan.drawBox(self:GetOwner())
        end
    end
    if CLIENT then
        if self:GetStage() ~= 2 then return true end
    end
end
 
function TOOL:RightClick( trace )
    if SERVER then
        GJailBan.savePoints()
        if GJailBan.isDefined() then self:GetOwner():EmitSound("buttons/weapon_confirm.wav") end
    end
end

function TOOL:Reload( trace )
    if SERVER then
        self:SetStage(GJailBan.resetPoints())
    end
    if CLIENT then
        GJailBan.unDrawBox()
    end
end
 
function TOOL:DrawToolScreen( width, height )
    -- Draw greenish background
    surface.SetDrawColor( Color( 34, 120, 24 ) )
    surface.DrawRect( 0, 0, width, height )
    
    -- Draw white text in the top part
    draw.SimpleText( "Jailban placer", "DermaLarge", width / 2, 50 , Color( 200, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    draw.NoTexture()
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial(jailMat)
    local h = TimedSin(0.5, height/4+30, height/4+45, 0)
    surface.DrawTexturedRect(width/4, h, width/2, height/2)
end

if CLIENT then
    TOOL.Information = {
        {name = "left1", stage = 0},
        {name = "left2", stage = 1},
        {name = "right"},
        {name = "reload"},
    }

    timer.Simple(0, function()
        language.Add("tool.gbantool.name", GJailBan.getPhrase("gjailban.server.toolname"))
        language.Add("tool.gbantool.desc", GJailBan.getPhrase("gjailban.server.tooldesc"))
        language.Add("tool.gbantool.left1", GJailBan.getPhrase("gjailban.server.toolleft1"))
        language.Add("tool.gbantool.left2", GJailBan.getPhrase("gjailban.server.toolleft2"))
        language.Add("tool.gbantool.right", GJailBan.getPhrase("gjailban.server.toolright"))
        language.Add("tool.gbantool.reload", GJailBan.getPhrase("gjailban.server.toolreload"))
    end)
end