ruinNpcViewCull = ruinNpcViewCull
local function createNpcViewCull()
    if IsValid(ruinNpcViewCull) then ruinNpcViewCull:Remove() end
    ruinNpcViewCull = ents.Create( "ruin_npc_view_cull" )
    ruinNpcViewCull:Spawn()
end

hook.Add("Think", "RUIN Set NPC View Cull Position", function()
    if !IsValid(Entity(1)) or !IsValid(ruinNpcViewCull) then createNpcViewCull() return end
    ruinNpcViewCull:SetPos( Entity(1):GetPos() + Vector(0,0,-72) )
end)