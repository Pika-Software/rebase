-- Mouse
function GM:InputMouseApply(cmd, x, y, angle)
end

function GM:GUIMouseDoublePressed(code, AimVector)
	self:GUIMousePressed(code, AimVector)
end

do

	local IsValid = IsValid

	function GM:AdjustMouseSensitivity( delta )
		local ply = LocalPlayer()
		if not ply then return -1 end

		local wep = ply:GetActiveWeapon()
		if not IsValid( wep ) then return -1 end
		if not wep.AdjustMouseSensitivity then return -1 end

		return wep:AdjustMouseSensitivity( delta )
	end

end

function GM:GUIMousePressed( mousecode, AimVector )
end

function GM:GUIMouseReleased( mousecode, AimVector )
end

function GM:PreventScreenClicks( cmd )
	return false
end