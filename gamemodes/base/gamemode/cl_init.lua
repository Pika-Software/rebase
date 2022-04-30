do

    local include = include
    local cl_files = {
        "client/mouse_control.lua",
        "client/player_camera.lua",
        "client/2d_render.lua",
        "client/3d_render.lua",
        "client/viewmodel.lua",
        "client/movement.lua",
        "client/entity.lua",
        "client/other.lua",
        "client/teams.lua",
        "client/derma.lua",
        "client/chat.lua",
        "shared.lua",
        "client/user_interface.lua"
    }

    for num, path in ipairs( cl_files ) do
        include( path )
    end

end

function GM:Initialize()
end

function GM:Think()
end

function GM:ShutDown()
end

do
    local spawnmenu_GetCreationTabs = spawnmenu.GetCreationTabs
    function spawnmenu.RemoveCreationTab( name )
        spawnmenu_GetCreationTabs()[ name ] = nil
    end
end