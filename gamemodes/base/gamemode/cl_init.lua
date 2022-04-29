local include = include

include("shared.lua")

--	//		Includes	//
include("client/2d_render.lua")
include("client/3d_render.lua")
include("client/chat.lua")
include("client/derma.lua")
include("client/entity.lua")
include("client/mouse_control.lua")
include("client/movement.lua")
include("client/other.lua")
include("client/player_camera.lua")
include("client/teams.lua")
include("client/viewmodel.lua")

--	//		Gamemode		//
function GM:Initialize()
end

function GM:Think()
end

function GM:ShutDown()
end