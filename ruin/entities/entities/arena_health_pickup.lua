AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "arena_health_pickup"
ENT.Author = "Trench"
ENT.Purpose = "heals you"

if SERVER then
    function ENT:StartTouch( ent )
        if !ent:IsValid() then return end
        if !ent:IsPlayer() then return end
        
        local hp = ent:Health()
        local giveHP = math.Remap(hp, 0, ent:GetMaxHealth(), ent:GetMaxHealth() * .2, ent:GetMaxHealth() * .025)
        ent:SetHealth(math.Clamp(ent:Health() + giveHP, 0, ent:GetMaxHealth()))
        ent:ConCommand( "healPulse" )
        self:EmitSound("buttons/button9.wav", 150, 200)
        self:Remove()
    end

    function ENT:Initialize()
        self:SetModel( "models/ruin/misc/health_pickup.mdl" )
        self:SetMaterial("ruin/misc/blue3")
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        self:PhysWake()
        self:SetTrigger( true )
        self:DrawShadow(false)
    end
end    
