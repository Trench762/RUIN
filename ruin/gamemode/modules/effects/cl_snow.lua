if CLIENT then
    local EFFECT = {}
    local snowParticles = { "ruin/misc/snowflake_01", "ruin/misc/snowflake_02", "ruin/misc/snowflake_03", "ruin/misc/snowflake_04" }
    local ply = LocalPlayer()
    local particlePos = Vector(0,0,0)
    local snowEffect 
    local parentEffectOrigin = Vector(0,0,0)
    local snowParticleOffset = VectorRand() * 512
    local particleTexture = "ruin/misc/snowflake_01"
    local particle
    local mainMenuCamParticlesOffset = Vector(0,0,300)

    hook.Add( "Think", "RUIN Snow Effect", function()
        if timer.Exists( "RUIN Snow Effect" ) then return end

        if tobool(RUIN.mapSettings.enable_ruin_snow) == false then return end   
        if !ply.options then return end
        if !RUIN.mapSettings then return end
        if ply.options.enableSnowParticles == false then return end 
        
        timer.Create( "RUIN Snow Effect", .05, 1, function() end )
        
        if ply.inMainMenu then
            particlePos = util.StringToType(RUIN.mapSettings.main_menu_cam_pos, "Vector") - mainMenuCamParticlesOffset 
        else 
            particlePos = ply:GetPos()
        end

        snowEffect = EffectData()
        snowEffect:SetOrigin( particlePos )
        util.Effect( "RuinSnow", snowEffect )
    end)

    function EFFECT:Init( effectData )
        local parentEffectOrigin = effectData:GetOrigin()
        local emitter = ParticleEmitter( Vector(), false )
        
        for i = 1, 8 do
            snowParticleOffset = VectorRand() * 512
            snowParticleOffset.z = parentEffectOrigin.z + 512 
            particleTexture = snowParticles[math.random(1,4)]
            particle = emitter:Add( particleTexture, parentEffectOrigin + snowParticleOffset ) 
            if ( particle ) then
                particle:SetDieTime( 4 )
                particle:SetStartAlpha( 150 ) 
                particle:SetEndAlpha( 0 ) 
                particle:SetStartSize( 1.2 ) 
                particle:SetEndSize( 1 ) 
                particle:SetVelocity( VectorRand() * 32 + Vector(0, 0, -math.random(32,64)) ) 
                particle:SetGravity( Vector(math.random(4,16),math.random(4,16),-32) ) 
                particle:SetBounce( math.Rand(.05,.1) )
                particle:SetRollDelta( math.Rand(-1,1) )
                particle:SetColor( 255, 255, 255 )
                particle:SetLighting( false )
                -- particle:SetCollide( true )
                -- particle:SetCollideCallback( function( particle, hitpos, hitnormal ) 
                --     particle:SetLifeTime( 0 )
                --     particle:SetDieTime( 1 )
                -- end )
            end
        end
        emitter:Finish()
    end
    effects.Register( EFFECT, "RuinSnow" )
end