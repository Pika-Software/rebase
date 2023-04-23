local player_manager_RunClass = player_manager.RunClass

-- Can Checks
do

	local alltalk = cvars.Number( "sv_alltalk", 0 )
	cvars.AddChangeCallback("sv_alltalk", function( name, old, new )
		alltalk = tonumber( new )
	end)

	function GM:PlayerCanHearPlayersVoice( listener, talker )
		if (alltalk >= 1) then
			return true, alltalk == 2
		end

		return listener:Team() == talker:Team(), false
	end

end

function GM:CanPlayerUnfreeze( ply, ent, phys )
	return true
end

function GM:PlayerCanPickupWeapon( ply, ent )
	return true
end

function GM:AllowPlayerPickup( ply, object )
	return true
end

function GM:PlayerCanPickupItem( ply, ent )
	return true
end

function GM:PlayerUse( ply, ent )
	return true
end

function GM:CanPlayerSuicide( ply )
	return true
end

function GM:PlayerSpray( ply )
	return false
end

-- Flashlight
function GM:PlayerSwitchFlashlight( ply, SwitchOn )
	return ply:CanUseFlashlight()
end

-- Taunt
function GM:PlayerShouldTaunt( ply, actid )
	return true
end

function GM:PlayerStartTaunt( ply, actid, length )
end

-- Player Damage
function GM:PlayerShouldTakeDamage( ply, attacker )
	return true
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
end

function GM:PlayerHurt( ply, attacker, healthleft, healthtaken )
end

function GM:OnPlayerHitGround( ply, bInWater, bOnFloater, flFallSpeed )
end

function GM:OnDamagedByExplosion( ply, dmginfo )
	ply:SetDSP( 35, false )
end

function GM:GetFallDamage( ply, fall_speed )
	return (fall_speed - 526.5) / 4
end

local CurTime = CurTime

-- Death
function GM:PlayerSilentDeath( ply )
	ply.NextSpawnTime = CurTime() + 2
end

function GM:PlayerDeathSound()
	return false
end

do

	local IN_JUMP = IN_JUMP
	local IN_ATTACK = IN_ATTACK
	local IN_ATTACK2 = IN_ATTACK2

	function GM:PlayerDeathThink( ply )
		if ply.NextSpawnTime < CurTime() and ( ply:IsBot() or ply:KeyPressed( IN_ATTACK ) or ply:KeyPressed( IN_ATTACK2 ) or ply:KeyPressed( IN_JUMP ) ) then
			ply:Spawn()
		end
	end

end

function GM:PostPlayerDeath( ply )
end

-- Vehicle
function GM:CanPlayerEnterVehicle( ply, vehicle, role )
	return true
end

function GM:CanExitVehicle( vehicle, passenger )
	return true
end

function GM:PlayerEnteredVehicle( ply, vehicle, role )
end

function GM:PlayerLeaveVehicle( ply, vehicle )
end

-- Team System
function GM:PlayerJoinTeam( ply, teamid )
end

-- Connecting
function GM:NetworkIDValidated( name, steamid )
	-- MsgN("GM:NetworkIDValidated", name, steamid)
end

function GM:PlayerAuthed( ply, SteamID, UniqueID )
end

function GM:PlayerDisconnected( ply )
end

-- Buttons
function GM:PlayerButtonDown( ply, btn )
end

function GM:PlayerButtonUp( ply, btn )
end

-- Weapon
function GM:PlayerDroppedWeapon( ply, weapon )
end

function GM:WeaponEquip( wep )
end

function GM:PlayerLoadout( ply )
	player_manager_RunClass( ply, "Loadout" )
end

-- Chat
function GM:PlayerSay( ply, text, isTeam )
	return text
end

do

	local IsValid = IsValid

	function GM:PlayerCanSeePlayersChat( text, isTeam, listener, speaker )
		if isTeam then
			if IsValid( speaker ) and IsValid( listener ) then
				return speaker:Team() == listener:Team()
			end

			return false
		end

		return true
	end

end

function GM:SetupPlayerVisibility( pPlayer, pViewEntity )
	--AddOriginToPVS(vector_position_here)
end

-- GM:DoPlayerDeath
do

	local IsValid = IsValid
	local CurTime = CurTime

	function GM:DoPlayerDeath( ply, attacker, dmginfo )
		ply.NextSpawnTime = CurTime() + 2
		ply:CreateRagdoll()
		ply:AddDeaths( 1 )

		if IsValid( attacker ) and attacker:IsPlayer() then
			if ply == attacker then
				attacker:AddFrags( -1 )
			else
				attacker:AddFrags( 1 )
			end
		end
	end

end

-- GM:PlayerDeath
do
	util.AddNetworkString( "PlayerKilled" )

	function GM:PlayerDeath( ply, infl, att )
		if IsValid( att ) then
			if (att:GetClass() == "trigger_hurt") then
				att = ply
			elseif att:IsVehicle() then
				local driver = att:GetDriver()
				if IsValid( driver ) then
					att = driver
				end
			end
		else
			att = ply
		end

		if IsValid( infl ) then
			if (infl == att) and (att:IsPlayer() or att:IsNPC()) then
				local wep = att:GetActiveWeapon()
				if IsValid( wep ) then
					infl = wep
				end
			end
		elseif (att:IsPlayer() or att:IsNPC()) then
			local wep = att:GetActiveWeapon()
			if IsValid( wep ) then
				infl = wep
			end
		else
			infl = att
		end

		player_manager_RunClass( ply, "Death", infl, att )

		net.Start("PlayerKilled")
			net.WriteEntity( ply )
		if att == ply then
			net.WriteInt(1, 3)
			net.Broadcast()
			MsgAll(Format("%s suicided!\n", att:Nick()))
			return
		end

		local isplayer = att:IsPlayer()
		if isplayer then
			net.WriteInt(2, 3)
		else
			net.WriteInt(3, 3)
		end

		local infl_class = infl:GetClass()
		net.WriteString(infl_class)

		if isplayer then
			net.WriteEntity(att)
			net.Broadcast()
			MsgAll(Format("%s killed %s using %s\n", att:Nick(), ply:Nick(), infl_class))
			return
		end

		net.WriteString(att:GetClass())
		net.Broadcast()
		Format("%s  was killed by %s\n", ply:Nick(), att:GetClass())
	end
end

-- GM:PlayerInitialSpawn
do

	local player_manager_SetPlayerClass = player_manager.SetPlayerClass
	local TEAM_UNASSIGNED = TEAM_UNASSIGNED

	function GM:PlayerInitialSpawn( ply, transiton )
		player_manager_SetPlayerClass( ply, "player_default" )
		ply:SetTeam( TEAM_UNASSIGNED )
	end

end

do

	local TEAM_SPECTATOR = TEAM_SPECTATOR

	-- GM:PlayerSpawnAsSpectator
	do

		local OBS_MODE_ROAMING = OBS_MODE_ROAMING

		function GM:PlayerSpawnAsSpectator( ply )
			ply:Spectate( OBS_MODE_ROAMING )
			ply:SetTeam( TEAM_SPECTATOR )
			ply:StripWeapons()
		end

	end

	-- GM:PlayerSpawn
	do

		local player_manager_OnPlayerSpawn = player_manager.OnPlayerSpawn
		local hook_Call = hook.Call

		function GM:PlayerSpawn( ply, transiton )
			if ply:Team() == TEAM_SPECTATOR then
				self:PlayerSpawnAsSpectator( ply )
				return
			end

			ply:UnSpectate()

			player_manager_OnPlayerSpawn( ply, transiton )
			player_manager_RunClass( ply, "Spawn" )

			if not transiton then
				hook_Call( "PlayerLoadout", self, ply )
			end

			hook_Call( "PlayerSetModel", self, ply )
		end

	end

end

-- GM:PlayerSetModel
function GM:PlayerSetModel( ply )
	player_manager_RunClass( ply, "SetModel" )
	ply:SetupHands()
end

-- GM:PlayerSetHandsModel
do

	local player_manager_TranslateToPlayerModelName = player_manager.TranslateToPlayerModelName
	local player_manager_TranslatePlayerHands = player_manager.TranslatePlayerHands

	function GM:PlayerSetHandsModel( ply, ent )
		local info = player_manager_RunClass( ply, "GetHandsModel" ) or player_manager_TranslatePlayerHands( player_manager_TranslateToPlayerModelName( ply:GetModel() ) )
		if info then
			ent:SetModel( info.model )
			ent:SetSkin( info.skin )
			ent:SetBodyGroups( info.body )
		end
	end

end

-- GM:IsSpawnpointSuitable
do

	local ipairs = ipairs
	local IsValid = IsValid
	local TEAM_SPECTATOR = TEAM_SPECTATOR
	local ents_FindInBox = ents.FindInBox

	local mins = Vector( -16, -16, 0 )
	local maxs = Vector( 16, 16, 64 )

	function GM:IsSpawnpointSuitable( ply, ent, killPlayers )
		if ply:Team() == TEAM_SPECTATOR then return true end

		local pos = ent:GetPos()
		local blockers = 0

		for num, pl in ipairs( ents_FindInBox( pos + mins, pos + maxs ) ) do
			if IsValid( pl ) and pl ~= ply and pl:IsPlayer() and pl:Alive() then
				blockers = blockers + 1

				if killPlayers then
					pl:Kill()
				end
			end
		end

		if not killPlayers and blockers > 0 then return false end

		return true
	end

end

-- GM:PlayerSelectSpaw
do

	local Msg = Msg
	local ipairs = ipairs
	local table_Add = table.Add
	local hook_Call = hook.Call
	local table_Count = table.Count
	local table_Random = table.Random
	local ents_FindByClass = ents.FindByClass
	local IsTableOfEntitiesValid = IsTableOfEntitiesValid

	local spawnpoints = {
		"info_player_deathmatch",
		"info_player_combine",
		"info_player_rebel",

		"info_player_counterterrorist",
		"info_player_terrorist",

		"gmod_player_start",

		"info_player_axis",
		"info_player_allies",

		"info_player_teamspawn",

		"ins_spawnpoint",

		"aoc_spawnpoint",

		"dys_spawn_point",

		"info_player_pirate",
		"info_player_viking",
		"info_player_knight",

		"diprip_start_team_blue",
		"diprip_start_team_red",

		"info_player_red",
		"info_player_blue",

		"info_player_coop",

		"info_player_human",
		"info_player_zombie",

		"info_player_zombiemaster",

		"info_player_fof",
		"info_player_desperado",
		"info_player_vigilante",

		"info_survivor_rescue"
	}

	function GM:PlayerSelectSpawn( ply, transiton )
		if transiton then return end

		if not IsTableOfEntitiesValid( self.SpawnPoints ) then
			self.SpawnPoints = ents_FindByClass( "info_player_start" )
			self.LastSpawnPoint = 0

			for num, class in ipairs( spawnpoints ) do
				self.SpawnPoints = table_Add( self.SpawnPoints, ents_FindByClass( class ) )
			end
		end

		local count = table_Count( self.SpawnPoints )
		if count == 0 then
			Msg( "[PlayerSelectSpawn] Error! No spawn points!\n" )
			return
		end

		for num, ent in ipairs( self.SpawnPoints ) do
			if ent:HasSpawnFlags( 1 ) and hook_Call( "IsSpawnpointSuitable", GAMEMODE, ply, ent, true ) then
				return ent
			end
		end

		local ChosenSpawnPoint = nil

		-- Try to work out the best, random spawnpoint
		for i = 1, count do
			ChosenSpawnPoint = table_Random( self.SpawnPoints )

			if IsValid( ChosenSpawnPoint ) and ChosenSpawnPoint:IsInWorld() then
				if (ChosenSpawnPoint == ply:GetVar( "LastSpawnpoint" )) or (ChosenSpawnPoint == self.LastSpawnPoint) and (count > 1) then continue end

				if hook_Call( "IsSpawnpointSuitable", GAMEMODE, ply, ChosenSpawnPoint, i == count ) then
					self.LastSpawnPoint = ChosenSpawnPoint
					ply:SetVar( "LastSpawnpoint", ChosenSpawnPoint )

					return ChosenSpawnPoint
				end
			end
		end

		return ChosenSpawnPoint
	end

end
