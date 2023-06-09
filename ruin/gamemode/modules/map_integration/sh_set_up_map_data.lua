if SERVER then
    util.AddNetworkString("RUIN Map Settings Network To Player")
    util.AddNetworkString("RUIN Map Settings Player Request From Server")

    net.Receive("RUIN Map Settings Player Request From Server", function(len, ply)
        net.Start("RUIN Map Settings Network To Player")
        net.WriteTable( RUIN.mapSettings )
        net.Broadcast()
    end)
end

if CLIENT then
    RUIN.mapSettings = RUIN.mapSettings or 
    {
        ["enable_ruin_snow"] = 0, -- 0 == No snow (Default)
        ["main_menu_cam_ang"] = "0, 0, 0",
        ["main_menu_cam_pos"] = "0, 0, 0",
        ["mode"] = 0, -- 0 == Extraction (Default game-mode)
    }

    net.Receive("RUIN Map Settings Network To Player", function(len, ply)
        RUIN.mapSettings = net.ReadTable()
        print("--------------------------")
        print("-------MAP SETTINGS-------")
        print("--------------------------")
        PrintTable(RUIN.mapSettings)
        print("-------------------------- \n")
    end)

    timer.Simple(0, function()
        net.Start("RUIN Map Settings Player Request From Server")
        net.SendToServer()
    end)
end
