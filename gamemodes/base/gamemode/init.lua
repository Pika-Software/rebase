local AddCSLuaFile = AddCSLuaFile
local include = include

AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local serverFolder = "base/gamemode/server/"
for _, fileName in ipairs( file.Find( serverFolder .. "*", "LUA" ) ) do
    include( serverFolder .. fileName )
end

local clientFolder = "base/gamemode/client/"
for _, fileName in ipairs( file.Find( clientFolder .. "*", "LUA" ) ) do
    AddCSLuaFile( clientFolder .. fileName )
end
