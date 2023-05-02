if not spawnmenu or not spawnmenu.AddToolMenuOption then return end
local spawnmenu_AddToolMenuOption = spawnmenu.AddToolMenuOption
function spawnmenu.AddToolMenuOption( tabName, ... )
    return spawnmenu_AddToolMenuOption( ( tabName == "Options" ) and "Utilities" or tabName, ... )
end