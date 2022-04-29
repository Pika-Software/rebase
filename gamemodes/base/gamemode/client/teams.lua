-- Team System
function GM:ShowTeam()
end

function GM:HideTeam()
end

do
	local TEAM_UNASSIGNED = TEAM_UNASSIGNED
	function GM:GetTeamColor( ent )
		return self:GetTeamNumColor( (ent.Team == nil) and TEAM_UNASSIGNED or ent:Team() )
	end
end

do
	local team_GetColor = team.GetColor
	function GM:GetTeamNumColor( num )
		return team_GetColor( num )
	end
end

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