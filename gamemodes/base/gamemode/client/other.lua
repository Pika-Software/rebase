-- PhysGun
function GM:DrawPhysgunBeam( ply, wep, bOn, target, boneid, pos )
	return true
end

-- Idk what is this
function GM:PostProcessPermitted( str )
	return false
end

-- Spawn Menu
function GM:OnSpawnMenuOpen()
end

function GM:OnSpawnMenuClose()
end

-- Context Menu
function GM:OnContextMenuOpen()
end

function GM:OnContextMenuClose()
end

local hook_Run = hook.Run

concommand.Add( "+menu", function()
	hook_Run( "OnSpawnMenuOpen" )
end, nil, "Opens the spawnmenu", FCVAR_DONTRECORD )

concommand.Add( "-menu", function()
	hook_Run( "OnSpawnMenuClose" )
end, nil, "Closes the spawnmenu", FCVAR_DONTRECORD )

concommand.Add( "+menu_context", function()
	hook_Run( "OnContextMenuOpen" )
end, nil, "Opens the context menu", FCVAR_DONTRECORD )

concommand.Add( "-menu_context", function()
	hook_Run( "OnContextMenuClose" )
end, nil, "Closes the context menu", FCVAR_DONTRECORD )
