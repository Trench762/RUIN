
if SERVER then
    util.AddNetworkString("RUIN HUD Notify Client Player Spawn")
    util.AddNetworkString("RUIN HUD Notify Client Player Died")
    util.AddNetworkString("RUIN HUD Detect Player Equip Weapon")

    hook.Add( "WeaponEquip", "RUIN HUD Detect Player Equip Weapon", function( weapon, ply )
        net.Start("RUIN HUD Detect Player Equip Weapon")
        net.Send(ply)
    end )

    hook.Add("PlayerSpawn", "RUIN Detect Player Spawn", function(ply, transition)
        net.Start("RUIN HUD Notify Client Player Spawn")
        net.Send(ply)
    end)

    hook.Add("PlayerDeath", "RUIN Detect Player Death", function(ply, transition)
        net.Start("RUIN HUD Notify Client Player Died")
        net.Send(ply)
    end)
end

if CLIENT then   
    local ply = LocalPlayer()
    local HUDAlphaMult = 0
    local scrW, scrH = ScrW(), ScrH()
    local white = Color(255, 255, 255)
    local weaponSelectColorActive = Color(200, 200, 200)
    local weaponSelectColorBackup = Color(80, 80, 80, 80)
    local backGroundColor = Color(0,0,0,150)
    local healthColor = Color(54, 230, 112)
    local colorUnavailable = Color(255,255,255,40)
    local colorRechargeBackground = Color(255,255,255,5)
    local color = Color(255,255,255)
    local fullyTransparent = Color(0,0,0,0)
    local weapon
    local weaponAmmoCount = 0
    local weaponMaxAmmo = 0
    local supportLine = Material("icons/supporting_line_with_tops.png", "mip smooth")
    local supportLineColor = Color(0,0,0,153)
    local arenaScoreBackground = Material("icons/arena_score_background.png", "mip smooth")
    local arenaScoreSkull = Material("icons/kill_count_skull.png", "mip smooth")
    local weaponIcons = {
        ["weapon_pistol"] = Material("icons/CXL-3.png", "mip smooth"),
        ["weapon_shotgun"] = Material("icons/GR-50.png", "mip smooth"),
        ["weapon_smg1"] = Material("icons/STNG-R.png", "mip smooth"),
        ["weapon_ar2"] = Material("icons/SXV-3.png", "mip smooth")
    }
    local activeWeaponIcon
    local backupWeaponIcon
    local skullScale = 0
    local weaponSelectHudAlphaMult = 0
    local SHIFTStart 
    local SHIFTEnd 
    local SHIFTCurrent 
    local fStart 
    local fEnd 
    local fCurrent 
    local QStart 
    local QEnd 
    local QCurrent
    local arenaMode = false
    local justSpawned = false
    ply.arenaKills = 0

    net.Receive("Update Player Arena Kills", function()
        ply.arenaKills = net.ReadUInt(12)
        hook.Run("RUIN HUD NPC Died")
    end) 

    hook.Add("RUIN HUD NPC Died", "RUIN HUD NPC Died", function()
        skullScale = 1
    end)

    net.Receive("RUIN HUD Notify Client Player Spawn", function()
        HUDAlphaMult = 0
        -- 0.2 Seconds is how long it takes for the death screen HUD to go away, so we wanna wait until its fully gone to start fading the HUD
        -- and also give some extra time so the hitch on map reset doesnt cause death screen to overlay on top of the HUD.
        timer.Simple(0.5, function() 
            timer.Create("RUIN HUD Increment Alpha", .01 ,50,function()
                HUDAlphaMult = HUDAlphaMult + 0.02
            end)
        end)

        justSpawned = true 
        timer.Simple(.5, function()
            justSpawned = false
        end)
    end)

    net.Receive("RUIN HUD Notify Client Player Died", function()
        weaponSelectHudAlphaMult = 0
    end)

    surface.CreateFont("RUIN Main HUD Font" , { font = "Kenney Future Square", size = ScreenScale(20), weight = 0, blursize = 0; scanlines = 0, shadow = false, additive = true, })

    hook.Add( "OnScreenSizeChanged", "RUIN MAIN HUD UI Rebuild Screen Sizes", function( oldWidth, oldHeight )
		scrW, scrH = ScrW(), ScrH()
        
        surface.CreateFont("RUIN Main HUD Font" , { font = "Kenney Future Square", size = ScreenScale(20), weight = 0, blursize = 0; scanlines = 0, shadow = false, additive = true, })
    end )

    hook.Add( "HUDPaint", "RUIN Main HUD", function()
        -- This needs to be first otherwise if esc menu is open right as player spawns, alphas wont be set up correctly.
        if HUDAlphaMult < 1 then
            white = Color(255, 255, 255, 255 * HUDAlphaMult )
            backGroundColor = Color(0,0,0,150 * HUDAlphaMult)
            healthColor = Color(54, 230, 112, 255 * HUDAlphaMult)
            colorUnavailable = Color(255,255,255,40 * HUDAlphaMult)
            colorRechargeBackground = Color(255,255,255,5 * HUDAlphaMult)
            supportLineColor = Color(0,0,0,153 * HUDAlphaMult)
        end

        if !IsValid(ply) then return end
        if !ply:Alive() then return end
        if !IsValid(ply:GetActiveWeapon()) then return end
        if !ply.options then return end
        if ply.options.enableHud == false then return end
        if RUIN.extracted then return end
        if ply.inMainMenu then return end 
        if ply.escMenuOpen then return end
        if ply:getDebuggingMenuCamera() then return end
        
        weapon = ply:GetActiveWeapon()
        weaponAmmoCount = weapon:Clip1()
        if weapon:GetClass() == "weapon_shotgun" then
            weaponMaxAmmo = 3
        else
            weaponMaxAmmo = weapon:GetMaxClip1()
        end

        -----------------------------------------------
        --ARC DERENDER GUARD---------------------------
        -----------------------------------------------
        -- draw.Arc Params = ( x, y, radius, width, minAng, maxAng, resolution, color ) resolution can be static and will scale since its just subdivisions.
        surface.SetDrawColor( fullyTransparent )
        draw.Arc( 0, 0, 0, 0, 0, 0, 1 ) // Throw away arc needed to solve bug with first arc de-rendering when next to halos (Couldn't find better fix)

        -----------------------------------------------
        --HEALTH BAR-----------------------------------
        -----------------------------------------------

        local fraction = math.Remap( ply:Health(), 0, ply:GetMaxHealth(), 1, 0 ) 
        draw.Arc( scrW *.4985, scrH * .799, scrH * .053, scrH * .008, 180, 269, 1, backGroundColor ) -- Health Arc Background
        draw.Arc( scrW *.4975, scrH * .8, scrH * .053, scrH * .004, 180, 268 - math.Round((90 * fraction)), 1, healthColor ) // health Arc

        -----------------------------------------------
        --AMMO COUNT-----------------------------------
        -----------------------------------------------
        
        local fraction = math.Remap( weaponAmmoCount, 0, weaponMaxAmmo, 1, 0 ) 
        draw.Arc( scrW*.499, scrH * .799, scrH * .053, scrH * .008, 90, 180, 1, backGroundColor ) -- Ammo Arc Background
        draw.Arc( scrW*.5, scrH * .8, scrH * .053, scrH * .004, 90 + math.Round((90 * fraction)), 180, 1, white ) -- Ammo Arc

        -----------------------------------------------
        --ABILITIES------------------------------------
        -----------------------------------------------

        -------------SHIFT Ability---------------------
        surface.SetDrawColor(supportLineColor)
        surface.SetMaterial(supportLine)
        surface.DrawTexturedRect(scrW * .35, scrH * .69, scrW * .3, scrW * .3)

        if(ply:CanAbilityShift()) then
            color = white
        else
            color = colorUnavailable
        end 

        surface.SetDrawColor(color)
        surface.SetMaterial(ply:GetAbilityShiftIcon() )
        surface.DrawTexturedRect(scrW * .485, scrH * .925, scrW * .03, scrW * .03)
        
        SHIFTStart = ply:GetAbilityShiftStart()
        SHIFTEnd = ply:GetAbilityShiftEnd()
        SHIFTCurrent = math.Remap(CurTime(),SHIFTStart,SHIFTEnd,0,1)

        if SHIFTCurrent > 0 and SHIFTCurrent <= 1 then 
            draw.RoundedBox( 0, scrW * .488 , scrH * .915, scrW * .025, scrH * .0035, colorRechargeBackground )
            draw.RoundedBox( 0, scrW * .488 , scrH * .915, scrW * .025 * SHIFTCurrent, scrH * .0035, colorUnavailable )
        end

        -------------F Ability-------------------------
        if(ply:CanAbilityF()) then
            color = white
        else
            color = colorUnavailable
        end 

        surface.SetDrawColor(color)
        surface.SetMaterial(ply:GetAbilityFIcon() )
        surface.DrawTexturedRect(scrW * .559, scrH * .925, scrW * .03, scrW * .03)

        fStart = ply:GetAbilityFStart()
        fEnd = ply:GetAbilityFEnd()
        fCurrent = math.Remap(CurTime(),fStart,fEnd,0,1)
    
        if fCurrent > 0 and fCurrent <= 1 then 
            draw.RoundedBox( 0, scrW * .561 , scrH * .915, scrW * .025, scrH * .0035, colorRechargeBackground )
            draw.RoundedBox( 0, scrW * .561 , scrH * .915, scrW * .025 * fCurrent, scrH * .0035, colorUnavailable )
        end

        -------------Q Ability-------------------------
        if(ply:CanAbilityQ()) then
            color = white
        else
            color = colorUnavailable
        end 

        surface.SetDrawColor(color)
        surface.SetMaterial(ply:GetAbilityQIcon() )
        surface.DrawTexturedRect(scrW * .412, scrH * .925, scrW * .03, scrW * .03)

        QStart = ply:GetAbilityQStart()
        QEnd = ply:GetAbilityQEnd()
        QCurrent = math.Remap(CurTime(),QStart,QEnd,0,1)

        if QCurrent > 0 and QCurrent <= 1 then 
            draw.RoundedBox( 0, scrW * .4145 , scrH * .915, scrW * .025, scrH * .0035, colorRechargeBackground )
            draw.RoundedBox( 0, scrW * .4145 , scrH * .915, scrW * .025 * QCurrent, scrH * .0035, colorUnavailable )
        end

        -----------------------------------------------
        --ARENA SCORE----------------------------------
        -----------------------------------------------
        if tonumber(RUIN.mapSettings["mode"]) == 1 then 
            surface.SetDrawColor(backGroundColor)
            surface.SetMaterial(arenaScoreBackground)
            surface.DrawTexturedRect(scrW * .85, scrH * -.075, scrW * .15, scrW * .15)
    
            skullScale = math.Clamp(skullScale - FrameTime(), 0, 99)
            surface.SetDrawColor(white)
            surface.SetMaterial(arenaScoreSkull)
            surface.DrawTexturedRectRotated(scrW * .978, scrH * .06, scrW * .04 + (skullScale * 20), scrW * .04 + (skullScale * 20), 0)
            draw.SimpleText( ply.arenaKills, "RUIN Main HUD Font", scrW * .94, scrH * .058, white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
        end
    
        -----------------------------------------------
        --Weapon Switch---------------------------------
        -----------------------------------------------
        if weaponSelectHudAlphaMult >= 0 then 
            activeWeaponIcon = weaponIcons[weapon:GetClass()]
            -- activeWeaponClass() is a custom gamemode function that returns the class of the primary weapon they have.
            backupWeaponIcon = weapon:GetClass() == ply:activeWeaponClass() and weaponIcons["weapon_pistol"] or weaponIcons[ply:activeWeaponClass()] 
    
            weaponSelectColorActive.a = weaponSelectColorActive.a * weaponSelectHudAlphaMult
            surface.SetDrawColor(weaponSelectColorActive)
            surface.SetMaterial(activeWeaponIcon)
            surface.DrawTexturedRect(scrW * 0.435, scrH * 0.8, scrW * .025, scrW * .0125)
            
            -- hasPrimary() is a custom gamemode function that is true if the player has a weapon picked up. (Even if it isn't equipped)
            if !ply:hasPrimary() then return end
            if !backupWeaponIcon then return end
            weaponSelectColorBackup.a = weaponSelectColorBackup.a * weaponSelectHudAlphaMult
            surface.SetDrawColor(weaponSelectColorBackup)
            surface.SetMaterial(backupWeaponIcon)
            surface.DrawTexturedRect(scrW * 0.44, scrH * 0.82, scrW * .025, scrW * .0125)
        end
    end )

    local function setUpWeaponDrawHUD()
        if !IsValid(ply) then return end
        if !IsValid(ply:GetActiveWeapon()) then return end
        if !ply:Alive() then return end
        if justSpawned then return end

        timer.Remove("RUIN weapon switch start disable weapon HUD")
        timer.Remove("RUIN weapon switch fade weapon HUD")
        
        -- Give it second for the game to actually swich the weapons so the render doesn't jolt.
        timer.Simple(.05, function()
            weaponSelectColorActive.a = 200
            weaponSelectColorBackup.a = 80
            weaponSelectHudAlphaMult = 1

            timer.Create("RUIN weapon switch start disable weapon HUD", 3.5, 1, function()
                timer.Create("RUIN weapon switch fade weapon HUD", 0.005, 100, function()
                    weaponSelectHudAlphaMult = weaponSelectHudAlphaMult - 0.01
                end)
            end)
        end)
    end

    hook.Add("KeyPress", "RUIN Hud Detect Switch Weapon", function(ply, key)
        if key != IN_SCORE then return end
        setUpWeaponDrawHUD()
    end)

    net.Receive("RUIN HUD Detect Player Equip Weapon", function()
        setUpWeaponDrawHUD()
    end)
end
