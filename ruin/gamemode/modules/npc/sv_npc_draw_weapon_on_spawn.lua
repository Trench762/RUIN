-- This is important because default weapons are replaced visually by small_features/sh_reskin_weapons
-- therefore, default weapons must be hidden, though sh_reskin_weapons attempts to do this there is a special case with 
-- metro police where their pistol may flicker in for a frame when they draw it upon being woken, giving away their positions.
-- Forcing them to start with their weapon drawn solves this issue.

hook.Add("OnEntityCreated", "RUIN AI Draw Weapon On Spawn", function(ent)
    if !IsValid(ent) or !ent:IsNPC() or ent:IsPlayer() then return end
    if ent:GetClass() != "npc_metropolice" then return end
    
    ent:SetKeyValue( "weapondrawn", 1 )
end)