-- GM:CalcViewModelView
do

	local IsValid = IsValid

	function GM:CalcViewModelView( wep, vm, oldPos, oldAng, pos, ang )
		if not IsValid( wep ) then return end

		local vm_origin, vm_angles = pos, ang
		local func = wep.GetViewModelPosition
		if func then
			local pos2, ang2 = func( wep, pos, ang )
			vm_origin = pos2 or vm_origin
			vm_angles = ang2 or vm_angles
		end

		func = wep.CalcViewModelView
		if func then
			local pos2, ang2 = func( wep, vm, oldPos, oldAng, pos, ang )
			vm_origin = pos2 or vm_origin
			vm_angles = ang2 or vm_angles
		end

		return vm_origin, vm_angles
	end

end

-- GM:PreDrawViewModel
do

	local player_manager_RunClass = player_manager.RunClass
	local IsValid = IsValid

	function GM:PreDrawViewModel( vm, ply, wep )
		if not IsValid( wep ) then return false end

		player_manager_RunClass( ply, "PreDrawViewModel", vm, wep )
		if not wep.PreDrawViewModel then return false end

		return wep:PreDrawViewModel( vm, wep, ply )
	end

end

-- GM:PostDrawViewModel
do

	local MATERIAL_CULLMODE_CCW = MATERIAL_CULLMODE_CCW
	local MATERIAL_CULLMODE_CW = MATERIAL_CULLMODE_CW

	local IsValid = IsValid
	local hook_Call = hook.Call
	local render_CullMode = render.CullMode

	function GM:PostDrawViewModel( vm, ply, wep )
		if IsValid( wep ) then
			if wep.UseHands or not wep:IsScripted() then
				local hands = ply:GetHands()
				if IsValid( hands ) and IsValid( hands:GetParent() ) then
					if not hook_Call( "PreDrawPlayerHands", self, hands, vm, ply, wep ) then
						if wep.ViewModelFlip then
							render_CullMode( MATERIAL_CULLMODE_CW )
						end

						hands:DrawModel()

						render_CullMode( MATERIAL_CULLMODE_CCW )
					end

					hook_Call( "PostDrawPlayerHands", self, hands, vm, ply, wep )
				end
			end

			if not wep.PostDrawViewModel then return false end
			return wep:PostDrawViewModel( vm, wep, ply )
		end

		return false
	end

end