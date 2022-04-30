do

	local MOVETYPE_NOCLIP = MOVETYPE_NOCLIP
	local ACT_MP_JUMP = ACT_MP_JUMP

	local CurTime = CurTime

	function GM:HandlePlayerJumping( ply, vel )
		if (ply:GetMoveType() == MOVETYPE_NOCLIP) then
			ply.m_bJumping = false
			return
		end

		if (ply.m_bJumping == true) or ply:OnGround() and (ply:WaterLevel() > 0) then
			if (ply.m_bJumping == true) then
				if (ply.m_bFirstJumpFrame == true) then
					ply.m_bFirstJumpFrame = false
					ply:AnimRestartMainSequence()
				end

				if (ply:WaterLevel() >= 2) or ((CurTime() - ply.m_flJumpStartTime) > 0.2 and ply:OnGround()) then
					ply.m_bJumping = false
					ply.m_fGroundTime = nil
					ply:AnimRestartMainSequence()
				end

				if (ply.m_bJumping == true) then
					ply.CalcIdeal = ACT_MP_JUMP
					return true
				end
			end
		else
			if (ply.m_fGroundTime == nil) then
				ply.m_fGroundTime = CurTime()
			elseif ((CurTime() - ply.m_fGroundTime) > 0) and (vel:Length2DSqr() < 0.25) then
				ply.m_bFirstJumpFrame = false
				ply.m_flJumpStartTime = 0
				ply.m_bJumping = true
			end
		end

		return false
	end

end

do

	local ACT_MP_CROUCH_IDLE = ACT_MP_CROUCH_IDLE
	local ACT_MP_CROUCHWALK = ACT_MP_CROUCHWALK
	local FL_ANIMDUCKING = FL_ANIMDUCKING

	function GM:HandlePlayerDucking( ply, vel )
		if ply:IsFlagSet( FL_ANIMDUCKING ) then
			if (vel:Length2DSqr() > 0.25) then
				ply.CalcIdeal = ACT_MP_CROUCHWALK
			else
				ply.CalcIdeal = ACT_MP_CROUCH_IDLE
			end

			return true
		end

		return false
	end

end

do

	local ACT_GMOD_NOCLIP_LAYER = ACT_GMOD_NOCLIP_LAYER
	local GESTURE_SLOT_CUSTOM = GESTURE_SLOT_CUSTOM
	local MOVETYPE_NOCLIP = MOVETYPE_NOCLIP

	function GM:HandlePlayerNoClipping( ply, vel )
		if (ply:GetMoveType() ~= MOVETYPE_NOCLIP) or ply:InVehicle() then
			if (ply.m_bWasNoclipping == true) then
				ply.m_bWasNoclipping = nil
				ply:AnimResetGestureSlot( GESTURE_SLOT_CUSTOM )

				if (CLIENT) then
					ply:SetIK( true )
				end
			end

			return
		end

		if (ply.m_bWasNoclipping == nil) then
			ply:AnimRestartGesture( GESTURE_SLOT_CUSTOM, ACT_GMOD_NOCLIP_LAYER, false )

			if (CLIENT) then
				ply:SetIK( false )
			end
		end

		return true
	end

end

do

	local ACT_MP_SWIM = ACT_MP_SWIM
	local max_vel = 1000000

	function GM:HandlePlayerVaulting( ply, vel )
		if (vel:LengthSqr() < max_vel) then return end
		if ply:IsOnGround() then return end

		ply.CalcIdeal = ACT_MP_SWIM

		return true
	end

	function GM:HandlePlayerSwimming( ply, vel )
		if (ply:WaterLevel() < 2) or ply:IsOnGround() then
			ply.m_bInSwim = false
			return false
		end

		ply.CalcIdeal = ACT_MP_SWIM
		ply.m_bInSwim = true

		return true
	end

end

do

	local GESTURE_SLOT_JUMP = GESTURE_SLOT_JUMP
	local MOVETYPE_NOCLIP = MOVETYPE_NOCLIP
	local ACT_LAND = ACT_LAND

	function GM:HandlePlayerLanding( ply, vel, WasOnGround )
		if (ply:GetMoveType() == MOVETYPE_NOCLIP) then return end
		if ply:IsOnGround() and (WasOnGround == false) then
			ply:AnimRestartGesture( GESTURE_SLOT_JUMP, ACT_LAND, true )
		end
	end

end

do

	local class_to_anim = {
		["prop_vehicle_jeep"] = "drive_jeep",
		["prop_vehicle_airboat"] = "drive_airboat",
		["prop_vehicle_prisoner_pod"] = {"drive_pd", "models/vehicles/prisoner_pod_inner.mdl", }
	}

	local isfunction = isfunction
	local list_Get = list.Get
	local IsValid = IsValid

	function GM:HandlePlayerDriving( ply )
		if ply:InVehicle() and IsValid( ply:GetParent() ) then
			local veh = ply:GetVehicle()
			if not veh.HandleAnimation and (veh.GetVehicleClass ~= nil) then
				local tbl = list_Get( "Vehicles" )[ veh:GetVehicleClass() ]
				if (tbl ~= nil) and (tbl.Members ~= nil) and (tbl.Members.HandleAnimation ~= nil) then
					veh.HandleAnimation = tbl.Members.HandleAnimation
				else
					veh.HandleAnimation = true -- Prevent this if block from trying to assign HandleAnimation again.
				end
			end

			if isfunction( veh.HandleAnimation ) then
				local seq = veh:HandleAnimation( ply )
				if ( seq ~= nil ) then
					ply.CalcSeqOverride = seq
				end
			end

			-- veh.HandleAnimation did not give us an animation
			if (ply.CalcSeqOverride == -1) then
				local seq_name = class_to_anim[ veh:GetClass() ]
				if (seq_name == nil) then
					ply.CalcSeqOverride = ply:LookupSequence( "sit_rollercoaster" )
				else

					if istable( seq_name ) and (veh:GetModel() == seq_name[2]) then
						ply.CalcSeqOverride = ply:LookupSequence( seq_name[1] )
					else
						ply.CalcSeqOverride = ply:LookupSequence( seq_name )
					end

				end
			end

			if (ply.CalcSeqOverride == ply:LookupSequence( "sit_rollercoaster" )) or (ply.CalcSeqOverride == ply:LookupSequence( "sit" )) and ply:GetAllowWeaponsInVehicle() then
				local wep = ply:GetActiveWeapon()
				if IsValid( wep ) then
					local holdtype = wep:GetHoldType()
					if (holdtype == "smg") then
						holdtype = "smg1"
					end

					local seqid = ply:LookupSequence( "sit_" .. holdtype )
					if (seqid == -1) then return true end

					ply.CalcSeqOverride = seqid
				end
			end

			return true
		end

		return false
	end

end

--[[---------------------------------------------------------
   Name: gamemode:UpdateAnimation()
   Desc: Animation updates (pose params etc) should be done here
-----------------------------------------------------------]]
do

	local math_NormalizeAngle = math.NormalizeAngle
	local math_max = math.max
	local math_min = math.min

	local up_offset = Vector( 0, 0, 1 )

	function GM:UpdateAnimation( ply, vel, maxseqgroundspeed )
		local len = vel:Length()
		local rate = math_min( (len > 0.2) and (len / maxseqgroundspeed) or 1, 2 )

		-- if we're under water we want to constantly be swimming..
		if (ply:WaterLevel() >= 2) then
			rate = math_max( rate, 0.5 )
		elseif (ply:IsOnGround() == false) and (len >= 1000) then
			rate = 0.1
		end

		ply:SetPlaybackRate( rate )

		-- We only need to do this clientside..
		if (CLIENT) then
			if ply:InVehicle() then
				local veh = ply:GetVehicle()
				local fwd = veh:GetUp()
				local dp = fwd:Dot( up_offset )

				ply:SetPoseParameter( "vertical_velocity", ( dp < 0 and dp or 0 ) + fwd:Dot( veh:GetVelocity() ) * 0.005 )

				if (veh:GetClass() == "prop_vehicle_prisoner_pod") then
					ply:SetPoseParameter( "vehicle_steer", 0 )
					ply:SetPoseParameter( "aim_yaw", math_NormalizeAngle( ply:GetAimVector():Angle()[2] - veh:GetAngles()[2] - 90 ) )
				else
					ply:SetPoseParameter( "vehicle_steer", veh:GetPoseParameter( "vehicle_steer" ) * 2 - 1 )
				end
			end

			hook.Run( "GrabEarAnimation", ply )
			hook.Run( "MouthMoveAnimation", ply )
			-- GAMEMODE:GrabEarAnimation( ply )
			-- GAMEMODE:MouthMoveAnimation( ply )

		end
	end

end

--
-- If you don't want the player to grab his ear in your gamemode then
-- just override this.
--
do

	local GESTURE_SLOT_VCD = GESTURE_SLOT_VCD
	local ACT_GMOD_IN_CHAT = ACT_GMOD_IN_CHAT

	local math_Approach = math.Approach
	local FrameTime = FrameTime

	function GM:GrabEarAnimation( ply )

		-- Don't show this when we're playing a taunt!
		if ply:IsPlayingTaunt() then return end

		ply.ChatGestureWeight = ply.ChatGestureWeight or 0

		if ply:IsTyping() then
			ply.ChatGestureWeight = math_Approach( ply.ChatGestureWeight, 1, FrameTime() * 5.0 )
		else
			ply.ChatGestureWeight = math_Approach( ply.ChatGestureWeight, 0, FrameTime() * 5.0 )
		end

		if ( ply.ChatGestureWeight > 0 ) then
			ply:AnimRestartGesture( GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true )
			ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, ply.ChatGestureWeight )
		end

	end

end

--
-- Moves the mouth when talking on voicecom
--

do

	module( "mouth", package.seeall )

	local mouth_flexes = {
		"right_mouth_drop",
		"left_mouth_drop",
		"right_part",
		"left_part",
		"jaw_drop"
	}

	local table_insert = table.insert
	local math_Clamp = math.Clamp
	local ipairs = ipairs

	function AddFlex( name )
		assert( isstring( name ), "Flex name must be a string!" )
		table_insert( mouth_flexes, name )
	end

	function RemoveFlex( name )
		if isnumber( name ) then
			table.remove( mouth_flexes, name )
			return
		end

		for num, value in ipairs( mouth_flexes ) do
			if (value == name) then
				table.remove( mouth_flexes, num )
			end
		end
	end

	local flex_cache = {}
	function GM:MouthMoveAnimation( ply )
		local flexes = flex_cache[ ply:GetModel() ]
		if (flexes == false) then return end

		if (flexes == nil) then
			flexes = {}

			for num, flex_name in ipairs( mouth_flexes ) do
				local id = ply:GetFlexIDByName( flex_name )
				if (id == nil) then continue end
				table_insert( flexes, id )
			end

			flex_cache[ ply:GetModel() ] = #flexes > 0 and flexes or false
		end

		local weight = ply:IsSpeaking() and math_Clamp( ply:VoiceVolume() * 2, 0, 2 ) or 0
		for key, id in ipairs( flexes ) do
			ply:SetFlexWeight( id, weight )
		end
	end

end

do

	local ACT_MP_STAND_IDLE = ACT_MP_STAND_IDLE
	local MOVETYPE_NOCLIP = MOVETYPE_NOCLIP
	local ACT_MP_WALK = ACT_MP_WALK
	local ACT_MP_RUN = ACT_MP_RUN

	function GM:CalcMainActivity( ply, vel )
		ply.CalcIdeal = ACT_MP_STAND_IDLE
		ply.CalcSeqOverride = -1

		self:HandlePlayerLanding( ply, vel, ply.m_bWasOnGround )

		if not ( self:HandlePlayerNoClipping( ply, vel ) or
			self:HandlePlayerDriving( ply ) or
			self:HandlePlayerVaulting( ply, vel ) or
			self:HandlePlayerJumping( ply, vel ) or
			self:HandlePlayerSwimming( ply, vel ) or
			self:HandlePlayerDucking( ply, vel ) ) then

			local len2d = vel:Length2DSqr()
			if (len2d > 22500) then
				ply.CalcIdeal = ACT_MP_RUN
			elseif (len2d > 0.25) then
				ply.CalcIdeal = ACT_MP_WALK
			end
		end

		ply.m_bWasOnGround = ply:IsOnGround()
		ply.m_bWasNoclipping = (ply:GetMoveType() == MOVETYPE_NOCLIP) and (ply:InVehicle() == false)

		return ply.CalcIdeal, ply.CalcSeqOverride
	end

end

do

	local IdleActivity = ACT_HL2MP_IDLE
	local IdleActivityTranslate = {
		[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = IdleActivity + 5,
		[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = IdleActivity + 5,
		[ ACT_MP_RELOAD_CROUCH ] = IdleActivity + 6,
		[ ACT_MP_RELOAD_STAND ] = IdleActivity + 6,
		[ ACT_MP_CROUCH_IDLE ] = IdleActivity + 3,
		[ ACT_MP_CROUCHWALK ] = IdleActivity + 4,
		[ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_SLAM,
		[ ACT_MP_STAND_IDLE ] = IdleActivity,
		[ ACT_MP_SWIM ] = IdleActivity + 9,
		[ ACT_MP_WALK ] = IdleActivity + 1,
		[ ACT_MP_RUN ] = IdleActivity + 2,
		[ ACT_LAND ] = ACT_LAND
	}

	-- it is preferred you return ACT_MP_* in CalcMainActivity, and if you have a specific need to not tranlsate through the weapon do it here
	function GM:TranslateActivity( ply, act )
		local newact = ply:TranslateWeaponActivity( act )
		return (act == newact) and IdleActivityTranslate[ act ] or newact
	end

end

do

	local PLAYERANIMEVENT_ATTACK_PRIMARY = PLAYERANIMEVENT_ATTACK_PRIMARY

	local ACT_MP_ATTACK_CROUCH_PRIMARYFIRE = ACT_MP_ATTACK_CROUCH_PRIMARYFIRE
	local ACT_MP_ATTACK_STAND_PRIMARYFIRE = ACT_MP_ATTACK_STAND_PRIMARYFIRE

	local ACT_VM_SECONDARYATTACK = ACT_VM_SECONDARYATTACK

	local GESTURE_SLOT_ATTACK_AND_RELOAD = GESTURE_SLOT_ATTACK_AND_RELOAD

	local ACT_MP_RELOAD_CROUCH = ACT_MP_RELOAD_CROUCH
	local ACT_MP_RELOAD_STAND = ACT_MP_RELOAD_STAND

	local PLAYERANIMEVENT_ATTACK_SECONDARY = PLAYERANIMEVENT_ATTACK_SECONDARY
	local PLAYERANIMEVENT_CANCEL_RELOAD = PLAYERANIMEVENT_CANCEL_RELOAD
	local PLAYERANIMEVENT_RELOAD = PLAYERANIMEVENT_RELOAD
	local PLAYERANIMEVENT_JUMP = PLAYERANIMEVENT_JUMP

	local ACT_VM_PRIMARYATTACK = ACT_VM_PRIMARYATTACK
	local ACT_INVALID = ACT_INVALID

	local FL_ANIMDUCKING = FL_ANIMDUCKING

	local CurTime = CurTime

	function GM:DoAnimationEvent( ply, event, data )
		if (event == PLAYERANIMEVENT_ATTACK_PRIMARY) then
			if ply:IsFlagSet( FL_ANIMDUCKING ) then
				ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PRIMARYFIRE, true )
			else
				ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_PRIMARYFIRE, true )
			end

			return ACT_VM_PRIMARYATTACK
		elseif (event == PLAYERANIMEVENT_ATTACK_SECONDARY) then
			return ACT_VM_SECONDARYATTACK
		elseif (event == PLAYERANIMEVENT_RELOAD) then
			if ply:IsFlagSet( FL_ANIMDUCKING ) then
				ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_CROUCH, true )
			else
				ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_STAND, true )
			end

			return ACT_INVALID
		elseif (event == PLAYERANIMEVENT_JUMP) then
			ply.m_bJumping = true
			ply.m_bFirstJumpFrame = true
			ply.m_flJumpStartTime = CurTime()

			ply:AnimRestartMainSequence()

			return ACT_INVALID
		elseif (event == PLAYERANIMEVENT_CANCEL_RELOAD) then
			ply:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )

			return ACT_INVALID
		end
	end

end