AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ruin Weapon Station"
ENT.Author = "Trench"
ENT.Purpose = "A station that spawns and regenerates weapons"
ENT.Spawnable = false
ENT.Category = "Other"

if SERVER then

    local weapons = {
        [1] = "ruin_weapon_ar2",
        [2] = "ruin_weapon_shotgun",
        [3] = "ruin_weapon_smg1"
    }

    local weaponModelLookup = {
        ["ruin_weapon_ar2"] = "models/ruin/weapons/sxv-3.mdl", 
        ["ruin_weapon_shotgun"] = "models/ruin/weapons/gr-50.mdl",
        ["ruin_weapon_smg1"] = "models/ruin/weapons/stng-r.mdl"
    }

    function ENT:PickWeaponToGenerate()
        self.pickWeapon =  weapons[math.random(1,3)]
    end

    function ENT:SetState( state ) -- 1 == "ready" or 0 == "generating"
        self.state = state
    end

    function ENT:GetState()
        return self.state
    end

    function ENT:Initialize()
        self:SetModel( "models/ruin/high_tech/weapon_station_01.mdl" )
        self:PhysicsInit(SOLID_VPHYSICS) -- Must create this before SetSolid()
        self:SetMoveType(MOVETYPE_NONE) -- Must be called after PhysicsInit()
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
        self:GetPhysicsObject():EnableMotion(false)
        self:DrawShadow(false)
        self:PickWeaponToGenerate()
        self:SetState( 1 )
    end

    local nextGenerateIncrement = CurTime()

    function ENT:Think()
        -- Weapon is being generated.
        if self:GetState() == 0 then 
            if !self.generatingWeapon or self.generatingWeapon == NULL then
                self.timeReady = CurTime() + 30
                self.generatingWeapon = ents.Create("prop_dynamic")
                self.generatingWeapon:SetModel(weaponModelLookup[self.pickWeapon])
                self.generatingWeapon:SetMaterial("models/wireframe")
                self.generatingWeapon:DrawShadow(false) 
                self.generatingWeapon:SetPos(self:GetPos() + Vector(0,0,32))
                self.generatingWeapon:Spawn() 
                self.generatingWeapon:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                self.generatingWeapon:SetMoveType(MOVETYPE_NONE)
                self:SetNWEntity( "renderEnt", self.generatingWeapon)
                self.generatingWeapon:SetColor(Color(205,205,205))
            end

            local weaponPos = Vector( 0, 0, math.sin(CurTime() * 3) * 5 )
            self.generatingWeapon:SetPos( ( self:GetPos() + Vector(0,0,32) ) + weaponPos )
            local weaponAngle = (CurTime() * -90) % 360 
            self.generatingWeapon:SetAngles( Angle(0, weaponAngle, 0) )

            local frame = math.Round( math.Remap(self.timeReady - CurTime(), 0, 30, 80, 0), 0 ) 
            
            if frame < 10 then
                frame = "0" .. tostring(frame)
            end

            self:SetSubMaterial(3, "models/ruin/high_tech/weapon_station_01_indicator/img_000" .. frame)

            if CurTime() >= self.timeReady then
                self.state = 1
                self:EmitSound("buttons/button1.wav", 80, 80, 1, CHAN_AUTO)
                self.generatingWeapon:Remove()
            end        
        -- Weapon is ready.
        else                  
            if !self.weapon or self.weapon == NULL then
                self.weapon = ents.Create(self.pickWeapon) 
                self.weapon:SetPos(self:GetPos() + Vector(0,0,32))
                self.weapon:Spawn()
                self.weapon:SetRenderMode(RENDERMODE_TRANSALPHA)
                self.weapon:DrawShadow(false) 
                self.weapon:SetMoveType(MOVETYPE_NONE)
                self.weapon.weaponStation = self
                self:SetNWEntity( "renderEnt", self.weapon )
                
                local color = Color(255,255,255,0)
                timer.Create("RUIN Weapon Station Fade In Ready State", .05, 20, function()
                    if !IsValid(self.weapon) then return end
                    color.a = math.min(255, color.a + 13)
                    self.weapon:SetColor(color)
                end)
            end
            
            local weaponPos = Vector( 0, 0, math.sin(CurTime() * 3) * 5 )
            self.weapon:SetPos( ( self:GetPos() + Vector(0,0,32) ) + weaponPos )
            local weaponAngle = (CurTime() * -90) % 360 
            self.weapon:SetAngles( Angle(0, weaponAngle, 0) )

            self:SetSubMaterial(3, "models/ruin/high_tech/weapon_station_01_indicator/img_00080")
        end

        self:NextThink(CurTime() + 0)
        return true
    end

    function ENT:UpdateTransmitState()        
        return TRANSMIT_ALWAYS
    end

    hook.Add("EntityRemoved", "RUIN Weapon Station Detect Weapon Equip", function(ent)
        if !IsValid(ent) then return end
        if ent.weaponStation then
            ent.weaponStation:PickWeaponToGenerate()
            ent.weaponStation:SetState(0) -- When a weapon is picked up making the weapon generator it was picked up from start generating a new weapon.
        end
    end)
    
end


if CLIENT then 

    function ENT:Initialize()
        self:SetRenderBounds( Vector(-512,-512,-512), Vector(512,512,512) )
    end

    function ENT:Draw()
        self:DrawModel()
    end

end

