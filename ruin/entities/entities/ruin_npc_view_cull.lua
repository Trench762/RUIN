AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ruin NPC View Cull"
ENT.Author = "Trench"
ENT.Purpose = "An invisible cylinder put around the player to disable npc engagement past a radius around the player."
ENT.Spawnable = false
ENT.Category = "Other"
ENT.shouldLaserIgnore = true

if SERVER then
    function ENT:Initialize()
        self:DrawShadow( false )
        self:SetModel( "models/ruin/misc/ruin_npc_view_cull.mdl" )
        self:PhysicsInit(SOLID_VPHYSICS) -- Must create this before SetSolid().
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup( COLLISION_GROUP_WEAPON )  
        self:PhysWake()
        self:GetPhysicsObject():EnableMotion(false)
    end
end

function ENT:Use( activator )    
    return
end

if CLIENT then 
    function ENT:Draw()
        --self:DrawModel()
        return
    end
end
