AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Trench"
ENT.Purpose = "deployable force shield for blocking income small arms fire- has hp and then is destroyed"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true
ENT.spawnTime = 0
ENT.totalLifeTime = 10
ENT.hp = 80

function eMeta:setColorValueIndex(number)
    self:SetNWInt('colorValueIndex', number )
end

function eMeta:getColorValueIndex()
    return self:GetNWInt('colorValueIndex', 40)
end

local forceShieldImpactSounds = {
    [1] = "weapons/physcannon/superphys_small_zap1.wav",
    [2] = "weapons/physcannon/superphys_small_zap2.wav",
    [3] = "weapons/physcannon/superphys_small_zap3.wav",
    [4] = "weapons/physcannon/superphys_small_zap4.wav"
}

local HPColorValues = {
    [40] = Color(120, 46, 255),
    [39] = Color(125, 46, 255),
    [38] = Color(130, 46, 255),
    [37] = Color(135, 46, 255),
    [36] = Color(140, 46, 255),
    [35] = Color(145, 46, 255),
    [34] = Color(150, 46, 255),
    [33] = Color(155, 46, 255),
    [32] = Color(160, 46, 255),
    [31] = Color(165, 46, 255),
    [30] = Color(170, 46, 255), 
    [29] = Color(175, 46, 255),
    [28] = Color(180, 46, 255),
    [27] = Color(185, 46, 255),
    [26] = Color(195, 46, 255),
    [25] = Color(205, 46, 245),
    [24] = Color(215, 46, 235),
    [23] = Color(225, 46, 225),
    [22] = Color(235, 46, 255),
    [21] = Color(245, 46, 255),
    [20] = Color(255, 46, 250),
    [19] = Color(255, 46, 240),
    [18] = Color(255, 46, 230),
    [17] = Color(255, 46, 220),
    [16] = Color(255, 46, 210),
    [15] = Color(255, 46, 200),
    [14] = Color(255, 46, 190),
    [13] = Color(255, 46, 180), 
    [12] = Color(255, 46, 170),
    [11] = Color(255, 46, 160),
    [10] = Color(255, 46, 150),
    [9]  = Color(255, 46, 140),
    [8]  = Color(255, 46, 130),
    [7]  = Color(255, 46, 120),
    [6]  = Color(255, 46, 110),
    [5]  = Color(255, 46, 100),
    [4]  = Color(255, 46, 90),
    [3]  = Color(255, 46, 80),
    [2]  = Color(255, 46, 70),
    [1]  = Color(255, 46, 60),
    [0]  = Color(255, 46, 50),
}

-- Precache models and sounds.
util.PrecacheModel( "models/ruin/high_tech/force_shield_01.mdl" )
util.PrecacheSound("ambient/machines/combine_shield_touch_loop1.wav")
util.PrecacheSound("ambient/levels/labs/electric_explosion5.wav")
util.PrecacheSound("weapons/stunstick/alyx_stunner1.wav")
for impactSound in ipairs(forceShieldImpactSounds) do
    util.PrecacheSound(forceShieldImpactSounds[impactSound])
end

function ENT:SetupDataTables()
    self:NetworkVar( "Float", 0, "spawnTime" )

    if SERVER then
        self:SetspawnTime( CurTime() )
    end
end

if SERVER then
    function ENT:Initialize()
        self:SetModel( "models/ruin/high_tech/force_shield_01.mdl" )
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)
        self:SetMoveType( MOVETYPE_NOCLIP )
        self:SetSolid( SOLID_VPHYSICS )
        self:SetCollisionGroup( COLLISION_GROUP_WORLD ) 
        self:DrawShadow( false )
        self.spawnTime = CurTime()
        self:SetColor(HPColorValues[40])
        self:EmitSound("ambient/machines/combine_shield_touch_loop1.wav", 55)
        self:EmitSound("weapons/stunstick/alyx_stunner1.wav",100)
        self.colorModulate = false
        self:Flicker()
        -- Put default setModelScale in timer too because even though physics are initialized before SetModelScale is called,
        -- SetModelScale finishes its job first, so this will result in it spawning a tiny model collision. 
        timer.Simple( 0, function() self:SetModelScale( 0, 0 ) end) --default of size 0
        timer.Simple( 0, function() self:SetModelScale( 1, .1 ) end ) --grows to size 1

        -- Code that defines behavior when entity's lifetime runs out.
        timer.Simple(self.totalLifeTime,function()
            if(!IsValid(self)) then return end
            self:EmitSound("ambient/levels/labs/electric_explosion5.wav", 100)
            self:StopSound("ambient/machines/combine_shield_touch_loop1.wav")
            self:Flicker()
            timer.Simple(0.48,function()
                if(IsValid(self)) then self:Remove() end
            end)
        end)

        local anim = self:LookupSequence("activate" or "idle" )
        self:SetSequence( anim )
        self:ResetSequence(anim)
        self:ResetSequenceInfo()
    end

    function ENT:bulletImpactEffect(impactPoint, impactNormal)
        local effectdata = EffectData()
        effectdata:SetNormal(impactNormal)
        effectdata:SetOrigin(impactPoint)
        util.Effect( "AR2Impact", effectdata) 
    end

    function ENT:Flicker()
        timer.Create( "RUIN " .. "shield_flicker_timer" .. tostring(self), .02, 24, function() 
            if !IsValid(self) then return end
            local color = self:GetColor()
                
            if(self.colorModulate == false)then
                color.a = math.abs(math.sin(CurTime()) * 100)
                self:SetColor(color)
            else 
                color.a = 255
                self:SetColor(color)
            end
            self.colorModulate = !self.colorModulate
        end)
    end
    
    function ENT:OnTakeDamage( dmginfo )
        local damage = dmginfo:GetDamage() 
            
        self:EmitSound(forceShieldImpactSounds[math.random(1,4)], 85)
        self:bulletImpactEffect(dmginfo:GetDamagePosition(), self:GetRight())
        self.hp = math.max(0, self.hp - damage)
        self:setColorValueIndex( math.max(0, math.floor(self.hp/2)) ) -- This way cant pick out of bounds
            
        self:SetModelScale(.995, .05)
        timer.Simple(.05, function() 
            if (IsValid(self)) then 
                self:SetModelScale(1,.05) 
            end 
        end)
    
        if(self.hp <= 0) then
            self:Flicker()
            self:EmitSound("ambient/levels/labs/electric_explosion5.wav", 100)
            self:StopSound("ambient/machines/combine_shield_touch_loop1.wav")
            timer.Simple(.48,function()
                if(IsValid(self)) then self:Remove() end
            end)
        end
        -- At the point the ENT:Flicker function is called, the shield's HP will be 0. 
        -- So if we don't cancel the coloring code if shield HP is below 0 the shield will be white since 
        -- the shield's color lookup table doesn't index below 0, which is where we retrieve color values 
        -- indexed for HP values. (Less memory efficient, more performance efficient)
        self:SetColor(HPColorValues[self:getColorValueIndex()])
    end
end    

if CLIENT then
    local shieldPos
    local shieldAngle
    local timeRemaining
    local shieldHP = 80
    local color_green = Color(130,248,181, 200)

    surface.CreateFont("Ruin_Shield_Holo_1" , {
        font = "Kenney Future Square", -- Name of font.
        size = 30,
        weight = 500,
        blursize = 0;
        scanlines = 2,
        antialias = false,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = true,
        additive = true,
        outline = false
    })
    
    local shieldLightUpdateDelay = CurTime()
    function ENT:Draw()
        shieldPos = self:GetPos()
        shieldPos.z = shieldPos.z + 90
        shieldAngle = self:GetAngles()
        shieldAngle = Angle(0, shieldAngle.y, 90)
        timeRemaining = math.Round(self.totalLifeTime - (CurTime() - self:GetCreationTime()))

        self:DrawModel()

        -- Render shield lifetime on the shield.
        cam.Start3D2D( shieldPos, shieldAngle, .65 )
            draw.SimpleText( timeRemaining, "Ruin_Shield_Holo_1", 0, 0, color_green, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()


        -- Update shield light.
        if !IsValid(self.shieldLight) then return end
        if LocalPlayer().options.enableLamps == false then return end 
        if shieldLightUpdateDelay > CurTime() then return end
        shieldLightUpdateDelay = CurTime() + 0.05

		self.shieldLight:SetColor(HPColorValues[self:getColorValueIndex()])
		self.shieldLight:SetFOV( math.random(150,155))
		self.shieldLight:Update()
    end

    function ENT:Initialize()
        self:SetRenderBounds( Vector(-512,-512,-512), Vector(512,512,512) )
        -- Create the shield light.
        if LocalPlayer().options.enableLamps == false then return end 
        self.shieldLight = ProjectedTexture()
        self.shieldLight:SetTexture( "effects/flashlight/soft" )
        self.shieldLight:SetColor(HPColorValues[40])
        self.shieldLight:SetFarZ( 400 )
        self.shieldLight:SetNearZ ( 60 )
        self.shieldLight:SetFOV( math.random(150,155) )
        self.shieldLight:SetBrightness( 1 )
        self.shieldLight:SetEnableShadows ( true )
        self.shieldLight:SetPos( self:GetPos() + Vector(0,0,64) )
        self.shieldLight:SetAngles( Angle(90,0,0) )
        self.shieldLight:Update()

        -- 0.48 Is the delay time after the lifetime of the shield is over where it flickers. We still need the light active during this time.
        timer.Simple(self.totalLifeTime + 0.48,function() 
            if(IsValid(self.shieldLight)) then self.shieldLight:Remove() end
        end)
    end

    function ENT:OnRemove()
        if IsValid(self.shieldLight) then self.shieldLight:Remove() end
    end
end

