if SERVER then
    util.AddNetworkString("RUIN Play Spawn Sound")
    
    hook.Add("PlayerSpawn", "RUIN Notify Player Play Spawn Sound On Spawn", function()
        net.Start("RUIN Play Spawn Sound")
        net.Broadcast()
    end)
end


if CLIENT then
    local ply = LocalPlayer()
    local w, h = ScrW(), ScrH()
    local glitchEffectColor = Color(0,0,0,255)
    local glitchEffectAlpha = 255
    local glitchMaterial = Material("ruin/hud/respawn_glitch_screen/1.png")   
    local nextMatChange = CurTime()
    local currentMat = 1
    
    local glitchMaterials = {
        [1] = Material("ruin/hud/respawn_glitch_screen/1.png"),
        [2] = Material("ruin/hud/respawn_glitch_screen/2.png"),
        [3] = Material("ruin/hud/respawn_glitch_screen/3.png"),
        [4] = Material("ruin/hud/respawn_glitch_screen/4.png"),
        [5] = Material("ruin/hud/respawn_glitch_screen/5.png"),
        [6] = Material("ruin/hud/respawn_glitch_screen/6.png"),
        [7] = Material("ruin/hud/respawn_glitch_screen/7.png"),
        [8] = Material("ruin/hud/respawn_glitch_screen/8.png"),
        [9] = Material("ruin/hud/respawn_glitch_screen/9.png"),
    }

    net.Receive("RUIN Play Spawn Sound", function()
        if LocalPlayer().inMainMenu then return end
        surface.PlaySound("ruin/effects/ui/glitch_02.ogg")

        glitchEffectAlpha = 255
        timer.Create("RUIN Player Spawn Set Glitch Alpha", .01, 35, function()
            glitchEffectAlpha = math.max(0, glitchEffectAlpha - 7.3)
        end)
    end)

    hook.Add("HUDPaint", "RUIN Draw Spawn Glitch Screen Effect", function()
        if glitchEffectAlpha == 0 then return end
        if ply.inMainMenu then return end
        if ply.escMenuOpen then return end

        if nextMatChange < CurTime() then 
            nextMatChange = CurTime() + .05 // 20 fps
            glitchMaterial = glitchMaterials[currentMat]
            currentMat = currentMat == 9 and 1 or currentMat + 1
        end

        glitchEffectColor.a = glitchEffectAlpha
        surface.SetDrawColor(glitchEffectColor)
        surface.SetMaterial(glitchMaterial)
        surface.DrawTexturedRect(0,0,w,h)
    end)
end
