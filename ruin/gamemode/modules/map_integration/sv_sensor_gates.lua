local delay = CurTime() 
local sensorDoors = {}
local doorDetectionRadius = 128

-- Fill a table with the list of all potential sensor doors.
function populateSensorDoors()
    timer.Simple(.1, function()
        for k, v in pairs(ents.FindByClass("prop_dynamic")) do
            if v:GetModel() != "models/ruin/harvester/gate_01.mdl" then continue end
            v.state = "closed"
            v.lastState = "closed"
            table.insert(sensorDoors, v)
        end
    end)
end

populateSensorDoors()

hook.Add("PostCleanupMap", "RUIN Populate Sensor Doors Table", function()
    -- It's important to clear this table otherwise there will be a memory leak.
    sensorDoors = {}
    populateSensorDoors()
end)

-- Return true if there are either players or NPC's near a given door.
local function entsNearDoor(door)
    local doorPos = door:GetPos()

    for _, npc in pairs(ents.FindByClass("npc_*")) do
        if doorPos:Distance(npc:GetPos()) < doorDetectionRadius then return true end
    end

    for _, plyr in pairs(ents.FindByClass("player")) do
        if doorPos:Distance(plyr:GetPos()) < doorDetectionRadius then return true end
    end

    return false
end

-- Simple state machine, opens door if it's closed and detects nearby players or npcs, closes it if it doesn't.
hook.Add("Think", "RUIN Manage Sensor Gates", function()
    if delay > CurTime() then return end
    delay = CurTime() + .05

    for _, door in pairs(sensorDoors) do
        if !IsValid(door) then continue end

        door.motionDetected = entsNearDoor(door) and true or false 

        if door.motionDetected then
            door.state = "open"
            door:Fire("SetAnimation", "idle_open" )
            if door.state != door.lastState and !door.justMadeNoise then
                door:EmitSound("doors/doormove2.wav", 80, 115, .2, CHAN_AUTO)
                door.justMadeNoise = true 
                timer.Simple(0.5, function() door.justMadeNoise = false end)
            end
            door:SetSkin(1)
            door.lastState = "open"
        else
            door.state = "closed"
            door:Fire("SetAnimation", "idle_closed" )
            if door.state != door.lastState and !door.justMadeNoise then
                door:EmitSound("doors/doormove2.wav", 80, 115, .2, CHAN_AUTO)
                door.justMadeNoise = true 
                timer.Simple(0.5, function() door.justMadeNoise = false end)
            end
            door:SetSkin(0)
            door.lastState = "closed"
        end
    end
end)

