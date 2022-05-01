if (CLIENT) and (spawnmenu ~= nil) and (spawnmenu.AddToolMenuOption ~= nil) then
    local original = spawnmenu.AddToolMenuOption
    function spawnmenu.AddToolMenuOption( tab, ... )
        return original( (tab == "Options") and "Utilities" or tab, ... )
    end
end