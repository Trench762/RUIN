AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ruin Weapon Pistol"
ENT.Author = "Trench"
ENT.Purpose = "Entity used with the stun augment ability"
ENT.Spawnable = false 
ENT.Category = "Other"

if SERVER then
    util.AddNetworkString( "RUIN Draw Stun Flash" )

    function ENT:Initialize()
        self:SetModel( "models/Items/AR2_Grenade.mdl" )
        self:PhysicsInit(SOLID_VPHYSICS) --Must create this before SetSolid
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
        self:PhysWake()
        self:SetMaterial("models/ruin/shared/misc/white")
        timer.Simple(.5,function() --after .5 seconds explode
            local nadePos = self:GetPos()
            local stunned = ents.FindInSphere( nadePos, 110 )
            self:EmitSound("phx/kaboom.wav", 100, 250, 1, CHAN_AUTO, 0)
            self:EmitSound("doors/door_metal_large_chamber_close1.wav", 100, 300, 1, CHAN_AUTO, 0)
            self:EmitSound("doors/door_metal_large_chamber_close1.wav", 100, 500, 1, CHAN_AUTO, 0)
            local stunExplodeEffect = EffectData()
            stunExplodeEffect:SetOrigin( nadePos )
            stunExplodeEffect:SetMagnitude(1)
            stunExplodeEffect:SetRadius(1)
            stunExplodeEffect:SetScale(1)
            util.Effect( "cball_explode", stunExplodeEffect )
            ParticleEffect("vortigaunt_glow_beam_cp1b", self:GetPos(), self:GetAngles())
            
            net.Start("RUIN Draw Stun Flash")
            net.WriteVector(nadePos)
            net.Broadcast()
            
            self:Remove()
            
            for k, v in pairs(stunned) do
                if !IsValid(v) or !v:IsNPC() then continue end
                if !v:IsLineOfSightClear( self ) then continue end
                timer.Create( "RUIN " .. tostring(v) .. "ruin_ability_stun_augment.Initialize", .1, 20, function() --stun enemies for 2 seconds
                    if !IsValid(v) or !v:IsNPC() or v:Health() <= 0 then return end
                    v:SetSchedule( SCHED_FLINCH_PHYSICS )
                    local effectdata = EffectData()
                    effectdata:SetMagnitude(1)
                    effectdata:SetRadius(1)
                    effectdata:SetScale(1)
                    effectdata:SetEntity(v)
                    util.Effect( "TeslaHitboxes", effectdata )

                    if timer.RepsLeft(tostring(v) .. "ruin_ability_stun_augment.Initialize") == 1 then
                        v:AddEntityRelationship( Entity(1), D_HT, 99 )
                    end
                end) 
            end
        end)
    end
end

function ENT:Use( activator )    
    return
end


if CLIENT then 
    local dlight 
    function ENT:Draw()
        if LocalPlayer().options.enableDLights == false then return end 
        self:DrawModel()
        -- dlight = DynamicLight( self:EntIndex() )
        -- if ( dlight ) then
        --     dlight.pos = self:GetPos() 
        --     dlight.r = 240
        --     dlight.g = 240
        --     dlight.b = 240
        --     dlight.brightness = 1
        --     dlight.Decay = 100000
        --     dlight.Size = 400
        --     dlight.DieTime = CurTime() + .01
        -- end
    end
    
    local muzzleFlashColor = Color(255, 255, 255)
    local muzzleFlashAngle = Angle(90,0,0)
    local muzzleFlashOffset = Vector(0,0,64)

    net.Receive("RUIN Draw Stun Flash", function()
        if LocalPlayer().options.enableLamps == false then return end 
        local flashPos = net.ReadVector()
        local flash = ProjectedTexture()
    
        flash:SetTexture( "effects/flashlight/soft" )
        flash:SetColor(muzzleFlashColor)
        flash:SetFarZ( 400 )
        flash:SetNearZ ( 60 )
        flash:SetFOV( 135 )
        flash:SetBrightness( 10 )
        flash:SetEnableShadows ( true )
    
        flash:SetPos( flashPos + muzzleFlashOffset )
        flash:SetAngles( muzzleFlashAngle )
        flash:Update()
        timer.Simple( 0.025 , function()
            flash:Remove()
        end)
    end)
end
