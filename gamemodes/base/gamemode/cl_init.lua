local client = {
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

for _, path in ipairs( client ) do
    include( path )
end