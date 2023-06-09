AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ruin Weapon Pistol"
ENT.Author = "Trench"
ENT.Purpose = "A stand in weapon entity for the Grenade, only to be used in Ruin"
ENT.Spawnable = false 
ENT.Category = "Other"

if SERVER then

    function ENT:Initialize()
        self:SetModel( "models/weapons/w_grenade.mdl" )
        self:PhysicsInit(SOLID_VPHYSICS) -- Must create this before SetSolid().
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        self:PhysWake()
        self:SetUseType( SIMPLE_USE ) 
    end
    
end

function ENT:Use( activator )    
    return
end

if CLIENT then 

    function ENT:Draw()
        self:DrawModel()
    end

end
