AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ruin Weapon Use Radius"
ENT.Author = "Trench"
ENT.Purpose = "The use radius for Ruin Weapons, attached to the ruin stand in weapons as a parented ent and controls the use behavior for that entity"
ENT.Spawnable = false
ENT.Category = "Other"

local pickUpSound = {
    [1] = "ruin/weapons/STNG-R/STNG-R_reload_01.ogg",
    [2] = "ruin/weapons/GR-50/GR-50_reload_03.ogg",
    [3] = "ruin/weapons/SXV-3/SXV-3_reload_01.ogg",
    [4] = "weapons/357/357_spin1.wav" -- Not used since 357 is not used.
}

if SERVER then
    
    util.AddNetworkString( "RUIN Pickup Weapon Sound" )
    util.AddNetworkString( "RUIN Clear Pistol Reload Laser Disable" )
    util.AddNetworkString( "RUIN Notify Player Draw Holstered Weapon Post Weapon Pickup" )

    function ENT:Initialize()
        self:SetModel( "models/hunter/misc/sphere075x075.mdl" )
        self:PhysicsInit(SOLID_VPHYSICS) -- Must create this before SetSolid()
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_WORLD)
        self:PhysWake()
        self:SetUseType( SIMPLE_USE ) 
        --self:SetMaterial("models/wireframe")
        --self:SetNoDraw( true )
        self:GetPhysicsObject():SetMass(1)
    end

end

function ENT:Use( activator )    
    if SERVER then 

        if !IsValid(activator) or !activator:IsPlayer() or self:GetParent():getMagCount() <= 0 then return end

        if activator:hasPrimary() then
            RUIN.dropWeapon(activator, activator:activeWeaponClass(), activator:getPrimaryMag(), true, self:GetParent())
        end
        activator:setPrimaryMag(self:GetParent():getMagCount()) --Should equal self.magMax if it was never picked up
        activator:Give(self:GetParent():getRealClassName(), true)
        activator:setHasPrimary(true)
        activator:setHasPrimaryEquipped(true)
        activator:setActiveWeaponClass(self:GetParent():getRealClassName())
        activator:SelectWeapon(self:GetParent():getRealClassName())
        activator:GetActiveWeapon():SetClip1(activator:getPrimaryMag())
        self:Remove()
        self:GetParent():Remove()
        net.Start("RUIN Clear Pistol Reload Laser Disable")
        net.Send(activator)
        net.Start("RUIN Pickup Weapon Sound")
        net.WriteUInt(self:GetParent():getPickUpSoundIndex(), 3)
        net.Send(activator)
        net.Start("RUIN Notify Player Draw Holstered Weapon Post Weapon Pickup")
        net.Send(activator)

    end
end

if CLIENT then 

    function ENT:Draw()
        --self:DrawModel()
    end

    net.Receive("RUIN Notify Player Draw Holstered Weapon Post Weapon Pickup", function()
        LocalPlayer():drawHolsteredWeapon(true) 
    end)

    net.Receive("RUIN Pickup Weapon Sound", function()
        local soundIndex = net.ReadUInt(3)
        surface.PlaySound(pickUpSound[soundIndex])
    end)

    net.Receive("RUIN Clear Pistol Reload Laser Disable", function()
        if ( !IsValid(LocalPlayer()) ) then return end
        LocalPlayer().isReloadingPistol = false -- This when if player is mid-pistol reload and picks up a weapon laser will appear
    end)

end

