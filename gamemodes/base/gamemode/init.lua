local AddCSLuaFile = AddCSLuaFile
local include = include

AddCSLuaFile("shared.lua")
include("shared.lua")

--  //      Client      //
AddCSLuaFile("client/2d_render.lua")
AddCSLuaFile("client/3d_render.lua")
AddCSLuaFile("client/chat.lua")
AddCSLuaFile("client/derma.lua")
AddCSLuaFile("client/entity.lua")
AddCSLuaFile("client/mouse_control.lua")
AddCSLuaFile("client/movement.lua")
AddCSLuaFile("client/other.lua")
AddCSLuaFile("client/player_camera.lua")
AddCSLuaFile("client/teams.lua")
AddCSLuaFile("client/viewmodel.lua")

AddCSLuaFile("shared/entity.lua")
AddCSLuaFile("shared/other.lua")
AddCSLuaFile("shared/player.lua")
AddCSLuaFile("shared/player_class/player_default.lua")

--	//	    Includes	//
include("server/other.lua")
include("server/player.lua")

--  //      Server      //
function GM:Initialize()
end

function GM:InitPostEntity()
end

function GM:Think()
end

function GM:ShutDown()
end