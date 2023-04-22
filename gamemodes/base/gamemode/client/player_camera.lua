-- GM:CalcVehicleView
do

	local util_TraceHull = util.TraceHull

	local WallOffset = 4
	local blockedHullEnts = {
		["prop_physics"] = true,
		["prop_dynamic"] = true,
		["prop_ragdoll"] = true,
		["phys_bone_follower"] = true,
	}

	local mins = Vector( -WallOffset, -WallOffset, -WallOffset )
	local maxs = Vector( WallOffset, WallOffset, WallOffset )

	local function filter( ent )
		if ent:IsVehicle() then return false end
		return blockedHullEnts[ ent:GetClass() ] or false
	end

	function GM:CalcVehicleView( veh, ply, view )
		if (veh.GetThirdPersonMode == nil) or (ply:GetViewEntity() ~= ply) then
			return
		end

		if veh:GetThirdPersonMode() then
			local mn, mx = veh:GetRenderBounds()
			local radius = ( mn - mx ):Length()

			local tr = util_TraceHull( {
				["start"] = view.origin,
				["endpos"] = view.origin + ( view.angles:Forward() * (radius + radius * veh:GetCameraDistance()) * -1 ),
				["filter"] = filter,
				["mins"] = mins,
				["maxs"] = maxs
			} )

			view.origin = tr.HitPos
			view.drawviewer = true

			if tr.Hit then
				if tr.StartSolid then
					return view
				end

				view.origin = view.origin + tr.HitNormal * WallOffset
			end
		end

		return view
	end

end

-- GM:CalcView
do

	local Angle = Angle
	local Vector = Vector
	local IsValid = IsValid
	local hook_Run = hook.Run
	local drive_CalcView = drive.CalcView
	local player_manager_RunClass = player_manager.RunClass

	function GM:CalcView( ply, origin, angles, fov, znear, zfar )
		local view = {
			["origin"] = origin,
			["angles"] = angles,
			["fov"] = fov,
			["znear"] = znear,
			["zfar"] = zfar,
			["drawviewer"] = false
		}

		local veh = ply:GetVehicle()
		if IsValid( veh ) then
			return hook_Run( "CalcVehicleView", veh, ply, view )
		end

		if drive_CalcView( ply, view ) then
			return view
		end

		player_manager_RunClass( ply, "CalcView", view )

		local wep = ply:GetActiveWeapon()
		if IsValid( wep ) then
			if (wep.CalcView == nil) then
				return view
			end

			local origin, angles, fov = wep:CalcView( ply, Vector( view.origin ), Angle( view.angles ), view.fov )
			view.origin, view.angles, view.fov = origin or view.origin, angles or view.angles, fov or view.fov
		end

		return view
	end
end