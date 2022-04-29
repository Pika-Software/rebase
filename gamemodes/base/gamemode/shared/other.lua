-- PhysGun
function GM:PhysgunPickup(ply, ent)
	return true
end

function GM:PhysgunDrop(ply, ent)
end

-- GravityGun
function GM:GravGunPunt(ply, ent)
	return true
end

function GM:GravGunPickupAllowed(ply, ent)
	return true
end

timer.Simple(0, function()
	if (SERVER) then
		concommand.Remove("lua_find")
		concommand.Remove("lua_findhooks")
	else
		concommand.Remove("lua_find_cl")
		concommand.Remove("lua_findhooks_cl")
	end

	-- Edit Variable
	net.ReceiveRemove("editvariable")
end)