-- Vehicle
function GM:VehicleMove(ply, vehicle, mv)
end

-- Player Movement
do

	local player = nil
	hook.Add("PlayerInitialized", "GM:CreateMove", function( ply )
		player = ply
	end)

	local player_manager_RunClass = player_manager.RunClass
	local drive_CreateMove = drive.CreateMove
	local class_name = "CreateMove"

	function GM:CreateMove( cmd )
		if drive_CreateMove( cmd ) then
			return true
		end

		if player_manager_RunClass( player, class_name, cmd ) then
			return true
		end
	end

end

-- Binds
function GM:PlayerBindPress( ply, bind, down )
	return false
end