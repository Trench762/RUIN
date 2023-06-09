function eMeta:setIsVisibleToPlayer(bool)
    self:SetNWBool('isVisibleToPlayer', bool )
end

function eMeta:isVisibleToPlayer()
    return self:GetNWBool('isVisibleToPlayer', false)
end

if !SERVER then return end

local function avoidPlayerAim(npc, enemy) 
    if !IsValid(enemy) or !IsValid(npc) then return end
    if npc:GetActiveWeapon():GetClass() == "weapon_stunstick" then return end
    
    local tr = enemy:GetEyeTrace() 
	local ent = tr.Entity 

    if npc == ent then
        local movePos 

        if(math.random(1,2) == 1) then
            movePos = ent:GetPos() + (enemy:GetRight() * math.random(48, 96))
        else
            movePos = ent:GetPos() + (enemy:GetRight() * math.random(-48, -96))
        end

        npc:SetLastPosition( movePos )
        npc:SetSchedule( SCHED_FORCED_GO_RUN )
        npc.justMovedFromAim = true
        timer.Simple(.5, function()
            npc.justMovedFromAim = false
        end)
    end
end

local function aiSneak(npc, enemy)
    if !npc.delayMovement then
        npc.delayMovement = CurTime()
    end

    if !IsValid(enemy) or !IsValid(npc) then return end
    if npc:GetNPCState() != NPC_STATE_COMBAT then return end -- Don't run all this complex npc code if they arent in combat.
    
    if npc:GetActiveWeapon():GetClass() == "weapon_stunstick" then 
        if npc.delayMovement > CurTime() then return end
        npc.delayMovement = npc.delayMovement + 0.1       
        
        if npc:GetSequenceName(npc:GetSequence()) == "run_all" then 
            return      
        else
            npc:SetLastPosition( enemy:GetPos() )
            npc:SetSchedule( SCHED_FORCED_GO_RUN )
            return
        end  
    end

    -- If the npc is visible tell them to start running again.
    if npc:isVisibleToPlayer() then 
        npc:SetMovementActivity(ACT_RUN_AIM)
        return 
    end

    -- If they arent a stealth soldier then no point to continue.
    if !npc.stealthSoldier then return end
    -- If they arent running e.g. they are probably walking, no point to run the rest of the code.
    if !npc:GetMovementActivity() == ACT_RUN  or !npc:GetMovementActivity() == ACT_RUN_AIM then return end  

    local npcWeapon = npc:GetActiveWeapon():GetClass()
    
    if (npcWeapon == "weapon_smg1" or npcWeapon == "weapon_ar2") then 
        npc:SetMovementActivity( ACT_WALK_AIM_RIFLE ) 
    end

    if (npcWeapon == "weapon_shotgun") then 
        npc:SetMovementActivity( ACT_WALK_AIM_SHOTGUN ) 
    end

    if (npcWeapon == "weapon_pistol") then 
        npc:SetMovementActivity(ACT_WALK_AIM_PISTOL) 
    end
end

local function pickStealthSoldiers(npc)
    if !IsValid(npc) then return end
    local npcCount = 0

    for k, v in pairs(ents.FindByClass("npc_combine_s")) do
        npcCount = npcCount + 1
    end

    for k, v in pairs(ents.FindByClass("npc_metropolice")) do
        npcCount = npcCount + 1
    end

    -- The more npcs there are, the greater chance of being a stealth soldier.
    local chance = 0

    if    (npcCount > 4) then  chance = 50
    elseif(npcCount > 2) then  chance = 30
    elseif(npcCount > 1) then  chance = 10 
    end
    
    if(math.random(0, 100) < chance) then
        npc.stealthSoldier = true
    else
        npc.stealthSoldier = false
    end
end

local function delayShootingProficiencyNoTarget(npc)
    if !IsValid(npc) then return end
    if npc:GetNPCState() != NPC_STATE_COMBAT then return end --Don't run all this complex npc code if they arent in combat
    if npc:GetActiveWeapon():GetClass() == "weapon_stunstick" then return end
    if timer.Exists(tostring(npc) .. "delay shooting proficiency ease up first phase" ) then return end
    if timer.Exists(tostring(npc) .. "delay shooting proficiency ease up second phase" ) then return end
    --Make it so the npc's aim skill is 1 when they have no sight of the player and when they initially see them, it takes .1 seconds
    --For them to get to skill level 2, after that they will level up by 1 every .5 seconds 
    --Meaning it will take 1.1 seconds to reach max aim skill after seeing an enemy. 
    --Obviously this resets every time they lose line of sight.
    if npc:isVisibleToPlayer() then 
        timer.Create("RUIN " .. tostring(npc) .. "delay shooting proficiency ease up first phase", .1, 1, function() 
            if !IsValid(npc) then return end
            --This is needed so we don't keep re-running the skill level code when they are at max.
            if npc:GetCurrentWeaponProficiency() == 4 then return end 
            npc:SetCurrentWeaponProficiency(2)
            
            timer.Create("RUIN " .. tostring(npc) .. "delay shooting proficiency ease up second phase", .5, 2, function() 
                if !IsValid(npc) then return end
                local skill = npc:GetCurrentWeaponProficiency()
                npc:SetCurrentWeaponProficiency(skill + 1)
            end)
        end)
    else
        npc:SetCurrentWeaponProficiency( 1 )
        timer.Remove("RUIN " .. tostring(npc) .. "delay shooting proficiency ease up first phase" )
        timer.Remove("RUIN " .. tostring(npc) .. "delay shooting proficiency ease up second phase" )
    end
end

local function ruinNPC(npc)
    if !IsValid(npc) then return end
    if npc:GetNPCState() != NPC_STATE_COMBAT then return end --Don't run all this complex npc code if they arent in combat
    
    local enemy = npc:GetEnemy()            --Get the npc's enemy
    if !IsValid(enemy) then return end      --If they don't have one return
    if !enemy:IsPlayer() then return end    --If the enemy isn't a player return
    
    if !npc.justMovedFromAim then 
        avoidPlayerAim(npc, enemy)
    end

    aiSneak(npc, enemy)
    delayShootingProficiencyNoTarget(npc)
end

hook.Add("Think", "RUIN AI Behavior", function()
    for k, v in pairs(ents.FindByClass("npc_metropolice")) do
		if !IsValid(v) then return end
        ruinNPC(v)
	end
    
    for k, v in pairs(ents.FindByClass("npc_combine_s")) do
		if !IsValid(v) then return end
        ruinNPC(v)
	end
end)

hook.Add("OnEntityCreated", "RUIN AI Behavior On NPC Spawn", function(ent)
    if !IsValid(ent) or !ent:IsNPC() or ent:IsPlayer() then return end
    
    --Give npcs a bit of time to leave spawn before choosing whether they are a stealthy npc or not
    timer.Simple(3, function() 
        for k, v in pairs(ents.FindByClass("npc_combine_s")) do
            pickStealthSoldiers(v)
        end
    
        for k, v in pairs(ents.FindByClass("npc_metropolice")) do
            pickStealthSoldiers(v)
        end
    end)

    --Set their Proficiency to the RUIN's default
    timer.Simple(.1, function() 
        if !IsValid(ent) then return end
        ent:SetCurrentWeaponProficiency( 1 )
    end)
end)

hook.Add("OnNPCKilled", "RUIN AI Behavior On NPC Killed", function(npc)
    timer.Simple(.1, function()
        for k, v in pairs(ents.FindByClass("npc_combine_s")) do
            pickStealthSoldiers(v)
        end
    
        for k, v in pairs(ents.FindByClass("npc_metropolice")) do
            pickStealthSoldiers(v)
        end
    end)
end)