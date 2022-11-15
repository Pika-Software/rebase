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

-- Team Color (Old stuff support)
do
	local team_GetColor = team.GetColor
	function GM:GetTeamNumColor( teamID )
		return team_GetColor( teamID )
	end
end

function GM:GetTeamColor( ent )
	return self:GetTeamNumColor( isfunction( ent.Team ) and ent:Team() or 1 )
end
