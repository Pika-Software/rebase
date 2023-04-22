-- PhysGun
function GM:PhysgunPickup( ply, ent )
	-- Freeze player while being picked up by physgun.
	if ent:IsPlayer() then
		ent:SetMoveType( MOVETYPE_NONE )
	end

	return true
end

function GM:PhysgunDrop( ply, ent )
	-- Unfreeze player, so he can walk now
	if ent:IsPlayer() then
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