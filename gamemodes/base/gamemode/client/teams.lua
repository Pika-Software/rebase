-- Team System UI
function GM:ShowTeam()
end

function GM:HideTeam()
end

-- Player Class Changed
do

	local util_NetworkIDToString = util.NetworkIDToString
	local player_manager_SetPlayerClass = player_manager.SetPlayerClass

	function GM:PlayerClassChanged(ply, newID)
		if (newID < 1) then return end

		local classname = util_NetworkIDToString(newID)
		if (classname == nil) then return end

		player_manager_SetPlayerClass(ply, classname)
	end

end