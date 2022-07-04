-- Extra
function net.ReceiveRemove( name )
	net.Receivers[ name:lower() ] = nil
end

do
	local list_GetForEdit = list.GetForEdit
	local ipairs = ipairs

	function list.Remove( name, key )
		local tbl = list_GetForEdit( name )
		if (key == nil) then
			for key, value in ipairs( tbl ) do
				tbl[ key ] = nil
			end
		else
			tbl[ key ] = nil
		end
	end
end

-- PhysGun
function GM:PhysgunPickup( ply, ent )
	-- Freeze player while being picked up by physgun.
    if ent:GetClass() == "player" then
        ent:SetMoveType( MOVETYPE_NONE )
    end

	return true
end

function GM:PhysgunDrop( ply, ent )
	-- Unfreeze player, so he can walk now
	if ent:GetClass() == "player" then
		ent:SetMoveType( MOVETYPE_WALK )
	end
end

-- GravityGun
function GM:GravGunPunt( ply, ent )
	return true
end

function GM:GravGunPickupAllowed( ply, ent )
	return true
end