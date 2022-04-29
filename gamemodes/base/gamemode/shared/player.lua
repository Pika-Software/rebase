local player_manager_RunClass = player_manager.RunClass

function GM:PlayerPostThink( ply )
end

function GM:PlayerConnect( nick, ip )
end

function GM:PlayerDriveAnimate( ply )
end

function GM:OnViewModelChanged( vm, old, new )
end

function GM:CanProperty( ply, property, ent )
	return false
end

-- Team System
function GM:CreateTeams()
end

-- Buttons
function GM:KeyPress( ply, key )
end

function GM:KeyRelease( ply, key )
end

-- GM:Move
do

	local drive_Move = drive.Move
	local class_name = "Move"

	function GM:Move( ply, mv )
		if drive_Move( ply, mv ) then
			return true
		end

		if player_manager_RunClass( ply, class_name, mv ) then
			return true
		end
	end

end

-- GM:SetupMove
do

	local drive_StartMove = drive.StartMove
	local class_name = "StartMove"

	function GM:SetupMove( ply, mv, cmd )
		if drive_StartMove( ply, mv, cmd ) then
			return true
		end

		if player_manager_RunClass( ply, class_name, mv, cmd ) then
			return true
		end
	end

end

-- GM:FinishMove
do

	local drive_FinishMove = drive.FinishMove
	local class_name = "FinishMove"

	function GM:FinishMove( ply, mv )
		if drive_FinishMove( ply, mv ) then
			return true
		end

		if player_manager_RunClass( ply, class_name, mv ) then
			return true
		end
	end

end

-- GM:PlayerFootstep
do
	local IsValid = IsValid
	function GM:PlayerFootstep( ply, pos, foot, sound, volume, CRF )
		return IsValid( ply ) and ply:Alive()
	end
end

-- GM:StartEntityDriving
do
	local drive_Start = drive.Start
	function GM:StartEntityDriving( ent, ply )
		drive_Start( ply, ent )
	end
end

-- GM:EndEntityDriving
do
	local drive_End = drive.End
	function GM:EndEntityDriving( ent, ply )
		drive_End( ply, ent )
	end
end

-- Metatable
do

	local table_insert = table.insert
	local gamemode_Call = gamemode.Call

	local PLAYER = FindMetaTable( "Player" )
	function PLAYER:AddFrozenPhysicsObject( ent, phys )
		-- Get the player's table
		local tab = self:GetTable()

		-- Make sure the physics objects table exists
		tab.FrozenPhysicsObjects = tab.FrozenPhysicsObjects or {}

		table_insert(tab.FrozenPhysicsObjects, {
			["ent"] = ent,
			["phys"] = phys
		})

		gamemode_Call( "PlayerFrozeObject", self, ent, phys )
	end

	local function PlayerUnfreezeObject( ply, ent, object )
		-- Not frozen!
		if object:IsMoveable() then return 0 end

		-- Unfreezable means it can't be frozen or unfrozen.
		-- This prevents the player unfreezing the gmod_anchor entity.
		if ent:GetUnFreezable() then return 0 end

		-- NOTE: IF YOU'RE MAKING SOME KIND OF PROP PROTECTOR THEN HOOK "CanPlayerUnfreeze"
		if gamemode_Call( "CanPlayerUnfreeze", ply, ent, object ) then
			object:EnableMotion( true )
			object:Wake()

			gamemode_Call( "PlayerUnfrozeObject", ply, ent, object )

			return 1
		end

		return 0
	end

	do

		local ipairs = ipairs
		local IsValid = IsValid

		do

			local constraint_GetAllConstrainedEntities = SERVER and constraint.GetAllConstrainedEntities
			local CurTime = CurTime

			function PLAYER:PhysgunUnfreeze()
				-- Get the player's table
				local tab = self:GetTable()
				if (tab.FrozenPhysicsObjects == nil) then return 0 end

				-- Detect double click. Unfreeze all objects on double click.
				if (tab.LastPhysUnfreeze and CurTime() - tab.LastPhysUnfreeze < 0.25) then
					return self:UnfreezePhysicsObjects()
				end

				local tr = self:GetEyeTrace()
				if tr.HitNonWorld then
					local entity = tr.Entity
					if IsValid( entity ) then
						local unfrozen = 0

						for num, ent in ipairs( constraint_GetAllConstrainedEntities( entity ) ) do
							local objects = ent:GetPhysicsObjectCount()
							for i = 1, objects do
								local phys = ent:GetPhysicsObjectNum( i - 1 )
								if IsValid( phys ) then
									unfrozen = unfrozen + PlayerUnfreezeObject( self, ent, phys )
								end
							end
						end

						return unfrozen
					end
				end

				tab.LastPhysUnfreeze = CurTime()

				return 0
			end

		end

		function PLAYER:UnfreezePhysicsObjects()
			-- Get the player's table
			local tab = self:GetTable()

			-- If the table doesn't exist then quit here
			if (tab.FrozenPhysicsObjects == nil) then return 0 end

			local count = 0

			-- Loop through each table in our table
			for num, data in ipairs( tab.FrozenPhysicsObjects ) do
				local ent = data.ent
				if IsValid( ent ) then
					local phys = data.phys
					if IsValid( phys ) then
						if phys:IsMoveable() then continue end

						-- We need to freeze/unfreeze all physobj's in jeeps to stop it spazzing
						if (ent:GetClass() == "prop_vehicle_jeep") then

							-- Loop through each one
							for i = 0, (ent:GetPhysicsObjectCount() - 1) do
								local phys = ent:GetPhysicsObjectNum(i)
								if IsValid( phys ) then
									PlayerUnfreezeObject( self, ent, phys )
								end
							end

						end

						count = count + PlayerUnfreezeObject( self, ent, phys )
					end
				end
			end

			-- Remove the table
			tab.FrozenPhysicsObjects = nil

			return count
		end

	end

	local g_UniqueIDTable = {}
	function PLAYER:UniqueIDTable( key )
		local id = 0

		if (SERVER) then
			id = self:UniqueID()
		end

		g_UniqueIDTable[ id ] = g_UniqueIDTable[ id ] or {}
		g_UniqueIDTable[ id ][ key ] = g_UniqueIDTable[ id ][ key ] or {}

		return g_UniqueIDTable[ id ][ key ]
	end

	do

		local FrameNumber = FrameNumber
		local util_TraceLine = util.TraceLine
		local util_GetPlayerTrace = util.GetPlayerTrace

		function PLAYER:GetEyeTrace()
			if (CLIENT) then
				local framenum = FrameNumber()

				if (self.LastPlayerTrace == framenum) then
					return self.PlayerTrace
				end

				self.LastPlayerTrace = framenum
			end

			local tr = util_TraceLine( util_GetPlayerTrace( self ) )
			self.PlayerTrace = tr

			return tr
		end

		function PLAYER:GetEyeTraceNoCursor()
			if (CLIENT) then
				local framenum = FrameNumber()

				if (self.LastPlayerAimTrace == framenum) then
					return self.PlayerAimTrace
				end

				self.LastPlayerAimTrace = framenum
			end

			local tr = util_TraceLine(util_GetPlayerTrace(self, self:EyeAngles():Forward()))
			self.PlayerAimTrace = tr

			return tr
		end

	end

	if (CLIENT) then
		if (PLAYER.OriginalConCommand == nil) then
			PLAYER.OriginalConCommand = PLAYER.ConCommand
		end

		local CommandList = nil
		local ply = nil

		do
			local IsConCommandBlocked = IsConCommandBlocked
			function PLAYER:ConCommand( command, skip )
				if not IsValid( ply ) then
					ply = self
				end

				if (skip == true) or IsConCommandBlocked( command ) then
					self:OriginalConCommand( command )
				else
					CommandList = CommandList or {}
					table_insert( CommandList, command )
				end
			end
		end

		do

			local ipairs = ipairs
			local table_remove = table.remove
			local table_IsEmpty = table.IsEmpty

			hook.Add("Tick", "SendQueuedConsoleCommands", function()
				if (CommandList == nil) or (ply == nil) then return end

				local BytesSent = 0
				for num, cmd in ipairs( CommandList ) do
					ply:OriginalConCommand( cmd )
					table_remove( CommandList, num )

					-- Only send x bytes per tick
					BytesSent = BytesSent + cmd:len()
					if (BytesSent > 128) then
						break
					end
				end

				if table_IsEmpty( CommandList ) then
					CommandList = nil
				end
			end)

		end

	end

end