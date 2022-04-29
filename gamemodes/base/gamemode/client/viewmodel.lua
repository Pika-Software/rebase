-- GM:CalcViewModelView
do
	local IsValid = IsValid
	function GM:CalcViewModelView( wep, vm, OldEyePos, OldEyeAng, EyePos, EyeAng )
		if IsValid( wep ) then
			local vm_origin, vm_angles = EyePos, EyeAng

			local func = wep.GetViewModelPosition
			if (func ~= nil) then
				local pos, ang = func( wep, EyePos, EyeAng )
				vm_origin = pos or vm_origin
				vm_angles = ang or vm_angles
			end

			func = wep.CalcViewModelView
			if (func ~= nil) then
				local pos, ang = func( wep, vm, OldEyePos, OldEyeAng, EyePos, EyeAng )
				vm_origin = pos or vm_origin
				vm_angles = ang or vm_angles
			end

			return vm_origin, vm_angles
		end
	end
end

-- GM:PreDrawViewModel
do

	local IsValid = IsValid
	local hook_name = "PreDrawViewModel"
	local player_manager_RunClass = player_manager.RunClass

	function GM:PreDrawViewModel( vm, ply, wep )
		if IsValid( wep ) then
			player_manager_RunClass( ply, hook_name, vm, wep )

			if (wep[ hook_name ] == nil) then
				return false
			end

			return wep:PreDrawViewModel( vm, wep, ply )
		end

		return false
	end

end

-- GM:PostDrawViewModel
do

	local IsValid = IsValid
	local hook_Call = hook.Call
	local render_CullMode = render.CullMode
	local hook_name1 = "PreDrawPlayerHands"
	local hook_name2 = "PostDrawPlayerHands"
	local MATERIAL_CULLMODE_CW = MATERIAL_CULLMODE_CW
	local MATERIAL_CULLMODE_CCW = MATERIAL_CULLMODE_CCW

	function GM:PostDrawViewModel( vm, ply, wep )
		if IsValid( wep ) then
			if (wep.UseHands == true) or not wep:IsScripted() then
				local hands = ply:GetHands()
				if IsValid( hands ) and IsValid( hands:GetParent() ) then
					if not hook_Call( hook_name1, self, hands, vm, ply, wep ) then
						if (wep.ViewModelFlip == true) then
							render_CullMode(MATERIAL_CULLMODE_CW)
						end

						hands:DrawModel()

						render_CullMode( MATERIAL_CULLMODE_CCW )
					end

					hook_Call( hook_name2, self, hands, vm, ply, wep )
				end
			end

			if (wep.PostDrawViewModel == nil) then
				return false
			end

			return wep:PostDrawViewModel( vm, wep, ply )
		end

		return false
	end

end