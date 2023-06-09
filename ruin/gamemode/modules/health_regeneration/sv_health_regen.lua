-- Health screen effects are done in a different module: "effects/cl_screen_effects".
local ply = Entity(1)
local regenCoolDown = 0
ply.justTookDamage = false 

hook.Add("EntityTakeDamage", "RUIN Health Regen Take Damage Regen Delay", function(ent)
    if !IsValid(ent) or !ent:IsPlayer() then return end

    ply = ent 
    ply.justTookDamage = true 

    timer.Create("RUIN hp regen delay", 3, 1, function()
        ply.justTookDamage = false
    end)
end)

hook.Add("Think", "RUIN Health Regen", function()
    if !IsValid(ply) then return end
    if !ply:Alive() then return end
    if ply:GetPlayerAbilities() == "Technomancer" then return end 
    if ply.justTookDamage then return end  
    if regenCoolDown >= CurTime() then return end
    
    -- 7.5 hp/sec.
    regenCoolDown = CurTime() + 0.05 
    ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + 3))
end)



