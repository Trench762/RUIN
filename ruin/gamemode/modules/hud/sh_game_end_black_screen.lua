if SERVER then 
    util.AddNetworkString("Toggle Game End Curtain")
    hook.Add("PlayerDeath", "RUIN Toggle Game End Curtain On Death", function(ply, inflictor, attacker)
        net.Start("Toggle Game End Curtain")
        net.WriteUInt(1, 3)
        net.Send(ply)
    end)
end

if CLIENT then
    local ply = LocalPlayer()

    local gameEndCases = {
        [1] = "death",      -- Death: Fade time = 0.0
        [2] = "extraction", -- Extraction: Fade time = 0.5
    }
        
    net.Receive("Toggle Game End Curtain", function()
        local gameEndCase = gameEndCases[net.ReadUInt(3)]

        if gameEndCase == "death" then
            ply:ConCommand( "fadeout 0.0" )
        elseif gameEndCase == "extraction" then
            ply:ConCommand( "fadeout 0.5" )
        end
    end)
end
