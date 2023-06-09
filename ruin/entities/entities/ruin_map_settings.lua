ENT.Type = "point"
ENT.Base = "base_point"

RUIN.mapSettings = RUIN.mapSettings or 
{
    ["enable_ruin_snow"] = 0, -- 0 == No snow. (Default)
    ["main_menu_cam_ang"] = "0, 0, 0",
    ["main_menu_cam_pos"] = "0, 0, 0",
    ["mode"] = 0, -- 0 == Extraction. (Default game-mode)
}

function ENT:Initialize()
    self:TriggerOutput("MapSettingsSpawned", self)
end

function ENT:KeyValue(k, v)
    if RUIN.mapSettings[k] then -- Don't store un-necessary stuff.
        RUIN.mapSettings[k] = v
    end
end






