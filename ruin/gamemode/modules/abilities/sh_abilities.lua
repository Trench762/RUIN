local colorSelect = Color(255, 255, 255, 165)
local readyToUseSoundVolume = .5
local weaponConversions = {
    ["models/weapons/w_pistol.mdl"] = "models/ruin/weapons/cxl-3.mdl",
    ["models/weapons/w_smg1.mdl"] = "models/ruin/weapons/stng-r.mdl",
    ["models/weapons/w_irifle.mdl"] = "models/ruin/weapons/sxv-3.mdl", 
    ["models/weapons/w_shotgun.mdl"] = "models/ruin/weapons/gr-50.mdl",
}

RUIN.Abilities = {
    Guardian = {
        Color = colorSelect,
        Icon = Material("icons/guardian.png", "mip smooth"),  
        Desc = { "Stoic defender, Impenetrable fortress" },  
        AbilityPassiveName = "Reinforced",
        AbilityPassiveDesc = "+100% Health -10% Speed",
        AbilityShiftName = "Impulse",
        AbilityShiftIcon = Material("icons/rapid_impulse.png", "mip smooth"),
        AbilityShiftDesc = "Violent vacuum pulsewave",
        AbilityFName = "Stun",
        AbilityFIcon = Material("icons/stun.png", "mip smooth"),
        AbilityFDesc = "Throwable stun grenade",
        AbilityQName = "Shield",
        AbilityQIcon = Material("icons/force_shield.png", "mip smooth"),
        AbilityQDesc = "Deployable hardlight generator",
        Speed = 135, -- Default = 150

        OnSpawn = function(p)
            p:SetWalkSpeed(135)
            p:SetSlowWalkSpeed(135)
            p:SetRunSpeed(135)
            
            p:SetMaxHealth(200)
            p:SetHealth(200)
        end,
        
        OnThink = function(p) 
        end,
    
        OnAbilityShift = function(p)
            local cooldown = 8
            local explosionOffset = Vector(0,0,16)
            -- ability conditions
            if not IsValid(p) then return end
            if not p:Alive() then return end
            if p:justSpawned() then return end
            
            
            if p:GetAbilityShiftEnd() > CurTime() then
                p:EmitSound("buttons/combine_button1.wav", 100, 100, .75) -- Not available sound
                return
            end

            p:SetNextAbilityShift(CurTime() + cooldown)

            -- ability code
            hook.Add("EntityTakeDamage", "RUIN Ignore Self Blast Damage", function(e, t)
                if not e.IsPlayer and not e:IsPlayer() then return end
                if t:GetAttacker() ~= e or t:GetInflictor() ~= e or not t:IsExplosionDamage() then return end
                hook.Remove("EntityTakeDamage", "RUIN Ignore Self Blast Damage")

                return true
            end)

            util.BlastDamage(p, p, p:WorldSpaceCenter() + explosionOffset, 160, 128)
            hook.Remove("EntityTakeDamage", "RUIN Ignore Self Blast Damage")
            local t = EffectData()
            t:SetOrigin(p:WorldSpaceCenter())
            t:SetEntity(p)
            util.Effect("ruin_ability_impulse", t)
            util.ScreenShake(p:WorldSpaceCenter(), 8, 100, 1, 128)
            p:EmitSound("ruin/effects/abilities/rapid_impulse_01.ogg")

            for i = 1, 1 do
                local e = ents.Create("prop_physics")
                e:SetModel("models/hunter/misc/sphere075x075.mdl")
                e:SetPos(p:WorldSpaceCenter())
                e:SetAngles(Angle(0, 30 * i, 0))
                e:Spawn()
                e:SetParent(p)
                e:SetRenderMode(RENDERMODE_TRANSCOLOR)
                e:SetColor(Color(255, 255, 255, 50))
                e:SetNotSolid(true)
                e:SetMoveType(MOVETYPE_NONE)
                e:SetModelScale(.1, 0)
                e:SetMaterial("Models/effects/vol_light001")
                e:SetMaterial("models/ruin/shared/glass/glass_01")

                timer.Simple(0, function()
                    if not IsValid(e) then return end
                    e:SetModelScale(40, 1)
                end)

                timer.Simple(.25, function()
                    if not IsValid(e) then return end
                    e:Remove()
                end)
            end
            
            timer.Create("RUIN ability_shift_cooldown", cooldown, 1, function()
                if !p:Alive() then return end
                p:EmitSound("weapons/grenade/tick1.wav", 100, 70, readyToUseSoundVolume) --Ready to use sound
            end)
        end,
        
        OnAbilityF = function(p)
            local cooldown = 8
            -- ability conditions
            if not IsValid(p) then return end
            if not p:Alive() then return end
            if p:justSpawned() then return end

            if p:GetAbilityFEnd() > CurTime() then
                p:EmitSound("buttons/button2.wav", 75, 125, .35) --Not Available Sound

                return
            end

            p:SetNextAbilityF(CurTime() + cooldown)
            -- ability code
            local stunAugment = ents.Create("ruin_ability_stun_augment")
            stunAugment:SetPos(p:GetPos() + Vector(0, 0, 64))
            stunAugment:SetAngles(p:GetAngles())
            stunAugment:Spawn()
            stunAugmentPhys = stunAugment:GetPhysicsObject()
            stunAugment:Activate()
            local trail = util.SpriteTrail(stunAugment, 3, trailColor, false, 20, 5, .15, 1 / (20 + 5) * 0.5, "trails/laser")

            if (stunAugment:GetPhysicsObject():IsValid() and p:IsValid()) then
                stunAugmentPhys:SetVelocityInstantaneous(p:EyeAngles():Forward() * 500)
                stunAugmentPhys:ApplyTorqueCenter(Vector(64, 0, 0))
            end

            p:EmitSound("weapons/airboat/airboat_gun_energy1.wav", 75, 300, .4, CHAN_AUTO, 0) --Deployed sound
            p:EmitSound("weapons/airboat/airboat_gun_energy2.wav", 75, 200, .35, CHAN_AUTO, 0)

            timer.Create("RUIN ability_f_cooldown", cooldown, 1, function()
                if !p:Alive() then return end
                p:EmitSound("buttons/button6.wav", 75, 140, readyToUseSoundVolume, CHAN_AUTO, 0) --Ready to use sound
            end)
        end,
        
        OnAbilityQ = function(p)
            local cooldown = 15
            -- ability conditions
            if not IsValid(p) then return end
            if not p:Alive() then return end
            if p:justSpawned() then return end

            if p:GetAbilityQEnd() > CurTime() then
                p:EmitSound("buttons/combine_button_locked.wav", 75, 125, .35) --Not available sound
                return
            end

            p:SetNextAbilityQ(CurTime() + cooldown)

            -- ability code
            local shieldDeployer = ents.Create("ruin_shield_deployer")
            local _shieldDeployAngleYaw = p:GetEyeTrace().Normal:Angle().yaw
            shieldDeployer.shieldDeployAngleYaw = _shieldDeployAngleYaw
            shieldDeployer:SetPos(p:GetPos() + Vector(0, 0, 64))
            shieldDeployer:SetAngles(p:GetAngles())
            shieldDeployer:Spawn()
            local shieldDeployerPhys = shieldDeployer.phys
            shieldDeployer:Activate()

            if (shieldDeployer:GetPhysicsObject():IsValid() and p:IsValid()) then
                shieldDeployerPhys:SetVelocityInstantaneous(p:EyeAngles():Forward() * 250)
            end

            p:EmitSound("npc/attack_helicopter/aheli_mine_drop1.wav", 35) --Deployed sound

            timer.Create("RUIN ability_q_cooldown", cooldown, 1, function()
                if !p:Alive() then return end
                p:EmitSound("npc/scanner/combat_scan5.wav", 40, 100, readyToUseSoundVolume) --Ready to use sound
            end)
        end,
    },
    
    Aggressor = {
        Color = colorSelect,
        Icon = Material("icons/aggressor.png", "mip smooth"),  
        Desc = { "Unrelenting force, Total destruction" },
        AbilityPassiveName = "Crank'd",
        AbilityPassiveDesc = "-50% MOV DMG -25% Health +10% Speed",
        AbilityShiftName = "Dash",
        AbilityShiftIcon = Material("icons/dash.png", "mip smooth"),
        AbilityShiftDesc = "Surge of momentum",
        AbilityFName = "Missiles",
        AbilityFIcon = Material("icons/micro_missiles.png", "mip smooth"),
        AbilityFDesc = "flurry of guided micro-missles",
        AbilityQName = "Overheat",
        AbilityQIcon = Material("icons/overheat.png", "mip smooth"),
        AbilityQDesc = "arm weapon with explosive round",
        Speed = 165, -- Default = 150

        OnSpawn = function(p)
            p:SetRunSpeed(165)
            p:SetWalkSpeed(165)
            p:SetSlowWalkSpeed(165)
            
            p:SetMaxHealth(75)
            p:SetHealth(75)

            hook.Add( "EntityTakeDamage", "RUIN " .. tostring(p), function(e,t)
                if e != p then return end
                if e:GetVelocity():Length() < 16 then return end
                t:ScaleDamage( .5 )
            end )
        end,

        OnThink = function(p) 
            timer.Create( "RUIN " .. tostring(p)..".Remove.Aggressor.Hooks", .5, 1, function() hook.Remove( "EntityTakeDamage", "RUIN " .. tostring(p) ) end )
        end,

        OnAbilityShift = function(p)
            local cooldown = 1.5
            -- ability conditions
            if not IsValid(p) then return end
            if not p:Alive() then return end
            if p:justSpawned() then return end
            if p:GetVelocity():Length() < 16 then return end
            if not p:IsOnGround() then return end

            if p:GetAbilityShiftEnd() > CurTime() then
                p:EmitSound("buttons/combine_button1.wav", 100, 100, .75) -- Not available sound
                return
            end

            p:setIsDashing(true)
            p:SetNextAbilityShift(CurTime() + cooldown)
            -- ability code
            local velo = p:GetVelocity()
            util.ScreenShake(p:GetPos(), 5, 5, .75, 5000)
            p:EmitSound("ambient/levels/labs/electric_explosion1.wav", 75, 200, .3, CHAN_AUTO, 0, 8) --Deployed sound
            p:GodEnable()
            p:SetMaterial("models/ruin/shared/misc/dash_mat")

            timer.Create("RUIN Dash Ghost Trail", .01, 10, function()
                if !p:Alive() or !IsValid(p) then p:SetMaterial("") return end
                local dashGhost = ents.Create("prop_dynamic")
                dashGhost:SetPos(p:GetPos())
                dashGhost:SetAngles(p:GetAngles())
                dashGhost:SetMoveType(MOVETYPE_NONE)
                dashGhost:SetModel(p:GetModel())
                dashGhost:SetNotSolid(true)
                dashGhost:Spawn()
                dashGhost:SetSequence( p:GetSequence() )
                dashGhost:SetMaterial("models/ruin/shared/misc/dash_mat")
                dashGhost:SetRenderMode(RENDERMODE_TRANSALPHA)
                local dashWeapon = ents.Create("prop_dynamic")
                local dashWeaponpos = p:GetPos()
                dashWeaponpos = dashWeaponpos + (p:GetAimVector() * 21)
                dashWeaponpos = dashWeaponpos + Vector(0,0,54)
                dashWeapon:SetPos(dashWeaponpos)
                local dashWeaponAngle = p:GetAngles()
                dashWeaponAngle:RotateAroundAxis( Vector(0,0,1), 180 )
                dashWeapon:SetAngles(dashWeaponAngle)
                dashWeapon:SetMoveType(MOVETYPE_NONE)
                dashWeapon:SetModel(weaponConversions[p:GetActiveWeapon():GetModel()])
                dashWeapon:SetNotSolid(true)
                dashWeapon:Spawn()
                dashWeapon:SetMaterial("models/ruin/shared/misc/dash_mat")
                dashWeapon:SetRenderMode(RENDERMODE_TRANSALPHA)
                
                timer.Simple(.025,function()
                    if !p:Alive() then return end
                    local color = dashGhost:GetColor()
                    color.a = color.a - 75
                    dashGhost:SetColor(color)
                    dashWeapon:SetColor(color)
                end)
                timer.Simple(.05,function()
                    if !p:Alive() then return end
                    local color = dashGhost:GetColor()
                    color.a = color.a - 75
                    dashGhost:SetColor(color)
                    dashWeapon:SetColor(color)
                end)
                timer.Simple(.075,function()
                    if !p:Alive() then return end
                    local color = dashGhost:GetColor()
                    color.a = color.a - 75
                    dashGhost:SetColor(color)
                    dashWeapon:SetColor(color)
                end)
                timer.Simple(.15, function()
                    if IsValid(dashGhost) then
                        dashGhost:Remove()
                    end
                    dashGhost:Remove()
                    if IsValid(dashWeapon) then
                        dashWeapon:Remove()
                    end
                end)
            end)


            timer.Simple(.15, function()
                if not IsValid(p) then return end
                p:GodDisable()
                p:SetMaterial("")
                p:setIsDashing(false)

                if IsValid(w) then
                    w:SetMaterial("")
                end
            end)

            timer.Create("RUIN ability_shift_cooldown", cooldown, 1, function()
                if !p:Alive() then return end
                p:EmitSound("weapons/grenade/tick1.wav", 75, 70, readyToUseSoundVolume) --Ready to use sound
            end)
        end,

        OnAbilityF = function(p)
            local cooldown = 8
            
            -- ability conditions
            if not IsValid(p) then return end
            if not p:Alive() then return end
            if p:justSpawned() then return end

            if p:GetAbilityFEnd() > CurTime() then
                p:EmitSound("buttons/button2.wav", 100, 125, .35) --Not available sound

                return
            end

            p:SetNextAbilityF(CurTime() + cooldown)
            
            -- ability code
            local validNpcs = {NULL}
            local v = p:WorldSpaceCenter()

            for _, e in pairs(ents.FindByClass("*npc*")) do
                local vv = e:WorldSpaceCenter()
                if not e.IsNPC or not e:IsNPC() then continue end
                if e:Health() <= 0 then continue end
                if v:Distance(vv) > 1024 then continue end
                if not p:IsLineOfSightClear(e) then continue end
                local i = p:EyeAngles():Forward():Dot((vv - v):GetNormalized())
                if i < .7 then continue end
                table.insert(validNpcs, e)
            end

            local a = p:EyeAngles()
            local v = p:GetPos()

            for i = 1, 6 do
                if !p:Alive() then return end
                timer.Simple(i / 15, function()
                    if !IsValid(p) or !p:Alive() then return end
                    p:EmitSound("ruin/effects/abilities/micro_missile_fire_02.ogg",150, math.random(70,90), .75)
                    p:EmitSound("ruin/effects/abilities/micro_missile_fire_01.ogg",150, math.random(165,185), 1)
                    local e = ents.Create("ruin_micro_missile")
                    e:SetPos(p:EyePos() + a:Right() * 4 + (Vector(0,0,16)))
                    e:SetAngles(Angle(-70, a.y + math.random(-8, 8), 0))
                    e:Spawn()
                    e:SetMaterial("models/ruin/shared/misc/dash_mat")
                    local ee = table.Random(validNpcs)
                    e:SetTargetEntity(ee)
                    if !IsValid(ee) then
                        e:SetTargetVector( v + a:Forward()*math.random(256,256+128) + a:Right()*math.random(-64,64)) 
                        local k = tostring(e) .. "missile crash to ground"
    
                        timer.Create("RUIN " .. k, .1, 200, function()
                            if !IsValid(e) or !IsValid(p) then timer.Remove(k) return end
                            if e:GetPos().z < p:GetPos().z then 
                                
                                e:SetTargetVector( e:GetPos() + Vector(0,0,-512))
                                e:GetPhysicsObject():AddVelocity(Vector(0,0,-1024)) 
                                --e.ACTIVE = false
                                --e:SetTargetVector( e:GetPos() + Vector(0,0,-64)) 
                                timer.Remove("RUIN " .. k)
                            end
                        end)
                    end
                    e.OWNER = p
                end)
            end

            timer.Create("RUIN ability_f_cooldown", cooldown, 1, function()
                if !p:Alive() then return end
                p:EmitSound("buttons/button6.wav", 100, 140, readyToUseSoundVolume, CHAN_AUTO, 0) --Ready to use sound
            end)
        end,
        
        OnAbilityQ = function(p) 
            local cooldown = 6 
            local abilityUseWindow = 2
            
            -- ability conditions
            if not IsValid(p) then return end
            if not p:Alive() then return end
            if p:justSpawned() then return end

            if p:GetAbilityQEnd() > CurTime() then
                p:EmitSound("buttons/combine_button_locked.wav", 100, 125, .35) --Not available sound
                return
            end

            p:EmitSound("npc/attack_helicopter/aheli_charge_up.wav", 100, 300, .75) -- Charge up sound
            p.AggressorQLoopSound = "weapons/physcannon/superphys_hold_loop.wav"
            timer.Create("RUIN Aggressor q loop sound delay", .3, 1, function()
                --p:EmitSound(loopSound, 100, 120, .75)
                p:EmitSound(p.AggressorQLoopSound, 100, 135, .25)
            end)

            p:SetNextAbilityQ(CurTime() + 10000000000000) -- Needed to get bar to show up right on use before starting to recharge
            p:setIsUsingAggressorQ(true)
            p.usingAggressorQ = true

            --ability code
            timer.Create("RUIN Aggressor Q Disable", abilityUseWindow, 1, function() 
                p:SetNextAbilityQ(CurTime() + cooldown)
                timer.Create("RUIN ability_q_cooldown", cooldown, 1, function()
                    if !p:Alive() then return end
                    p:EmitSound("npc/sniper/reload1.wav", 100, 140, readyToUseSoundVolume, CHAN_AUTO, 0) --Ready to use sound
                end)
                p:EmitSound("npc/turret_floor/die.wav", 100, 200, .3, CHAN_AUTO, 0)
                p:setIsUsingAggressorQ(false)
                hook.Remove("PlayerDeath", "RUIN Aggressor Clear Q Effects On Death")
                hook.Remove("EntityFireBullets", "RUIN Aggressor Q Ability Enhance Weapon")
                timer.Remove("RUIN Aggressor q loop sound delay")
                p:StopSound(p.AggressorQLoopSound)
            end)

            hook.Add("EntityFireBullets", "RUIN Aggressor Q Ability Enhance Weapon", function(ent)
                if !IsValid(ent) then return end
                if !ent:IsPlayer() then return end
                ent:EmitSound("weapons/ar2/npc_ar2_altfire.wav",75,130,1)
                
                -- Trace to see where the player's bullet went
                local tr = util.TraceLine( {
                    start = ent:EyePos(),
                    endpos = ent:GetAimVector() * 99999999,
                    filter = ent, ent:GetActiveWeapon()
                } )
        
                -- Create the effect
                local effectdata = EffectData()
                effectdata:SetMagnitude(1)
                effectdata:SetRadius(1)
                effectdata:SetScale(1)
                effectdata:SetOrigin( tr.HitPos )
                util.Effect( "HelicopterMegaBomb", effectdata )
                local effectdata = EffectData()
                local attachment = ent:GetActiveWeapon():LookupAttachment( "muzzle" )
                local t = ent:GetActiveWeapon():GetAttachment( attachment )
                effectdata:SetOrigin( t.Pos )
                effectdata:SetNormal( ent:EyeAngles():Forward() )
                util.Effect( "ruin_ability_overheat_muzzle_dischage", effectdata )
                
                -- Make explosion at site of impact
                util.BlastDamage(ent,ent,tr.HitPos,160,50)

                -- Create explosion flash by riding off the enhanced muzzle flash script
                net.Start("RUIN Draw Aggressor Q Flash")
                net.WriteVector( tr.HitPos )
                net.Broadcast()

                -- Cancel all associated hooks & timers and sounds and reset the ability 
                hook.Remove("PlayerDeath", "RUIN Aggressor Clear Q Effects On Death")
                hook.Remove("EntityFireBullets", "RUIN Aggressor Q Ability Enhance Weapon")
                timer.Remove("RUIN Aggressor Q Disable")
                timer.Remove("RUIN Aggressor q loop sound delay")
                timer.Simple( 0, function() p:setIsUsingAggressorQ(false) end )
                p:SetNextAbilityQ(CurTime() + cooldown)
                p:StopSound(p.AggressorQLoopSound)
                timer.Create("RUIN ability_q_cooldown", cooldown, 1, function()
                    if !p:Alive() then return end
                    p:EmitSound("npc/sniper/reload1.wav", 100, 140, readyToUseSoundVolume, CHAN_AUTO, 0) --Ready to use sound
                end)
            end)

            hook.Add("PlayerDeath", "RUIN Aggressor Clear Q Effects On Death", function(ply)
                if !IsValid(ply) then return end
                
                timer.Remove("RUIN Aggressor Q Disable")
                timer.Remove("RUIN ability_q_cooldown")
                hook.Remove("PlayerDeath", "RUIN Aggressor Clear Q Effects On Death")
                hook.Remove("EntityFireBullets", "RUIN Aggressor Q Ability Enhance Weapon")
                p:StopSound(p.AggressorQLoopSound)
                p:setIsUsingAggressorQ(false)
            end)
        end,
    },
    
    -- Technomancer = {
    --     Icon = Material("icons/technomancer.png", "mip smooth"),
    --     Desc = { "Digital Nightmare, Stalking Spectre" },
    --     Color = colorSelect,
    --     AbilityPassiveName = "Fragile", 
    --     AbilityPassiveDesc = "-20% Health, No HP Recovery",
    --     AbilityShiftName = "Active Camo",
    --     AbilityShiftIcon = Material("icons/active_camo.png", "mip smooth"),
    --     AbilityShiftDesc = "Invisibility For Short Time",
    --     AbilityFName = "Inject",
    --     AbilityFIcon = Material("icons/inject.png", "mip smooth"),
    --     AbilityFDesc = "Turn enemy friendly for short time",
    --     AbilityQName = "Nanites",
    --     AbilityQIcon = Material("icons/nanites.png", "mip smooth"),
    --     AbilityQDesc = "Deploys radius that heals you",
    --     OnSpawn = function(p)
    --         p:SetWalkSpeed(150) -- Default = 150
    --         p:SetSlowWalkSpeed(150)
    --         p:SetRunSpeed(150)
            
    --         p:SetMaxHealth(100)
    --         p:SetHealth(100)
    --     end,
    --     OnThink = function(p) end,
    --     OnAbilityShift = function(p)
    --         local invisibilityTime = 3
    --         local cooldown = 8
    --         -- ability conditions
    --         if not IsValid(p) then return end
    --         if not p:Alive() then return end
    --         if p:justSpawned() then return end        
            
    --         if p:GetAbilityShiftEnd() > CurTime() then
    --             p:EmitSound("buttons/combine_button1.wav", 100, 100, .75) -- Not available sound
    --             return
    --         end
            
    --         -- ability code
    --         p:EmitSound("items/suitchargeok1.wav", 100, 170, .4, CHAN_AUTO, 0) --Deployed sound
            
    --         p:setIsCloaking(true)
    --         p:SetNextAbilityShift(CurTime() + CurTime() + 10000000000000) -- Needed to get bar to show up right on use before starting to recharge
            
    --         p:SetMaterial("models/shadertest/shader3")
    --         net.Start("RUIN Technomancer Q Materialize Weapon Skin")
    --         net.WriteBool(true)
    --         net.Broadcast()
            
    --         for k, v in pairs(ents.FindByClass("npc_*")) do
    --             if v:GetClass() == "npc_grenade_frag" then continue end
    --             if !IsEnemyEntityName(v:GetClass()) then continue end
    --             if v:isInjected() then continue end
    --             v:AddEntityRelationship( p, D_NU, 99 )
    --             v:IgnoreEnemyUntil( p, CurTime() + invisibilityTime )
    --             v:SetEnemy( NULL, true )
    --         end
            
    --         timer.Create("RUIN ability_shift_cooldown", invisibilityTime, 1, function()
    --             if !IsValid(p) then return end
            
    --             p:SetNextAbilityShift(CurTime() + cooldown)
            
    --             p:setIsCloaking(false)
    --             p:EmitSound("ambient/energy/zap2.wav", 100, 120, .4, CHAN_AUTO, 0) --Ability effect worn off sound
                
    --             p:SetMaterial("")
    --             net.Start("RUIN Technomancer Q Materialize Weapon Skin")
    --             net.WriteBool(false)
    --             net.Broadcast()
            
    --             for k, v in pairs(ents.FindByClass("npc_*")) do
    --                 if v:GetClass() == "npc_grenade_frag" then continue end
    --                 if !IsEnemyEntityName(v:GetClass()) then continue end
    --                 if v:isInjected() then continue end
    --                 v:AddEntityRelationship( p, D_HT, 99 )
    --                 v:IgnoreEnemyUntil( p, CurTime() + 0 )
    --             end
            
    --             hook.Remove("PlayerDeath", "RUIN Technomancer Clear Shift Effects On Death")
    --             hook.Remove("OnEntityCreated", "RUIN Technomancer Active Camo Set Up Dispositions On NPC Spawn")
    --             hook.Remove("EntityFireBullets", "RUIN Technomancer Disable Cloak On Fire")
    --         end)
            
    --         timer.Create("RUIN ability_shift_cooldown_ready_sound", cooldown + invisibilityTime, 1, function()
    --             if !p:Alive() then return end
    --             p:EmitSound("weapons/grenade/tick1.wav", 75, 70, readyToUseSoundVolume) --Ready to use sound
    --         end)
            
    --         hook.Add("EntityFireBullets", "RUIN Technomancer Disable Cloak On Fire", function(ent, data)
    --             if !ent:IsPlayer() then return end
    --             if !IsValid(ent) then return end
                
    --             p:SetNextAbilityShift(CurTime() + cooldown)
            
    --             ent:setIsCloaking(false)
    --             p:EmitSound("ambient/energy/zap2.wav", 100, 120, .4, CHAN_AUTO, 0) --Ability effect worn off sound
            
    --             ent:SetMaterial("")
    --             net.Start("RUIN Technomancer Q Materialize Weapon Skin")
    --             net.WriteBool(false)
    --             net.Broadcast()
            
    --             for k, v in pairs(ents.FindByClass("npc_*")) do
    --                 if v:GetClass() == "npc_grenade_frag" then continue end
    --                 if !IsEnemyEntityName(v:GetClass()) then continue end
    --                 if v:isInjected() then continue end
    --                 v:AddEntityRelationship( p, D_HT, 99 )
    --                 v:IgnoreEnemyUntil( p, CurTime() + 0 )
    --             end
            
    --             timer.Remove("RUIN ability_shift_cooldown")
    --             timer.Create("RUIN ability_shift_cooldown_ready_sound", cooldown, 1, function()
    --                 if !p:Alive() then return end
    --                 p:EmitSound("weapons/grenade/tick1.wav", 75, 70, readyToUseSoundVolume) --Ready to use sound
    --             end)
            
    --             hook.Remove("PlayerDeath", "RUIN Technomancer Clear Shift Effects On Death")
    --             hook.Remove("EntityFireBullets", "RUIN Technomancer Disable Cloak On Fire")
    --             hook.Remove("OnEntityCreated", "RUIN Technomancer Active Camo Set Up Dispositions On NPC Spawn")
    --         end)
            
    --         hook.Add("PlayerDeath", "RUIN Technomancer Clear Shift Effects On Death", function(ply) 
    --             if !IsValid(ply) then return end
            
    --             ply:setIsCloaking(false)
    --             ply:SetMaterial("")
    --             net.Start("RUIN Technomancer Q Materialize Weapon Skin")
    --             net.WriteBool(true)
    --             net.Broadcast()
            
    --             hook.Remove("PlayerDeath", "RUIN Technomancer Clear Shift Effects On Death")
    --             hook.Remove("EntityFireBullets", "RUIN Technomancer Disable Cloak On Fire")
    --             hook.Remove("OnEntityCreated", "RUIN Technomancer Active Camo Set Up Dispositions On NPC Spawn")
    --             timer.Remove("RUIN ability_shift_cooldown")
    --             timer.Remove("RUIN ability_shift_cooldown_ready_sound")
    --         end)
            
    --         hook.Add("OnEntityCreated", "RUIN Technomancer Active Camo Set Up Dispositions On NPC Spawn", function(ent)
    --             if !IsValid(ent) then return end
    --             if !ent:IsNPC() then return end
    --             if !IsEnemyEntityName(ent:GetClass()) then return end   
    --             if !IsValid(p) then return end
    --             ent:AddEntityRelationship( p, D_NU, 99 )
    --             ent:IgnoreEnemyUntil( p, CurTime() + invisibilityTime )
    --         end)
    --     end,
    --     OnAbilityF = function(p) 
    --         local cooldown = 12 
    --         local abilityEffectDuration = 5 
            
    --         -- ability conditions
    --         if not IsValid(p) then return end
    --         if not p:Alive() then return end
    --         if p:justSpawned() then return end

    --         if p:GetAbilityFEnd() > CurTime() then
    --             p:EmitSound("buttons/combine_button_locked.wav", 75, 125, .35) --Not available sound
    --             return
    --         end

    --         p:SetNextAbilityF(CurTime() + cooldown) -- Needed to get bar to show up right on use before starting to recharge

    --         --ability code
    --         local priorityEnemy = nil
    --         local bestAlignment = .90

    --         for k, v in pairs(ents.FindByClass("npc_*")) do
    --             if !IsValid(v) then continue end
    --             if !IsEnemyEntityName(v:GetClass()) then continue end
    --             if !v:isVisibleToPlayer() then continue end

    --             local diff = v:GetPos() - p:GetShootPos()
    --             local alignment = p:GetAimVector():Dot(diff) / diff:Length()

    --             if alignment > bestAlignment  then // Ensure the current alignment is better than the last one (All alignments must be atleast greater than .90 aswell)
    --                 priorityEnemy = v
    --                 bestAlignment = alignment
    --             end
    --         end

    --         if !IsValid(priorityEnemy) then 
    --             p:EmitSound("buttons/weapon_cant_buy.wav", 75, 125, .35) --Ability failed sound
    --             return 
    --         end

    --         p:EmitSound("buttons/blip2.wav", 75, 170, .4, CHAN_AUTO, 0) --Deployed sound
            
    --         priorityEnemy:setInjected(true)
    --         if !p:isCloaking() then
    --             priorityEnemy:AddEntityRelationship( p, D_LI, 99 )
    --             priorityEnemy:IgnoreEnemyUntil( p, CurTime() + abilityEffectDuration )
    --         end
    --         local squad = priorityEnemy:GetSquad()
    --         priorityEnemy:SetSquad("")
    --         priorityEnemy:SetEnemy( NULL, true )

    --         net.Start("RUIN Technomancer Injected Enemy")
    --         net.WriteEntity(priorityEnemy)
    --         net.Broadcast()

    --         for k, v in pairs(ents.FindByClass("npc_*")) do
    --             if !IsValid(priorityEnemy) then return end
    --             if !IsValid(v) then continue end
    --             if !IsEnemyEntityName(v:GetClass()) then continue end
                
    --             v:AddEntityRelationship( priorityEnemy, D_HT, 99 )
    --             priorityEnemy:AddEntityRelationship( v, D_HT, 99 )
    --         end

    --         timer.Simple(abilityEffectDuration, function()
    --             if !IsValid(priorityEnemy) then return end
                
    --             priorityEnemy:SetSquad(squad)

    --             priorityEnemy:setInjected(false)
    --             if !p:isCloaking() then
    --                 priorityEnemy:AddEntityRelationship( p, D_HT, 99 )
    --             end
                
    --             for k, v in pairs(ents.FindByClass("npc_*")) do
    --                 if !IsValid(v) then continue end
    --                 if !IsEnemyEntityName(v:GetClass()) then continue end
                    
    --                 v:AddEntityRelationship( priorityEnemy, D_LI, 99 )
    --                 priorityEnemy:AddEntityRelationship( v, D_LI, 99 )
    --             end
    --         end)

    --         timer.Create("RUIN ability_f_cooldown", cooldown, 1, function()
    --             if !p:Alive() then return end
    --             p:EmitSound("buttons/combine_button5.wav", 75, 120, readyToUseSoundVolume, CHAN_AUTO, 0) --Ready to use sound
    --             hook.Remove("OnEntityCreated", "RUIN Technomancer Injected Set Up Dispositions On NPC Spawn")
    --         end)

    --         hook.Add("OnEntityCreated", "RUIN Technomancer Injected Set Up Dispositions On NPC Spawn", function(ent)
    --             if !IsValid(ent) then return end
    --             if !ent:IsNPC() then return end
    --             if !IsEnemyEntityName(ent:GetClass()) then return end
    --             if !IsValid(priorityEnemy) then return end    
    --             ent:AddEntityRelationship( priorityEnemy, D_HT, 99 )
    --             priorityEnemy:AddEntityRelationship( ent, D_HT, 99 )
    --         end)
    --     end,
    --     OnAbilityQ = function(p)
    --         local activeTime = 3
    --         local cooldown = 10 

    --         -- ability conditions
    --         if not IsValid(p) then return end
    --         if not p:Alive() then return end
    --         if p:justSpawned() then return end

    --         if p:GetAbilityQEnd() > CurTime() then
    --             p:EmitSound("buttons/combine_button_locked.wav", 75, 125, .35) --Not available sound
    --             return
    --         end

    --         --ability code
    --         p:SetNextAbilityQ(CurTime() + CurTime() + 10000000000000) -- Needed to get bar to show up right on use before starting to recharge
    --         p:EmitSound("buttons/button1.wav", 75, 80, .4, CHAN_AUTO, 0) --Deployed sound

    --         local tempPropVisualizer = ents.Create("prop_dynamic")
    --         tempPropVisualizer:SetModel("models/hunter/tubes/circle4x4.mdl")
    --         tempPropVisualizer:SetPos(p:GetPos())
    --         tempPropVisualizer:Spawn()
    --         tempPropVisualizer:SetRenderMode(RENDERMODE_TRANSALPHA)
    --         tempPropVisualizer:SetColor(Color(127,255,0,150))

    --         timer.Create("RUIN ability_q_cooldown_ready_sound", cooldown + activeTime, 1, function()
    --             p:EmitSound("buttons/blip1.wav", 100, 140, readyToUseSoundVolume, CHAN_AUTO, 0) --Ready to use sound
    --         end)

    --         timer.Create("RUIN ability_q_cooldown", activeTime, 1, function()
    --             if !p:Alive() then return end
    --             tempPropVisualizer:Remove()
    --             p:SetNextAbilityQ(CurTime() + cooldown)
    --             hook.Remove("PlayerDeath", "RUIN Technomancer Clear Q Effects On Death")
    --             hook.Remove("Think", "RUIN Technmoancer Q Ability Heal Players In Radius")
    --         end)

    --         hook.Add("PlayerDeath", "RUIN Technomancer Clear Q Effects On Death", function(ply)
    --             hook.Remove("PlayerDeath", "RUIN Technomancer Clear Q Effects On Death")
    --             hook.Remove("Think", "RUIN Technmoancer Q Ability Heal Players In Radius")
    --             timer.Remove("RUIN ability_q_cooldown_ready_sound")
    --             if !IsValid(tempPropVisualizer) then return end
    --             tempPropVisualizer:Remove()
    --         end)

    --         local healDelay = 0 
    --         hook.Add("Think", "RUIN Technmoancer Q Ability Heal Players In Radius", function()
    --             if CurTime() < healDelay then return end
                
    --             if tempPropVisualizer:GetPos():Distance( p:GetPos() ) > 128 then return end
    --             local hp = p:Health()
    --             local maxHP = p:GetMaxHealth()
    --             healDelay = CurTime() + .1
    --             p:SetHealth(math.Clamp(hp + maxHP * .05, 0, maxHP))
    --         end)
    --     end,
    -- },
}

if SERVER then
    util.AddNetworkString( "RUIN Draw Aggressor Q Flash" )
    local plyAbilities 
    hook.Add("PlayerSpawn", "RUIN Player Abilities", function(p)
        timer.Create("RUIN " .. tostring(p) .. "Ruin Player Abilities", 0, 1, function()
            if not IsValid(p) then return end
            local k = p:GetPlayerAbilities()
            plyAbilities = k
            local t = RUIN.Abilities[k]

            if not t then
                t = RUIN.Abilities.Guardian
            end

            if t.OnSpawn then
                t.OnSpawn(p)
            end
        end)

        util.PrecacheModel(p:GetModel())
    end)

    hook.Add("Think", "RUIN Player Abilities", function()
        for _, p in pairs(player.GetAll()) do
            local k = p:GetPlayerAbilities()
            plyAbilities = k
            local t = RUIN.Abilities[k]

            if not t then
                t = RUIN.Abilities.Guardian
            end

            if t.OnThink then
                t.OnThink(p)
            end
        end
    end)

    util.AddNetworkString("RUIN Player Ability Button Pressed")
    util.AddNetworkString("RUIN Technomancer Q Materialize Weapon Skin")
    util.AddNetworkString("RUIN Technomancer Injected Enemy")
    
    net.Receive("RUIN Player Ability Button Pressed",function()
        local t = RUIN.Abilities[plyAbilities]

        if not t then
            t = RUIN.Abilities.Guardian
        end

        local num = net.ReadUInt(2)
        if num == 1 then t.OnAbilityShift(Entity(1)) end
        if num == 2 then t.OnAbilityF(Entity(1)) end
        if num == 3 then t.OnAbilityQ(Entity(1)) end
    end)
end

-- ability keybinds
if CLIENT then
    CreateClientConVar("RuinAbilityF", KEY_F, true, true)
    CreateClientConVar("RuinAbilityQ", KEY_Q, true, true)
    CreateClientConVar("RuinAbilityShift", KEY_LSHIFT, true, true)

    hook.Add("PlayerBindPress", "RUIN Ability Key Detect", function( ply, bind )
        if bind != "+speed" and bind != "impulse 100" and bind != "+menu" then return end
        local num 

        if bind == "+speed" then num = 1 end
        if bind == "impulse 100" then num = 2 end
        if bind == "+menu" then num = 3 end

        net.Start("RUIN Player Ability Button Pressed")
        net.WriteUInt( num, 2 )
        net.SendToServer()
    end)
end

function pMeta:GetAbilityFKey()
    return self:GetInfoNum("RuinAbilityF", KEY_F)
end

function pMeta:GetAbilityQKey()
    return self:GetInfoNum("RuinAbilityQ", KEY_Q)
end

function pMeta:GetAbilityShiftKey()
    return self:GetInfoNum("RuinAbilityShift", KEY_LSHIFT)
end

function pMeta:GetAbilityFName()
    return RUIN.Abilities[ self:GetPlayerAbilities() ].AbilityFName
end

function pMeta:GetAbilityQName()
    return RUIN.Abilities[ self:GetPlayerAbilities() ].AbilityQName
end

function pMeta:GetAbilityShiftName() 
    return RUIN.Abilities[ self:GetPlayerAbilities() ].AbilityShiftName
end

function pMeta:GetAbilityFIcon()
    return RUIN.Abilities[ self:GetPlayerAbilities() ].AbilityFIcon
end

function pMeta:GetAbilityQIcon()
    return RUIN.Abilities[ self:GetPlayerAbilities() ].AbilityQIcon
end

function pMeta:GetAbilityShiftIcon() 
    return RUIN.Abilities[ self:GetPlayerAbilities() ].AbilityShiftIcon
end

-- ability group/ player class
function pMeta:SetPlayerAbilities(k)
    if not RUIN.Abilities[k] then return end
    self:SetNWString("PlayerAbilities", k)
end

function pMeta:GetPlayerAbilities()
    return self:GetNWString("PlayerAbilities", "Guardian")
end

-- ability f
function pMeta:SetNextAbilityF(i)
    self:SetNWFloat("AbilityFStart", CurTime())
    self:SetNWFloat("AbilityFEnd", i)
end

function pMeta:GetAbilityFStart()
    return self:GetNWFloat("AbilityFStart")
end

function pMeta:GetAbilityFEnd()
    return self:GetNWFloat("AbilityFEnd")
end

function pMeta:CanAbilityF()
    return self:GetAbilityFEnd() < CurTime()
end

-- ability q
function pMeta:SetNextAbilityQ(i)
    self:SetNWFloat("AbilityQStart", CurTime())
    self:SetNWFloat("AbilityQEnd", i)
end

function pMeta:GetAbilityQStart()
    return self:GetNWFloat("AbilityQStart")
end

function pMeta:GetAbilityQEnd()
    return self:GetNWFloat("AbilityQEnd")
end

function pMeta:CanAbilityQ()
    return self:GetAbilityQEnd() < CurTime()
end

function pMeta:setIsUsingAggressorQ(bool)
    self:SetNWBool("isUsingAggressorQ", bool)
end

function pMeta:isUsingAggressorQ()
    return self:GetNWBool("isUsingAggressorQ")
end

-- ability shift
function pMeta:SetNextAbilityShift(i)
    self:SetNWFloat("AbilityShiftStart", CurTime())
    self:SetNWFloat("AbilityShiftEnd", i)
end

function pMeta:GetAbilityShiftStart()
    return self:GetNWFloat("AbilityShiftStart")
end

function pMeta:GetAbilityShiftEnd()
    return self:GetNWFloat("AbilityShiftEnd")
end

function pMeta:CanAbilityShift()
    return self:GetAbilityShiftEnd() < CurTime()
end

-- reset cooldowns on cleanup
hook.Add("PostCleanupMap", "RUIN Reset All Cooldowns", function()
    for _, p in pairs(player.GetAll()) do
        p:SetNextAbilityF(0)
        p:SetNextAbilityQ(0)
        p:SetNextAbilityShift(0)
        timer.Remove("RUIN ability_shift_cooldown")
        timer.Remove("RUIN ability_q_cooldown")
        timer.Remove("RUIN ability_f_cooldown")
    end
end)

hook.Add("PlayerDeath", "RUIN Abilities Handle Player Death", function(ply)
    if(IsValid(ply.AggressorQLoopSound)) then
        ply:StopSound(ply.AggressorQLoopSound)
    end
    timer.Remove("RUIN Aggressor q loop sound delay")
end)

-- ability effects
if CLIENT then
    local ply = LocalPlayer()

    // guardian impulse 
    local matCircle = Material("ruin/misc/circle_01.png")
    local matWarp = Material("particle/warp1_warp")
    local EFFECT = {}
    local p
    EFFECT.Render = function() end

    function EFFECT:Init(t)
        local e = ParticleEmitter(t:GetOrigin())

        timer.Simple(0, function()
            e:Finish()
        end)

        -- debris
        local velo
        local plyVelo = IsValid(t:GetEntity()) and t:GetEntity():GetVelocity()

        for i = 1, 32 do
            -- local p = e:Add("particles/smokey", t:GetOrigin())
            -- if (p) then
            --     p:SetDieTime(math.Rand(2,4))
            --     p:SetAirResistance(512)
            --     p:SetStartAlpha(10)
            --     p:SetEndAlpha(0)
            --     p:SetStartSize(32)
            --     p:SetEndSize(32*2)
            --     velo = VectorRand() * 1024
            --     velo.z = 0 
            --     p:SetVelocity( velo + plyVelo*4 )
            --     p:SetGravity(VectorRand()*16)
            --     p:SetCollide(true)
            --     p:SetBounce(.1)
            --     p:SetRollDelta(math.Rand(-1,1))
            --     p:SetColor(255,255,255)
            -- end
        end

        -- particles on the surrounding surfaces
        local a = Angle(0, 0, 0)
        local steps = 40

        for i = 1, steps do
            local p = e:Add("particles/smokey", t:GetOrigin())

            if (p) then
                p:SetCollideCallback(function(_, v, n)
                    p:SetCollide(false)
                    p:SetDieTime(math.Rand(2, 4))
                    p:SetStartAlpha(10)
                    p:SetAirResistance(0)
                    p:SetVelocity(n * 256)
                    p:SetPos(p:GetPos() + n * 8 + Vector(0, 0, math.random(-16, 16)))
                end)

                p:SetDieTime(.05)
                p:SetAirResistance(1024)
                p:SetStartAlpha(0)
                p:SetEndAlpha(0)
                p:SetStartSize(16)
                p:SetEndSize(16 * 2)
                p:SetVelocity(a:Forward() * 4096)
                p:SetCollide(true)
                p:SetBounce(0)
                p:SetRollDelta(math.Rand(-1, 1))
                p:SetColor(255, 255, 255)
            end

            a:RotateAroundAxis(a:Up(), 360 / steps)
        end

        local ee = ParticleEmitter(t:GetOrigin())

        timer.Simple(0, function()
            ee:Finish()
        end)

        -- circle pulse emitted from player
        local p = ee:Add(matCircle, t:GetOrigin())

        if (p) then
            p:SetPos(p:GetPos() + Vector(0, 0, 32))
            p:SetDieTime(.2)
            p:SetStartAlpha(255)
            p:SetEndAlpha(0)
            p:SetStartSize(0)
            p:SetEndSize(128)
            p:SetColor(70, 70, 70)
        end

        -- distortion emitted from player
        local p = ee:Add(matWarp, t:GetOrigin())

        if (p) then
            p:SetPos(p:GetPos() + Vector(0, 0, 32))
            p:SetDieTime(.2)
            p:SetStartAlpha(255)
            p:SetEndAlpha(0)
            p:SetStartSize(0)
            p:SetEndSize(200)
            p:SetColor(75, 75, 75)
        end
    end

    effects.Register(EFFECT, "ruin_ability_impulse")


    // aggressor overheat muzzle discharge
    local matCircle = Material("ruin/misc/circle_01.png")
    local matWarp = Material("particle/warp1_warp")
    local EFFECT = {}
    local p
    EFFECT.Render = function() end
    
    function EFFECT:Init(t)
        local e = ParticleEmitter(t:GetOrigin())
        timer.Simple(0, function() e:Finish() end)
        -- debris
        local velo
        local plyVelo = IsValid(t:GetEntity()) and t:GetEntity():GetVelocity()
        -- particles on the surrounding surfaces
        // particle daddy
        local p = e:Add("effects/blueflare1", t:GetOrigin())
        if (p) then
            p:SetDieTime(.3)
            p:SetAirResistance(0)
            p:SetStartAlpha(200)
            p:SetEndAlpha(0)
            p:SetStartSize(32)
            p:SetEndSize(0)
            -- p:SetVelocity()
            -- p:SetGravity(VectorRand()*64)
            -- p:SetCollide(true)
            -- p:SetBounce(0)
            -- p:SetRollDelta(math.Rand(-1, 1))
            p:SetColor(255, 255, 255)
        end
        // particle children
        local n = t:GetNormal()
        for i = 1, 16 do
            local p = e:Add("effects/blueflare1", t:GetOrigin())
            if (p) then
                p:SetDieTime(.3)
                p:SetAirResistance(256)
                p:SetStartAlpha(200)
                p:SetEndAlpha(0)
                p:SetStartSize(8)
                p:SetEndSize(0)
                p:SetVelocity(n*256 + VectorRand()*128)
                p:SetGravity(VectorRand()*64)
                p:SetCollide(true)
                p:SetBounce(0)
                p:SetRollDelta(math.Rand(-1, 1))
                p:SetColor(255, 255, 255)
            end
        end
    end
    
    effects.Register(EFFECT, "ruin_ability_overheat_muzzle_dischage") 
    -- aggressor overheat hitpos explosion 

    net.Receive("RUIN Technomancer Q Materialize Weapon Skin", function()
        ply = LocalPlayer()
        if !IsValid(ply) then return end
        
        if(net.ReadBool() == true) then
            ply.weaponSkin:SetMaterial("models/shadertest/shader3")
        else
            ply.weaponSkin:SetMaterial("")
        end
    end)

    surface.CreateFont("Technomancer Inject Font" , { font = "Kenney Future Square", size = ScreenScale(8), weight = 0, blursize = 0; scanlines = 0, shadow = false, additive = false, })

    hook.Add( "OnScreenSizeChanged", "RUIN Main Technomancer Inject Rebuild Font", function( oldWidth, oldHeight )
        surface.CreateFont("Technomancer Inject Font" , { font = "Kenney Future Square", size = ScreenScale(8), weight = 0, blursize = 0; scanlines = 0, shadow = false, additive = false, })
    end )

    local injectedColor = Color(126, 254, 33, 255)
    local injectOffset = 0
    local outlineColor = Color(0,0,0, 255)
    local ent = nil

    net.Receive("RUIN Technomancer Injected Enemy", function()
        ent = net.ReadEntity()

        injectedColor = Color(98, 203, 0, 255)
        outlineColor = Color(0,0,0, 255)
        injectOffset = 0

        timer.Simple(.1, function()
            timer.Create("RUIN Technomancer Injected Text Fade Out", .01, 50, function() 
                injectedColor.a = injectedColor.a - 5.1
                outlineColor.a = outlineColor.a - 5.1
                injectOffset = injectOffset + .35
            end)
        end)
    end)

    local pos = Vector(0,0,0)

    hook.Add("HUDPaint", "RUIN Technomancer Injected HUD Paint", function()
        if !IsValid(ent) then return end
        if !IsValid(ply) then return end
        if !ply:Alive() then return end
        if injectedColor.a == 0 then return end
        if RUIN.extracted then return end
        if ply.inMainMenu then return end 
        if ply.escMenuOpen then return end

        pos = (ent:GetPos() + Vector(0,0,80 + injectOffset)):ToScreen()

        draw.SimpleTextOutlined("INJECTED", "Technomancer Inject Font", pos.x, pos.y, injectedColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, outlineColor)
    end)
end

if SERVER then
    concommand.Add("RuinSetPlayerAbilities", function(p, _, t)
        local k = t[1] or ""
        if not RUIN.Abilities[k] then return end
        p:SetPlayerAbilities(k)
        
        game.CleanUpMap( false, { "env_fire", "entityflame", "_firesmoke" } )
        p:KillSilent()
        p:Spawn()
        RUIN.gameStarted = true
    end)
end

if CLIENT then
    local p, w, h = LocalPlayer(), ScrW(), ScrH()
    hook.Add("Think", "RUIN Ability HUD Manager Think", function()
        if !p.abilitySelectorHUD then return end
        if !IsValid(p.abilitySelectorHUD) then return end
        
        if LocalPlayer().escMenuOpen or gui.IsGameUIVisible() then 
            p.abilitySelectorHUD:Hide()
            for _, element in pairs(p.abilitySelectorHUD:GetChildren()) do
                element:Hide()
            end
        else
            p.abilitySelectorHUD:Show()
            for _, element in pairs(p.abilitySelectorHUD:GetChildren()) do
                element:Show()
            end
        end
    end)

    surface.CreateFont("RuinFontL" , {
        font = "Kenney Future Square", size = ScreenScale(13), weight = 0, blursize = 0; scanlines = 0, shadow = true, additive = true,
    })
    
    surface.CreateFont("RuinFontM" , {
        font = "Kenney Future Square", size = ScreenScale(10), weight = 0, blursize = 0; scanlines = 0, shadow = true, additive = true,
    })
    
    surface.CreateFont("RuinFontS" , {
        font = "Kenney Future Square", size = ScreenScale(7), weight = 0, blursize = 0; scanlines = 0, shadow = true, additive = true,
    })

    hook.Add( "OnScreenSizeChanged", "RUIN Loadout/ Abilities UI Rebuild Screen Sizes", function( oldWidth, oldHeight )
		w, h = ScrW(), ScrH()
        surface.CreateFont("RuinFontL" , { font = "Kenney Future Square", size = ScreenScale(13), weight = 500, blursize = 0; scanlines = 0, shadow = true, additive = true, }) 
        surface.CreateFont("RuinFontM" , { font = "Kenney Future Square", size = ScreenScale(10), weight = 500, blursize = 0; scanlines = 0, shadow = true, additive = true, })  
        surface.CreateFont("RuinFontS" , { font = "Kenney Future Square", size = ScreenScale(7), weight = 500, blursize = 0; scanlines = 0, shadow = true, additive = true, })

        if p.abilitySelectorHUD and p.abilitySelectorHUD:IsValid() then
            p.abilitySelectorHUD:Remove()
            p:ConCommand("RuinAbilitySelector")
        end
    end )
    
    concommand.Add("RuinAbilitySelector", function()
        local DFrame = vgui.Create("DFrame")
        DFrame:SetSize(w, h)
        DFrame:MakePopup()
        DFrame:SetAlpha(0)
        if p:Alive() then
            DFrame:AlphaTo(255, .3, 0)
        else
            DFrame:AlphaTo(255, 0, 0)
        end
        DFrame:ShowCloseButton( false )
        DFrame:SetDraggable( false ) 
        DFrame:SetTitle( "" ) 
        p.abilitySelectorHUD = DFrame
        input.SetCursorPos(w * .5, h * .95)

        DFrame.Paint = function(s)
            draw.BlurPanel(s)
        end

        DFrame.Think = function(s)
            s:ShowCloseButton(false)
        end

        local DPanel = vgui.Create("DPanel", DFrame)
        DPanel.Paint = function(s) end

        DPanel.Think = function(s)
            s:SizeToChildren(true, true)
            s:Center()
        end

        local wide = (w * .6 / table.Count(RUIN.Abilities)) * .75
        local tall = wide * 1.75

        for k, t in pairs(RUIN.Abilities) do
            local DButton = vgui.Create("DButton", DPanel)
            DButton:SetSize(wide, tall)
            DButton:Dock(LEFT)
            DButton:SetText("")
            DButton:DockMargin(h * .01, 0, h * .01, 0)

            DButton.Paint = function(s, w, h)
                local ft = FrameTime() / game.GetTimeScale() 
                s.hoverfrac = Lerp(ft * 4, s.hoverfrac or 0, s:IsHovered() and 1 or 0)
            end

            DButton.OnCursorEntered = function(s)
                EmitSound( "buttons/lightswitch2.wav", Vector(0,0,0), -2, CHAN_AUTO, 1, 75, 0, 200, 0 )
            end

            DButton.DoClick = function(s)
                p.numTimesLoadoutSelected = p.numTimesLoadoutSelected + 1
                
                RunConsoleCommand( "RuinSetPlayerAbilities", k )
                EmitSound( "buttons/button9.wav", Vector(0,0,0), -2, CHAN_AUTO, 1, 75, 0, 250, 0 )
                DFrame:Close()
                
                p.inMainMenu = false 
                RUIN.justSelectedClass = true 
                timer.Simple(1, function()
                    RUIN.justSelectedClass = false
                end)
                
                timer.Simple(1, function()
                    RUIN.displayMissionInfo()
                end)

                if p.numTimesLoadoutSelected == 1 then -- This will ensure playing a song after selecting loadout for the first time after main menu
                    RUIN.playSong(false) 
                end
            end

            DButton.PaintOver = function(s, w, h)
                local f = s.hoverfrac
                local _f = math.Remap( f, 0, 1, 1, 0 )
                
                draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 10 + 40 * f))
                -- draw.RoundedBox(0, 0, 0, w, h, c )
                
                local c = Color( t.Color.r-(40*_f), t.Color.g-(40*_f), t.Color.b-(40*_f), t.Color.a*f )
                surface.SetDrawColor( c )
                surface.DrawOutlinedRect( 0, 0, w, h, f*8 )

                if t.Icon then
                    surface.SetMaterial(t.Icon)
                    surface.SetDrawColor(Color(255, 255, 255, 200))
                    surface.DrawTexturedRectRotated(w / 2, h * .4 - (h * .25) * f, h / 5, h / 5, 0)
                end

                draw.SimpleTextOutlined(k, "RuinFontL", w / 2, h * .55 - (h * .25) * f, Color(255, 255, 255, 200), 1, 1, 2, Color(0, 0, 0, 25))
                local fff = math.RemapClamped(f, 0, .2, 0, 1)
                for i, v in pairs( t.Desc or {} ) do
                    draw.SimpleTextOutlined(v, "RuinFontS", w / 2, h * .95 + (h * .02) * i, Color(255, 255, 255, 100-100*fff), 1, 1, 2, Color(0, 0, 0, 20-25*fff))
                end
                local ff = math.RemapClamped(f, .5, 1, 0, 1)
                draw.SimpleText(t.AbilityShiftName, "RuinFontM", w / 2, h * .5, Color(255, 255, 255, 200 * ff), 1, 1)
                draw.SimpleText(t.AbilityShiftDesc, "RuinFontS", w / 2, h * .53, Color(255, 255, 255, 100 * ff), 1, 1)
                local fff = math.RemapClamped(f, .6, 1, 0, 1)
                draw.SimpleText(t.AbilityFName, "RuinFontM", w / 2, h * .6, Color(255, 255, 255, 200 * fff), 1, 1)
                draw.SimpleText(t.AbilityFDesc, "RuinFontS", w / 2, h * .63, Color(255, 255, 255, 100 * fff), 1, 1)
                local ffff = math.RemapClamped(f, .7, 1, 0, 1)
                draw.SimpleText(t.AbilityQName, "RuinFontM", w / 2, h * .7, Color(255, 255, 255, 200 * ffff), 1, 1)
                draw.SimpleText(t.AbilityQDesc, "RuinFontS", w / 2, h * .73, Color(255, 255, 255, 100 * ffff), 1, 1)
                local fffff = math.RemapClamped(f, .8, 1, 0, 1)
                draw.SimpleText(t.AbilityPassiveName, "RuinFontM", w / 2, h * .9, Color(255, 255, 255, 200 * fffff), 1, 1)
                draw.SimpleText(t.AbilityPassiveDesc, "RuinFontS", w / 2, h * .93, Color(255, 255, 255, 100 * fffff), 1, 1)
            end
        end
    end)

	net.Receive("RUIN Draw Aggressor Q Flash", function()
        if LocalPlayer().options.enableLamps == false then return end 
		
		local flashPos = net.ReadVector()
		local flash = ProjectedTexture()

		flash:SetTexture( "effects/flashlight/soft" )
		flash:SetColor( Color(41, 13, 0, 255) )
		flash:SetFarZ( 400 )
		flash:SetNearZ ( 60 )
		flash:SetFOV( 150 )
		flash:SetBrightness( math.random(50,65) )
		flash:SetEnableShadows ( true )

		flash:SetPos( flashPos + Vector(0,0,64) )
		flash:SetAngles( Angle(90,0,0) )
		flash:Update()
		timer.Simple( 0.025, function() flash:Remove() end)
	end)
end

function eMeta:setInjected(bool)
    self:SetNWBool('isInjected', bool )
end

function eMeta:isInjected()
    return self:GetNWBool('isInjected', false)
end