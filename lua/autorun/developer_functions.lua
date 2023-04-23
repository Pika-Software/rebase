if not CLIENT then return end
if not spawnmenu then return end
if not spawnmenu.AddToolMenuOption then return end

local func = spawnmenu.AddToolMenuOption
function spawnmenu.AddToolMenuOption( tab, ... )
    return func( ( tab == "Options" ) and "Utilities" or tab, ... )
end