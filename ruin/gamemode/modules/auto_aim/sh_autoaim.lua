if CLIENT then
    local DEBUG = false -- SET THIS TO TRUE TO VISUALIZE DEBUGGING, REQUIRED "developer 1" IN CONSOLE
    nextDebugRender = CurTime()
    RUIN.autoAimOverride = false
    RUIN.autoAimTargetPosition = nil

    local traceMins =  Vector( -1, -1, -128 )
    local traceMaxs = Vector( 1, 1, 128 )
    local ply = nil
    local explosiveBarrelAimPoint = Vector(0,0,0)
    local npcAimPoint = Vector(0,0,0)
    local worldSpaceAABBMin = Vector()
    local worldSpaceAABBMax = Vector()
    local vectorHalf = Vector(0.5,0.5,0.5)
    local aimOffset = Vector(1,1,.25)
    local explosives = {
        ["models/ruin/clutter/explosive_barrel_01.mdl"] = true,
        ["models/ruin/clutter/explosive_barrel_02.mdl"] = true,
        ["models/props_c17/oildrum001_explosive.mdl"] = true,
        ["models/props_phx/oildrum001_explosive.mdl"] = true,
        ["models/props_phx/misc/potato_launcher_explosive.mdl"] = true,
        ["models/props_junk/gascan001a.mdl"] = true,
        ["models/props_junk/propane_tank001a.mdl"] = true,
        ["models/ruin/pipes/pipes_01_1e.mdl"] = true
    }

    for k, v in pairs(ents.FindByClass("prop_physics")) do
        if !IsValid(v) then return end
        local model = v:GetModel()
        
        if string.find(model, "explosive") then
            if table.HasValue( explosives, model ) then return end
            table.insert(explosives, model)
        end
    end
    
    hook.Add("Think", "RUIN Auto Aim Trace", function()
        if !IsValid(ply) then ply = LocalPlayer() end
        if (!IsValid(ply)) or (ply:Health() <= 0) then return end
        -- This way the trace will always be shooting straight out no matter what the pitch of the player's aim is (Important for when autoaim code overrides the pitch)
        local correctedEyeAngles = ply:EyeAngles()
        correctedEyeAngles.p = 0
        
        local tr = util.TraceHull( {
            start = ply:EyePos(),
            endpos = ply:EyePos() + (correctedEyeAngles:Forward() * 10000),
            --Function in filter is not ideal but more ideal than previous solution.
            filter = function( ent )
                return  ent:IsNPC() 
                or ent:GetClass() == "prop_physics" and explosives[ent:GetModel()]
            end, 
            ignoreworld = true,
            mins = traceMins,
            maxs = traceMaxs,
        } )

        local hitPos = tr.HitPos
        local hitEnt = tr.Entity

        if tr.Hit == true  and hitEnt:IsNPC() and hitEnt:isVisibleToPlayer() and IsValid(hitEnt) then
            RUIN.autoAimOverride = true
            
            if hitEnt:GetAttachment(hitEnt:LookupAttachment("eyes")) ~= nil then
                RUIN.autoAimTargetPosition = hitEnt:GetAttachment(hitEnt:LookupAttachment("eyes")).Pos
            else
                worldSpaceAABBMin, worldSpaceAABBMax = hitEnt:WorldSpaceAABB()
                npcAimPoint = (worldSpaceAABBMin +  worldSpaceAABBMax) * vectorHalf
                RUIN.autoAimTargetPosition = npcAimPoint
            end
        elseif tr.Hit == true and IsValid(hitEnt) and explosives[hitEnt:GetModel()] then
            RUIN.autoAimOverride = true
            
            worldSpaceAABBMin, worldSpaceAABBMax = hitEnt:WorldSpaceAABB()
            explosiveBarrelAimPoint = ((worldSpaceAABBMin +  worldSpaceAABBMax) * vectorHalf ) + ((worldSpaceAABBMax - worldSpaceAABBMin) * aimOffset)
            RUIN.autoAimTargetPosition = explosiveBarrelAimPoint
        else
            RUIN.autoAimOverride = false
        end

        -- DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG--
        -- DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG--
        if DEBUG == false then return end
        if nextDebugRender > CurTime() then return end
        nextDebugRender = CurTime() + .01
        print("-----")
        print("Auto Aim Box Trace Hit Pos: " .. tostring(hitPos))
        print("Auto Aim Box Trace Hit Entity: " .. tostring(hitEnt))
        if IsValid(hitEnt) and hitEnt:GetAttachment(hitEnt:LookupAttachment("eyes")) ~= nil then
            print("Auto Aim Box Trace Hit Entity Eye Pos: " .. tostring(hitEnt:GetAttachment(hitEnt:LookupAttachment("eyes")).Pos))
        end
        print("Auto Aim override: " .. tostring(RUIN.autoAimOverride))
        if tr.Hit == false then return end
        debugoverlay.Box( hitPos, traceMins, traceMaxs, .01, Color( 21, 253, 0) )
        -- DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG--
        -- DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG--
    end)
end