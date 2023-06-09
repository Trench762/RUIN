AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ruin Weapon Crate"
ENT.Author = "Trench"
ENT.Purpose = "A weapon crate that drops a random weapon when used"
ENT.Spawnable = false
ENT.Category = "Other"

if SERVER then

    local weapons = {
        [1] = "ruin_weapon_ar2",
        [2] = "ruin_weapon_shotgun",
        [3] = "ruin_weapon_smg1"
    }

    function ENT:SpawnWeapon()
        local weapon = ents.Create(weapons[math.random(1,3)])
        local angles = self:GetAngles()
        weapon:SetPos(self:GetPos() + Vector(0,0,24))
        weapon:SetAngles(angles)
        weapon:Spawn()
        weapon:setFromCrate(true)
        local wepAngles = weapon:GetAngles()
        wepAngles.roll = wepAngles.roll + 90
        weapon:SetAngles(wepAngles)
        weapon:SetMoveType(MOVETYPE_NONE)
        weapon:SetSolid(SOLID_VPHYSICS)
        weapon:GetPhysicsObject():RotateAroundAxis( Vector(1, 0, 0), 90 )
        weapon:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        weapon:SetUseType( SIMPLE_USE ) 
    end

    function ENT:Initialize()
        self:SetModel( "models/ruin/high_tech/weapon_crate_01.mdl" )
        self:PhysicsInit(SOLID_VPHYSICS) -- Must create this before SetSolid()
        self:SetMoveType(MOVETYPE_NONE) -- Must be called after PhysicsInit()
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:GetPhysicsObject():EnableMotion(false)
        self:SetUseType( SIMPLE_USE ) 
        self:SpawnWeapon()
    end

    function ENT:UpdateTransmitState()        
        return TRANSMIT_ALWAYS
    end 
end

if CLIENT then 

    function ENT:Initialize()
        self:SetRenderBounds( Vector(-512,-512,-512), Vector(512,512,512) )
    end

    function ENT:Draw()
        self:DrawModel()
    end

end

