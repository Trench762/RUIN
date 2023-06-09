local grenades = {}

local material = Material( "ruin/hud/warning_holo_01" )
hook.Add( "PostDrawTranslucentRenderables", "RUIN Draw Explosive Warnings", function()
    local colorAlpha = math.sin(CurTime() * 16) * 5
    for k, v in ipairs(grenades) do
        if(!IsValid(v) or ( Entity(1):GetPos():DistToSqr(v:GetPos()) > 78400 ) or (Entity(1):Health() <= 0) ) then continue end
        local color = v:GetColor()
        color.a = colorAlpha
        v:SetColor(color)
        render.SetMaterial( material )
        render.DrawSprite( v:GetPos(), 28, 28, color )
    end
end )

hook.Add("OnEntityCreated", "RUIN Explosive Warning Cache Objects", function(entity)
    if entity:GetClass() == "npc_grenade_frag" then
        if !IsValid(entity) then return end
        table.insert(grenades, entity)
    end
end)

local garbageCollectNextThink = CurTime() + 10

hook.Add("Think", "RUIN Explosive Warning Garbage Collect", function()
    if ( CurTime() < garbageCollectNextThink ) then return end
    garbageCollectNextThink = CurTime() + 10
    
    local dumpTable = {}

    for k, v in ipairs(grenades) do
        if IsValid(v) then 
            table.insert( dumpTable, v ) 
        end
    end

    grenades = dumpTable
end)

hook.Add("PostCleanupMap", "RUIN Explosive Warning Clear Cache", function()
    grenades = {}
end)
