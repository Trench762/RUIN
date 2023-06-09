if tonumber(RUIN.mapSettings["mode"]) == 0 then return end 

-- TODO: CHANGE THIS WHEN CHANGING ENEMY MODELS
util.PrecacheModel("models/Combine_Super_Soldier.mdl")
util.PrecacheModel("models/Combine_Soldier_PrisonGuard.mdl")
util.PrecacheModel("models/Combine_Soldier.mdl")
util.PrecacheModel("models/Police.mdl")
util.AddNetworkString("Update Player Arena Kills")

local DEBUG = false
local curMaxEnemiesAllowed = 4
local curEnemiesKilled = 0
local curEnemiesOnField = 0
local nextThink = CurTime()
local stunStickEnemies = 0
RUIN.gameStarted = false

local enemiesCombine = {
    "npc_metropolice",
    "npc_combine_s"
}

local weaponsMetroPolice = {
    "weapon_pistol",
    "weapon_smg1",
    "weapon_stunstick"
}

local weaponsMetroPoliceNoStunStick = {
    "weapon_pistol",
    "weapon_smg1",
}

local weaponsCombine = {
    "weapon_smg1",
    "weapon_ar2",
}

local function findNPCSpawn()
    local camperSpawnDistanceAdjustment = 1
    local farthestSpawn = 0
    local minDistance = 32768
    local maxDistance = 32768
    local spawn = nil
    local potentialSpawns = {}
    if !IsValid(Entity(1)) then return end
    local plyPos = Entity(1):GetPos()
    
    -- Find the furthest spawn at the current moment
    for k, v in pairs(RUIN.arenaNpcSpawnPoints) do
        if plyPos:Distance( v ) > farthestSpawn then
            farthestSpawn = plyPos:Distance( v )
            minDistance = farthestSpawn * 0.75
        end
    end

    -- Find spawn points that are also decently far relative to the furthest spawn
    for k, v in pairs(RUIN.arenaNpcSpawnPoints) do
        if  plyPos:Distance( v ) > minDistance then
            -- Make sure player can't see enemies spawn
            if Entity(1):IsLineOfSightClear( v ) then continue end
            -- Make sure we don't spawn it where an npc already is
            
            local localEnts = ents.FindInSphere( v, 128 ) 
            local spawnBlocked 
            
            for k, v in pairs(localEnts) do
                if v:IsNPC() then spawnBlocked = true end
            end
            
            if spawnBlocked then continue end
            
            table.insert(potentialSpawns, v)
        end
    end

    --Pick a random spawn from the potential spawns
    spawn = table.Random(potentialSpawns)
    return spawn
end

local plyAnchorPos = Vector(0,0,999999)

hook.Add("Think", "RUIN Arena Mode Think", function()
    if !RUIN.gameStarted then return end
    if nextThink > CurTime() then return end
    nextThink = CurTime() + 1

    curEnemiesOnField = 0
    for k, v in pairs(ents.FindByClass("npc_*")) do
        if !IsValid(v) then continue end
        if !IsValid(Entity(1)) then continue end
        if v:GetClass() == "npc_grenade_frag" then continue end -- Grenades don't have dispostion, need to find a better, more general fix for this.
        if v:Disposition( Entity(1) ) != D_HT then continue end -- If it's not an enemy it's not counted.
        curEnemiesOnField = curEnemiesOnField + 1

        --Make NPC's seek player at all times
        v:UpdateEnemyMemory( Entity(1), Entity(1):GetPos() )
    end

    if curEnemiesOnField < curMaxEnemiesAllowed then
        local pos = findNPCSpawn()
        if !pos then return end

        local enemy = ents.Create( table.Random(enemiesCombine) ) 
        enemy:SetPos(pos)
        
        if ( enemy:GetClass() == "npc_combine_s" ) then
            enemy:Give( table.Random(weaponsCombine) )
            enemy:SetKeyValue( "NumGrenades", math.random(0,2) )
        elseif ( enemy:GetClass() == "npc_metropolice" ) then
            if stunStickEnemies >= math.Round(curMaxEnemiesAllowed * 0.2, 0) then 
                enemy:Give( table.Random(weaponsMetroPoliceNoStunStick) )
            else
                enemy:Give( table.Random(weaponsMetroPolice) )
            end
        end

        enemy:Spawn()
        if enemy:GetActiveWeapon():GetClass() == "weapon_stunstick" then
            stunStickEnemies = stunStickEnemies + 1
        end
        
        if DEBUG then
            enemy:Remove()
            debugoverlay.Box( pos, Vector(-8,-8,-8), Vector(8,8,8), 1, Color( 58, 255, 23) )
            for k, v in pairs(RUIN.arenaNpcSpawnPoints) do
                if v == pos then continue end
                debugoverlay.Box( v, Vector(-8,-8,-8), Vector(8,8,8), 1, Color( 121, 119, 19, 1) )
            end
        end
    end 
end)

hook.Add("OnNPCKilled", "RUIN Arena Detect Enemy Killed", function(npc, attacker, inflictor)
    if !IsValid(npc) then return end
    if npc:Disposition( Entity(1) ) != D_HT then return end -- If it's not an enemy it's not counted.
    if attacker != Entity(1) then return end -- Don't count it if the player didn't kill them.

    curEnemiesKilled = curEnemiesKilled + 1
    curMaxEnemiesAllowed = 4 + math.floor((curEnemiesKilled / 30), 0)
    if npc:GetActiveWeapon() == "weapon_stunstick" then
        stunStickEnemies = stunStickEnemies - 1
    end

    net.Start("Update Player Arena Kills")
    net.WriteUInt(curEnemiesKilled, 12) -- If they kill more than 4095 this will be a problem.
    net.Broadcast()

    if DEBUG then
        print("Enemies Killed: " .. tostring(curEnemiesKilled))
        print("Enemies Allowed: " .. tostring(curMaxEnemiesAllowed))
    end

    for i = 1, math.random(3,4) do
        local npcPos = npc:GetPos() + Vector(0,0,64)
        timer.Simple(i/20, function()
            local healthOrb = ents.Create("arena_health_pickup")
            healthOrb:SetPos(npcPos)
            healthOrb:Spawn()
            
            local phys = healthOrb:GetPhysicsObject()
            phys:ApplyForceCenter(Vector(math.random(-512,512), math.random(-512,512), math.random(1440,2048)))
            util.SpriteTrail( healthOrb, 0, Color(58,255,255), true, 10, 4, .2, 1 / ( 10 + 4 ) * 0.5, "trails/laser" )
    
            timer.Create(tostring(healthOrb), 1.5, 1, function()
                if !IsValid(healthOrb) then return end
                healthOrb:Remove()
            end)
        end)
    end
end)

hook.Add("PostCleanupMap", "RUIN Arena Post Cleanup", function() 
    Entity(1).lastPlyAnchorPosUpdate = 0
    curEnemiesKilled = 0
    curMaxEnemiesAllowed = 4
    net.Start("Update Player Arena Kills")
    net.WriteUInt(0, 12) -- If they kill more than 4095 this will be a problem.
    net.Broadcast()
end)

local ply
local nextThink2 = CurTime()
hook.Add("Think", "RUIN Arena Player Health Pickup Vacuum", function()
    ply = Entity(1)
    if !IsValid(ply) then return end
    if !ply:Alive() then return end
    if nextThink2 > CurTime() then return end
    nextThink2 = CurTime() + 0.1

    for k, v in pairs(ents.FindByClass("arena_health_pickup")) do
        local dist = v:GetPos():Distance(ply:GetPos())
        local distDifference = (Entity(1):WorldSpaceCenter() - v:GetPos()):GetNormalized()
        local physicsObject = v:GetPhysicsObject()

        if dist > 192 then continue end
        if !IsValid(physicsObject) then continue end

        physicsObject:ApplyForceCenter(physicsObject:GetVelocity() * -0.5)
        physicsObject:ApplyForceCenter((distDifference * math.Remap(dist, 0, 256, 256, 0)) * physicsObject:GetMass())

        if v.resetRemoveTimer then continue end
        timer.Create(tostring(v), 1.5, 1, function()
            if !IsValid(v) then return end
            v:Remove()
        end)
        v.resetRemoveTimer = true 
    end
end)