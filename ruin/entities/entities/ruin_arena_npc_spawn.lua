ENT.Type = "point"
ENT.Base = "base_point"

RUIN.arenaNpcSpawnPoints = RUIN.arenaNpcSpawnPoints or {}

function ENT:Initialize()
    if table.HasValue(RUIN.arenaNpcSpawnPoints, self:GetPos()) then return end
    table.insert(RUIN.arenaNpcSpawnPoints, self:GetPos())
    self:Remove()
end

