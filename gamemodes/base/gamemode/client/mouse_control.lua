-- Mouse
function GM:InputMouseApply(cmd, x, y, angle)
end

function GM:GUIMouseDoublePressed(code, AimVector)
	self:GUIMousePressed(code, AimVector)
end

do

	local player = nil
	hook.Add("PlayerInitialized", "GM:AdjustMouseSensitivity", function( ply )
		player = ply
	end)

	local IsValid = IsValid
	function GM:AdjustMouseSensitivity( fDefault )
		if (player == nil) then return -1 end
		local wep = player:GetActiveWeapon()
		if IsValid( wep ) then
			if (wep.AdjustMouseSensitivity == nil) then return -1 end
			return wep:AdjustMouseSensitivity( fDefault )
		end

		return -1
	end

end

function GM:GUIMousePressed( mousecode, AimVector )
end

function GM:GUIMouseReleased( mousecode, AimVector )
end

function GM:PreventScreenClicks( cmd )
	return false
end