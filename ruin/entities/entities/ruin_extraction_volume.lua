ENT.Type = "brush"
ENT.Base = "base_brush"

function RUIN.playerExtracted(entity)
    net.Start("RUIN Network To Player Extraction Completed")
    net.Send(entity)
    net.Start("Toggle Game End Curtain")
    net.WriteUInt(2, 3)
    net.Send(entity)
end

function ENT:StartTouch( entity )
    if !IsValid(entity) then return end
    if !entity:IsPlayer() then return end
    RUIN.playerExtracted(entity)
    RUIN.extracted = true
    entity:Freeze( true )
    timer.Simple(5, function()
        entity:Freeze( false )
    end)

    -- Ensures player isn't killed if they extracted and npcs are alive.
    entity:GodEnable()
    for k, v in pairs(ents.FindByClass("npc_*")) do
        if !IsValid(v) or !IsEnemyEntityName(v:GetClass()) then continue end
        v:AddEntityRelationship( entity, D_NU, 99 )
    end
end

function ENT:Initialize()
    self:SetTrigger( true )
end





