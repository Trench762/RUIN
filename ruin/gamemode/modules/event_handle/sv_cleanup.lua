local restartDelay = 0

function RUIN.CleanUp(ply, force)
    if force then
        -- Instead of restartDelay, Delay here is controlled in ruin_extraction_volume.lua 
        -- by freezing the player for 4 seconds, thereby blocking input.
        net.Start("RUIN Notify Player Draw Holstered Weapon Post Death", false)
        net.Broadcast()
        timer.Simple(0, function()
            game.CleanUpMap( false, { "env_fire", "entityflame", "_firesmoke" } )
            ply:Spawn()
            ply:StripWeapons()
            ply:Give("weapon_pistol")
            ply:SetHealth(ply:GetMaxHealth())
        end)
    else
        if(ply:Alive()) then return end
        if(restartDelay > CurTime()) then return end
        net.Start("RUIN Notify Player Draw Holstered Weapon Post Death", false)
        net.Broadcast()
        timer.Simple(0, function() -- I'm really not sure why but if this isn't in a timer, the game crashes. 
            game.CleanUpMap( false, { "env_fire", "entityflame", "_firesmoke" } )
            ply:Spawn()
            ply:StripWeapons()
            ply:Give("weapon_pistol")
            ply:SetHealth(ply:GetMaxHealth())
        end)
    end
end

hook.Add("KeyPress", "RUIN Reset Level", function(ply, key)
    if RUIN.extracted then 
        RUIN.CleanUp(ply, true)
    else
        RUIN.CleanUp(ply)
    end
end)

hook.Add("Think", "RUIN Prevent Premature Cleanup", function()
    if !IsValid(Entity(1)) then return end
    if( Entity(1):Health() <= 0 ) then return end
    restartDelay = CurTime() + .75
end)

hook.Add("PlayerDeathThink", "RUIN Prevent Default Respawn", function()
    return false
end)




