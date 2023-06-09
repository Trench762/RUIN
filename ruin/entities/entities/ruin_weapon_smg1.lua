AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ruin Weapon SMG"
ENT.Author = "Trench"
ENT.Purpose = "A stand in weapon entity for the SMG, only to be used in Ruin"
ENT.Spawnable = false
ENT.Category = "Other"
ENT.magMax = 45 -- Used for setting initialize ammo and weapon halo rendering in sh_weapon_system.lua
ENT.pickUpSoundIndex = 1

function ENT:setMagCount(number)
    self:SetNWInt('magCount', number )
end

function ENT:getMagCount()
    return self:GetNWInt('magCount', 0)
end

function ENT:setRealClassName(name)
    self:SetNWString('realClassName', name )
end

function ENT:getRealClassName()
    return self:GetNWString('realClassName', "weapon_smg1")
end

function ENT:setFromCrate(bool)
    self:SetNWBool('fromCrate', bool )
end

function ENT:fromCrate()
	return self:GetNWBool('fromCrate', false)
end

function ENT:setPickUpSoundIndex(number)
    self:SetNWInt('pickUpSoundIndex', number )
end

function ENT:getPickUpSoundIndex()
    return self:GetNWInt('pickUpSoundIndex', 1)
end


if SERVER then
    
    function ENT:Initialize()
        self:SetModel( "models/ruin/weapons/stng-r.mdl" )
        self:PhysicsInit(SOLID_VPHYSICS) --Must create this before SetSolid
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        self:PhysWake()
        self:setMagCount(self.magMax)
        self:SetUseType( SIMPLE_USE ) --FUCKING CUM
        self:setRealClassName("weapon_smg1")
        self:setPickUpSoundIndex(1)
        local useRadius = ents.Create("ruin_wep_use_radius")
        useRadius:SetPos(self:GetPos())
        useRadius:SetParent(self)
        useRadius:Spawn()
        useRadius:Activate()
    end

end

-- This is done via a proxy: ruin_wep_use_radius this way it's easier to pickup weapons (using a parented ent with a bigger collision model)
function ENT:Use( activator )    
    return
end

if CLIENT then 

    function ENT:Draw()
        self:DrawModel()
    end

end



