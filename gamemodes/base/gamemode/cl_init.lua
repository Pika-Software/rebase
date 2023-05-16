local include = include
include( "shared.lua" )

local clientFolder = "base/gamemode/client/"
for _, fileName in ipairs( file.Find( clientFolder .. "*", "LUA" ) ) do
    include( clientFolder .. fileName )
end