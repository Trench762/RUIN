AddCSLuaFile()
if SERVER then
util.AddNetworkString("RUIN Micro Missle Notify Client Draw Flash")
end
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ruin micro missile"
ENT.Author = "Slaugh7er"
ENT.Purpose = ""
ENT.Spawnable = true
ENT.Category = "Other"

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel("models/Items/AR2_Grenade.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:PhysWake()
    self:Fire("kill", "", 10)

    self:SetTrigger( true )
    self:UseTriggerBounds( true, 1 )

    timer.Simple(0, function()
        if not IsValid(self) then return end
        local phys = self:GetPhysicsObject()
        phys:SetVelocity(self:GetForward() * 256)
    end)
    
    util.SpriteTrail(self, 0, Color(255, 100, 100), true, 3, 0, .115, 1, "trails/plasma")
    
    -- If done here would make it so missiles come out as dummies first.
    timer.Simple(.175, function()
        if not IsValid(self) then return end
        util.SpriteTrail(self, 0, Color(255, 100, 100), true, 3, 0, 0.01, 1, "trails/plasma")
        self.ACTIVE = true 
    end)

    timer.Simple(1.25, function()
        if !IsValid(self) then return end
        self:Explode()
    end)
end

local explosionRadius = 64
local explosionDamage = 8

function ENT:Explode()
    if self.EXPLODED then return end
    self.EXPLODED = true
    -- Explosion code.
    self:SetMoveType(MOVETYPE_NONE)
    self:SetNotSolid(true)
    self:SetNoDraw(true)
    local t = EffectData()
    t:SetOrigin(self:WorldSpaceCenter())
    util.Effect("ruin_micro_missile_explode", t)

    for _, e in pairs(ents.FindInSphere(self:WorldSpaceCenter(), explosionRadius)) do
        if not e.TakeDamageInfo then continue end
        local t = DamageInfo()
        t:SetAttacker(self.OWNER or NULL)
        t:SetInflictor(self)
        local damage = explosionDamage
        if e.IsPlayer and e:IsPlayer() then
            damage = damage / 10
        end

        t:SetDamage(damage)
        t:SetDamagePosition(self:WorldSpaceCenter())
        e:TakeDamageInfo(t)
    end

    -- This is bad but I don't feel like re-writing the entire entity structure.
    net.Start("RUIN Micro Missle Notify Client Draw Flash")
    net.WriteVector(self:GetPos())
    net.Broadcast()

    self:EmitSound("phx/kaboom.wav", 100, 700, 1, CHAN_REPLACE, 0)
    -- Explosion code.
    -- Allow trail to timeout.
    timer.Simple(1, function()
        if IsValid(self) then
            self:Remove()
        end
    end)
end

local noCollideClasses = {
    player = true,
    ruin_micro_missile = true,
    ruin_npc_view_cull = true,
}

function ENT:StartTouch(e)
    -- local c = e:GetClass()
    -- if noCollideClasses[c] then return end
    -- print(self, "collided with", e, c)
    -- self:Explode()
end

function ENT:PhysicsCollide(t, phys)
    local e = t.HitEntity
    if IsValid(e) then return end
    self.collisionPosition = t.HitPos
    -- if IsValid(e) then
    -- if e.IsPlayer and e:IsPlayer() then return end
    -- else
    -- self:Explode()
    -- end
end

function ENT:Think()
    if CLIENT then return end
    if not self.ACTIVE then return end

    if self.collisionPosition then
        self:SetPos(self.collisionPosition)
        self:Explode()
    end

    local e = self:GetTargetEntity()

    if IsValid(e) then
        self:SetTargetVector(e:WorldSpaceCenter())
    end

    local v = self:GetTargetVector() 
    
    local a = self:GetAngles() 
    local aa = (v-self:WorldSpaceCenter()):Angle()
    local turnSpeed = 24 -- Influences speed.
    a.p = math.ApproachAngle( a.p, aa.p, turnSpeed )
    a.y = math.ApproachAngle( a.y, aa.y, turnSpeed )
    a.r = math.ApproachAngle( a.r, aa.r, turnSpeed )
    local wiggle = 4
    a.p = a.p + math.random(-wiggle,wiggle)
    a.y = a.y + math.random(-wiggle,wiggle)
    a.r = a.r + math.random(-wiggle,wiggle)
    self:SetAngles(a)
    local phys = self:GetPhysicsObject()
    phys:SetVelocity(self:GetForward() * phys:GetMass() * 160) -- Influences speed. (Modify turnspeed aswell to increase speed)
    self:NextThink(CurTime() + .05)

    if self:GetPos():DistToSqr(self:GetTargetVector()) < 4096 then -- Actual distance = 64.
        self:Explode()
    end

    return true
end

function ENT:Draw()
    self:DrawModel()
    -- render.DrawLine( self:WorldSpaceCenter(), self:GetTargetVector(), Color( 255, 255, 255 ) )
end

function ENT:SetTargetEntity(e)
    self:SetNWEntity("targetentity", e or NULL)
end

function ENT:GetTargetEntity()
    return self:GetNWEntity("targetentity")
end

function ENT:SetTargetVector(v)
    self:SetNWVector("targetvector", v or nil)
end

function ENT:GetTargetVector()
    return self:GetNWVector("targetvector", self:GetPos() + self:GetForward() + Vector(0, 0, -2))
end

if CLIENT then
    local matCircle = Material("ruin/misc/circle_01.png")
    local EFFECT = {}
    EFFECT.Render = function() end

    function EFFECT:Init(t)
        local e = ParticleEmitter(t:GetOrigin())

        timer.Simple(0, function()
            e:Finish()
        end)

        -- core
        for i = 1, 1 do
            local p = e:Add(matCircle, t:GetOrigin())

            if (p) then
                p:SetDieTime(.1)
                p:SetStartAlpha(math.random(100,150))
                p:SetEndAlpha(0)
                p:SetStartSize(0)
                p:SetEndSize(math.random(16,32))
                p:SetColor(255, 100, 100)
            end
        end

        -- energy particles
        for i = 1, 6 do
            local p = e:Add("effects/blueflare1", t:GetOrigin() + VectorRand() * 16)

            if (p) then
                p:SetDieTime(4)
                p:SetAirResistance(32)
                p:SetStartAlpha(150)
                p:SetEndAlpha(0)
                p:SetStartSize(0)
                p:SetEndSize(3)

                timer.Simple(2, function()
                    p:SetStartSize(3)
                    p:SetEndSize(0)
                end)

                p:SetVelocity(VectorRand() * 16)
                p:SetGravity(VectorRand() * 2)
                p:SetCollide(true)
                p:SetBounce(0)
                p:SetRoll(math.Rand(-8, 8))
                p:SetColor(255, 100, 100)
            end
        end
    end

    effects.Register(EFFECT, "ruin_micro_missile_explode")
end

if CLIENT then
    net.Receive("RUIN Micro Missle Notify Client Draw Flash", function()
        if LocalPlayer().options.enableLamps == false then return end 
        local missilePos = net.ReadVector()
        local flash = ProjectedTexture()

        flash:SetTexture( "effects/flashlight/soft" )
        flash:SetColor( Color(250, 25, 25) )
        flash:SetFarZ( 400 )
        flash:SetNearZ ( 60 )
        flash:SetFOV( math.random(70,100) )
        flash:SetBrightness( math.random(5,10) )
        flash:SetEnableShadows ( true )

        flash:SetPos( missilePos + Vector(0,0,64))
        flash:SetAngles( Angle(90,0,0) )
        flash:Update()
        timer.Simple( 0.025, function() flash:Remove() end)
    end)
end
