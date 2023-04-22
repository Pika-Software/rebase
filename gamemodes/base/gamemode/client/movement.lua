-- Player Movement
do

	local player_manager_RunClass = player_manager.RunClass
	local drive_CreateMove = drive.CreateMove

	function GM:CreateMove( cmd )
		if drive_CreateMove( cmd ) then
			return true
		end

		local ply = LocalPlayer()
		if not ply then return end
		if not player_manager_RunClass( ply, "CreateMove", cmd ) then return end

		return true
	end

end

-- Vehicle Movement
function GM:VehicleMove( ply, vehicle, mv )
end

-- Binds
function GM:PlayerBindPress( ply, bind, down )
	return false
end