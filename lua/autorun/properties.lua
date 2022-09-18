-- include( "properties/kinect_controller.lua" )


-- Bodygroups
do

    local bodygroups = {}
    bodygroups.MenuLabel = "#bodygroups"
    bodygroups.MenuIcon = "icon16/link_edit.png"
    bodygroups.Order = 600

    function bodygroups:Filter( ent, ply )
        if !IsValid( ent ) then return false end
        if ent:IsPlayer() then return false end
        if !gamemode.Call( "CanProperty", ply, "bodygroups", ent ) then return false end
        if IsValid( ent.AttachedEntity ) then
            ent = ent.AttachedEntity
        end

        --
        -- Get a list of bodygroups
        --
        local options = ent:GetBodyGroups();
        if ( !options ) then return false end

        --
        -- If a bodygroup has more than one state - then we can configure it
        --
        for k, v in pairs( options ) do
            if ( v.num > 1 ) then return true end
        end

        return false
    end

    function bodygroups:MenuOpen( option, ent, tr )

        local target = IsValid( ent.AttachedEntity ) and ent.AttachedEntity or ent
        --
        -- Get a list of bodygroups
        --
        local options = target:GetBodyGroups()

        --
        -- Add a submenu to our automatically created menu option
        --
        local submenu = option:AddSubMenu()

        --
        -- For each body group - add a menu or checkbox
        --
        for k, v in pairs( options ) do

            if ( v.num <= 1 ) then continue end

            --
            -- If there's only 2 options, add it as a checkbox instead of a submenu
            --
            if ( v.num == 2 ) then

                local current = target:GetBodygroup( v.id )
                local opposite = 1
                if ( current == opposite ) then opposite = 0 end

                local option = submenu:AddOption( v.name, function() self:SetBodyGroup( ent, v.id, opposite ) end )
                if ( current == 1 ) then
                    option:SetChecked( true )
                end

            --
            -- More than 2 options we add our own submenu
            --
            else
                local groups = submenu:AddSubMenu( v.name )
                for i=1, v.num do
                    local modelname = "model #" .. i
                    if ( v.submodels && v.submodels[ i-1 ] != "" ) then modelname = v.submodels[ i-1 ] end
                    local option = groups:AddOption( modelname, function() self:SetBodyGroup( ent, v.id, i-1 ) end )
                    if ( target:GetBodygroup( v.id ) == i-1 ) then
                        option:SetChecked( true )
                    end
                end
            end
        end
    end

    function bodygroups:Action( ent )
    end

    function bodygroups:SetBodyGroup( ent, body, id )
        self:MsgStart()
            net.WriteEntity( ent )
            net.WriteUInt( body, 8 )
            net.WriteUInt( id, 8 )
        self:MsgEnd()
    end

    function bodygroups:Receive( length, ply )
        local ent = net.ReadEntity()
        local body = net.ReadUInt( 8 )
        local id = net.ReadUInt( 8 )

        if ( !properties.CanBeTargeted( ent, ply ) ) then return end
        if ( !self:Filter( ent, ply ) ) then return end

        ent = IsValid( ent.AttachedEntity ) and ent.AttachedEntity or ent

        ent:SetBodygroup( body, id )
    end

    properties.Add( "bodygroups", bodygroups )

end

-- Skin
do

    local skin = {}

    skin.MenuLabel = "#skin"
	skin.MenuIcon = "icon16/picture_edit.png"
	skin.Order = 601

	function skin:Filter( ent, ply )

		if ( !IsValid( ent ) ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !gamemode.Call( "CanProperty", ply, "skin", ent ) ) then return false end
		if ( IsValid( ent.AttachedEntity ) ) then ent = ent.AttachedEntity end  -- If our ent has an attached entity, we want to modify its skin instead
		if ( !ent:SkinCount() ) then return false end

		return ent:SkinCount() > 1

	end

	function skin:MenuOpen( option, ent, tr )

		--
		-- Add a submenu to our automatically created menu option
		--
		local submenu = option:AddSubMenu()

		--
		-- Create a check item for each skin
		--
		local target = IsValid( ent.AttachedEntity ) and ent.AttachedEntity or ent

		local num = target:SkinCount()

		for i = 0, num - 1 do

			local option = submenu:AddOption( "Skin " .. i, function() self:SetSkin( ent, i ) end )
			if ( target:GetSkin() == i ) then
				option:SetChecked( true )
			end

		end

	end

	function skin:Action( ent )

		-- Nothing - we use SetSkin below

	end

	function skin:SetSkin( ent, id )

		self:MsgStart()
			net.WriteEntity( ent )
			net.WriteUInt( id, 8 )
		self:MsgEnd()

	end

	function skin:Receive( length, ply )

		local ent = net.ReadEntity()
		local skinid = net.ReadUInt( 8 )

		if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end

		ent = IsValid( ent.AttachedEntity ) and ent.AttachedEntity or ent
		ent:SetSkin( skinid )

	end

    properties.Add( "skin", skin )

end

-- Bone Manipulation
do

    do

        local bone_manipulate = {}

        bone_manipulate.MenuLabel = "#edit_bones"
        bone_manipulate.MenuIcon = "icon16/vector.png"
        bone_manipulate.Order = 500

        function bone_manipulate:Filter( ent, ply )

            if ( !gamemode.Call( "CanProperty", ply, "bonemanipulate", ent ) ) then return false end
            if ( IsValid( ent.AttachedEntity ) ) then ent = ent.AttachedEntity end -- If our ent has an attached entity, we want to use and modify its bones instead

            local bonecount = ent:GetBoneCount()
            if ( bonecount <= 1 ) then return false end

            return ents.FindByClassAndParent( "widget_bones", ent ) == nil

        end

        function bone_manipulate:Action( ent )

            if ( IsValid( ent.AttachedEntity ) ) then ent = ent.AttachedEntity end

            self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()

        end

        function bone_manipulate:Receive( length, ply )

            local ent = net.ReadEntity()
            if ( !IsValid( ent ) ) then return end
            if ( !properties.CanBeTargeted( ent, ply ) ) then return end
            if ( !self:Filter( ent, ply ) ) then return end

            ent.widget = ents.Create( "widget_bones" )
            ent.widget:Setup( ent )
            ent.widget:Spawn()
            ent.widget.LastBonePress = 0
            ent.widget.BonePressCount = 0

            -- What happens when we click on a bone?
            ent.widget.OnBoneClick = function( w, boneid, ply )

                -- If we have an old axis, remove it
                if ( IsValid( w.axis ) ) then w.axis:Remove() end

                -- We clicked on the same bone
                if ( w.LastBonePress == boneid ) then
                    w.BonePressCount = w.BonePressCount + 1
                    if ( w.BonePressCount >= 3 ) then w.BonePressCount = 0 end
                -- We clicked on a new bone!
                else
                    w.BonePressCount = 0
                    w.LastBonePress = boneid
                end

                local EntityCycle = { "widget_bonemanip_move", "widget_bonemanip_rotate", "widget_bonemanip_scale" }

                w.axis = ents.Create( EntityCycle[ w.BonePressCount + 1 ] )
                w.axis:Setup( ent, boneid, w.BonePressCount == 1 )
                w.axis:Spawn()
                w.axis:SetPriority( 0.5 )
                w:DeleteOnRemove( w.axis )

            end
        end

        properties.Add( "bone_manipulate", bone_manipulate )

    end

    do

        local bone_manipulate_end = {}

        bone_manipulate_end.MenuLabel = "#stop_editing_bones"
        bone_manipulate_end.MenuIcon = "icon16/vector_delete.png"
        bone_manipulate_end.Order = 500

        function bone_manipulate_end:Filter( ent )

            if ( IsValid( ent.AttachedEntity ) ) then ent = ent.AttachedEntity end -- If our ent has an attached entity, we want to use and modify its bones instead

            return ents.FindByClassAndParent( "widget_bones", ent ) != nil

        end

        function bone_manipulate_end:Action( ent )

            if ( IsValid( ent.AttachedEntity ) ) then ent = ent.AttachedEntity end

            self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()

        end

        function bone_manipulate_end:Receive( length, ply )

            local ent = net.ReadEntity()
            if ( !IsValid( ent ) ) then return end
            if ( !IsValid( ent.widget ) ) then return end

            ent.widget:Remove()

        end

        properties.Add( "bone_manipulate_end", bone_manipulate_end )

    end

    do

        local ENT = {}
        ENT.Base = "widget_axis"

        function ENT:OnArrowDragged( num, dist, pl, mv )

            -- Prediction doesn't work properly yet.. because of the confusion with the bone moving, and the parenting, Agh.
            if ( CLIENT ) then return end

            local ent = self:GetParent()
            if ( !IsValid( ent ) ) then return end

            local bone = self:GetParentAttachment()
            if ( bone <= 0 ) then return end

            local v = Vector( 0, 0, 0 )

            if ( num == 1 ) then v.x = dist end
            if ( num == 2 ) then v.y = dist end
            if ( num == 3 ) then v.z = dist end

            ent:ManipulateBonePosition( bone, ent:GetManipulateBonePosition( bone ) + v )

        end
        --
        -- Although we use the position from our bone, we want to use the angles from the
        -- parent bone - because that's the direction our bone goes
        --
        function ENT:CalcAbsolutePosition( v, a )

            local ent = self:GetParent()
            if ( !IsValid( ent ) ) then return end

            local bone = ent:GetBoneParent( self:GetParentAttachment() )
            if ( bone <= 0 ) then return end

            local _, ang = ent:GetBonePosition( bone )
            local pos = ent:GetBonePosition( self:GetParentAttachment() )
            return pos, ang

        end

        scripted_ents.Register( ENT, "widget_bonemanip_move" )

    end

    do

        local ENT = {}
        ENT.Base = "widget_axis"

        function ENT:OnArrowDragged( num, dist, pl, mv )

            -- Prediction doesn't work properly yet.. because of the confusion with the bone moving, and the parenting, Agh.
            if ( CLIENT ) then return end

            local ent = self:GetParent()
            if ( !IsValid( ent ) ) then return end

            local bone = self:GetParentAttachment()
            if ( bone <= 0 ) then return end

            local v = Angle( 0, 0, 0 )

            if ( num == 2 ) then v.x = dist end
            if ( num == 3 ) then v.y = dist end
            if ( num == 1 ) then v.z = dist end

            ent:ManipulateBoneAngles( bone, ent:GetManipulateBoneAngles( bone ) + v )

        end

        scripted_ents.Register( ENT, "widget_bonemanip_rotate" )

    end

    do

        local ENT = {}
        ENT.Base = "widget_axis"
        ENT.IsScaleArrow = true

        function ENT:OnArrowDragged( num, dist, pl, mv )

            -- Prediction doesn't work properly yet.. because of the confusion with the bone moving, and the parenting, Agh.
            if ( CLIENT ) then return end

            local ent = self:GetParent()
            if ( !IsValid( ent ) ) then return end

            local bone = self:GetParentAttachment()
            if ( bone <= 0 ) then return end

            local v = Vector( 0, 0, 0 )

            if ( num == 1 ) then v.x = dist end
            if ( num == 2 ) then v.y = dist end
            if ( num == 3 ) then v.z = dist end

            ent:ManipulateBoneScale( bone, ent:GetManipulateBoneScale( bone ) + v * 0.1 )
            ent:ManipulateBoneScale( ent:GetBoneParent( bone ), ent:GetManipulateBoneScale( ent:GetBoneParent( bone ) ) + v )

        end
        --
        -- Although we use the position from our bone, we want to use the angles from the
        -- parent bone - because that's the direction our bone goes
        --
        function ENT:CalcAbsolutePosition( v, a )

            local ent = self:GetParent()
            if ( !IsValid( ent ) ) then return end

            local bone = self:GetParentAttachment()
            if ( bone <= 0 ) then return end

            local pbone = ent:GetBoneParent( bone )
            if ( pbone <= 0 ) then return end

            local pos, ang = ent:GetBonePosition( bone )
            local pos2, _ = ent:GetBonePosition( pbone )

            return pos + ( pos2 - pos ) * 0.5, ang

        end

        scripted_ents.Register( ENT, "widget_bonemanip_scale" )

    end
end

--Remove
do

    local remove = {}
    remove.MenuLabel = "#remove"
    remove.MenuIcon = "icon16/delete.png"
    remove.Order = 1000

    function remove:Filter( ent, ply )

        if ( !gamemode.Call( "CanProperty", ply, "remover", ent ) ) then return false end
        if ( !IsValid( ent ) ) then return false end
        if ( ent:IsPlayer() ) then return false end

        return true

    end

    function remove:Action( ent )

        self:MsgStart()
            net.WriteEntity( ent )
        self:MsgEnd()

    end

    function remove:Receive( length, ply )
        if ( !IsValid( ply ) ) then return end

        local ent = net.ReadEntity()
        if ( !IsValid( ent ) ) then return end

        -- Don't allow removal of players or objects that cannot be physically targeted by properties
        if ( !properties.CanBeTargeted( ent, ply ) ) then return end
        if ( !self:Filter( ent, ply ) ) then return end

        -- Remove all constraints (this stops ropes from hanging around)
        constraint.RemoveAll( ent )

        -- Remove it properly in 1 second
        timer.Simple( 1, function() if ( IsValid( ent ) ) then ent:Remove() end end )

        -- Make it non solid
        ent:SetNotSolid( true )
        ent:SetMoveType( MOVETYPE_NONE )
        ent:SetNoDraw( true )

        -- Send Effect
        local ed = EffectData()
        ed:SetEntity( ent )
        util.Effect( "entity_remove", ed, true, true )

        ply:SendLua( "achievements.Remover()" )

    end

    properties.Add( "remove", remove)

end

-- Statue
do

    if ( SERVER ) then

        duplicator.RegisterEntityModifier( "statue_property", function( ply, ent, data )

        if ( !data ) then
            duplicator.ClearEntityModifier( ent, "statue_property" )
            return
        end

        -- We have been pasted from duplicator, restore the necessary variables for the unstatue to work
        if ( ent.StatueInfo == nil ) then

            -- Ew. Have to wait a frame for the constraints to get pasted
            timer.Simple( 0, function()
                if ( !IsValid( ent ) ) then return end

                local bones = ent:GetPhysicsObjectCount()
                if ( bones < 2 ) then return end

                ent:SetNWBool( "IsStatue", true )
                ent.StatueInfo = {}

                local con = constraint.FindConstraints( ent, "Weld" )
                for id, t in pairs( con ) do
                    if ( t.Ent1 != t.Ent2 || t.Ent1 != ent || t.Bone1 != 0 ) then continue end

                    ent.StatueInfo[ t.Bone2 ] = t.Constraint
                end

                local numC = table.Count( ent.StatueInfo )
                if ( numC < 1 --[[or numC != bones - 1]] ) then duplicator.ClearEntityModifier( ent, "statue_property" ) end
            end )
        end

        duplicator.StoreEntityModifier( ent, "statue_property", data )

        end)

    end

    -- Player Timeouts
    do

        local playerTimeouts = {}

        playerTimeouts.MenuLabel = "#makestatue"
        playerTimeouts.MenuIcon = "icon16/lock.png"
        playerTimeouts.Order = 1501

        function playerTimeouts:Filter( ent, ply )
            if ( !IsValid( ent ) ) then return false end
            if ( ent:GetClass() != "prop_ragdoll" ) then return false end
            if ( ent:GetNWBool( "IsStatue" ) ) then return false end
            if ( !gamemode.Call( "CanProperty", ply, "statue", ent ) ) then return false end
            return true
        end

        function playerTimeouts:Filter( ent )

            self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()

        end

        function playerTimeouts:Receive( length, ply )

            local ent = net.ReadEntity()

            if ( !IsValid( ent ) ) then return end
            if ( !IsValid( ply ) ) then return end
            if ( !properties.CanBeTargeted( ent, ply ) ) then return end
            if ( ent:GetClass() != "prop_ragdoll" ) then return end
            if ( !self:Filter( ent, ply ) ) then return end

            -- Do not spam please!
            local timeout = playerTimeouts[ ply ]
            if ( timeout && timeout.time > CurTime() ) then
                if ( !timeout.sentMessage ) then
                    ServerLog( "Player " .. tostring( ply ) .. " tried to use 'statue' property too rapidly!\n" )
                    ply:PrintMessage( HUD_PRINTTALK, "Please wait at least 0.2 seconds before trying to make another ragdoll a statue." )
                    timeout.sentMessage = true
                end
                return
            end

            local bones = ent:GetPhysicsObjectCount()
            if ( bones < 2 ) then return end
            if ( ent.StatueInfo ) then return end

            ent.StatueInfo = {}

            undo.Create( "Statue" )

            for bone = 1, bones - 1 do

                local constraint = constraint.Weld( ent, ent, 0, bone, 0 )

                if ( constraint ) then

                    ent.StatueInfo[ bone ] = constraint
                    ply:AddCleanup( "constraints", constraint )
                    undo.AddEntity( constraint )

                end

                local effectdata = EffectData()
                effectdata:SetOrigin( ent:GetPhysicsObjectNum( bone ):GetPos() )
                effectdata:SetScale( 1 )
                effectdata:SetMagnitude( 1 )
                util.Effect( "GlassImpact", effectdata, true, true )

            end

            ent:SetNWBool( "IsStatue", true )

            undo.AddFunction( function()
                if ( !IsValid( ent ) ) then return false end

                ent:SetNWBool( "IsStatue", false )
                ent.StatueInfo = nil
                StatueDuplicator( ply, ent, nil )

            end )

            undo.SetPlayer( ply )
            undo.Finish()

            StatueDuplicator( ply, ent, {} )

            playerTimeouts[ ply ] = { time = CurTime() + 0.2, sentMessage = false }

        end

        properties.Add( "playerTimeouts", playerTimeouts)

    end

    -- Statue stop
    do

        local statue_stop = {}
        statue_stop.MenuLabel = "#unstatue"
        statue_stop.MenuIcon = "icon16/lock_open.png"
        statue_stop.Order = 1501

        function statue_stop:Filter( ent, ply )
            if ( !IsValid( ent ) ) then return false end
            if ( ent:GetClass() != "prop_ragdoll" ) then return false end
            if ( !ent:GetNWBool( "IsStatue" ) ) then return false end
            if ( !gamemode.Call( "CanProperty", ply, "unstatue", ent ) ) then return false end
            return true
        end

        function statue_stop:Action( ent )

            self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()

        end

        function statue_stop:Receive( length, ply )

            local ent = net.ReadEntity()

            if ( !IsValid( ent ) ) then return end
            if ( !IsValid( ply ) ) then return end
            if ( !properties.CanBeTargeted( ent, ply ) ) then return end
            if ( ent:GetClass() != "prop_ragdoll" ) then return end

            local bones = ent:GetPhysicsObjectCount()
            if ( bones < 2 ) then return end
            if ( !ent.StatueInfo ) then return end

            for k, v in pairs( ent.StatueInfo ) do

                if ( IsValid( v ) ) then
                    v:Remove()
                end

            end

            ent:SetNWBool( "IsStatue", false )
            ent.StatueInfo = nil

            StatueDuplicator( ply, ent, nil )

        end

        properties.Add( "statue_stop", statue_stop)

    end

end

-- Keeping Upright
do

    local keepupright = {}
    keepupright.MenuLabel = "#keepupright"
    keepupright.MenuIcon = "icon16/arrow_up.png"
    keepupright.Order = 900

    function keepupright:Filter( ent, ply )

        if ( !IsValid( ent ) ) then return false end
        if ( ent:GetClass() != "prop_physics" ) then return false end
        if ( ent:GetNWBool( "IsUpright" ) ) then return false end
        if ( !gamemode.Call( "CanProperty", ply, "keepupright", ent ) ) then return false end

        return true
    end

    function keepupright:Action( ent )

        self:MsgStart()
            net.WriteEntity( ent )
        self:MsgEnd()

    end

    function keepupright:Receive( length, ply )

        local ent = net.ReadEntity()

        if ( !IsValid( ent ) ) then return end
        if ( !IsValid( ply ) ) then return end
        if ( !properties.CanBeTargeted( ent, ply ) ) then return end
        if ( ent:GetClass() != "prop_physics" ) then return end
        if ( ent:GetNWBool( "IsUpright" ) ) then return end
        if ( !self:Filter( ent, ply ) ) then return end

        local Phys = ent:GetPhysicsObjectNum( 0 )
        if ( !IsValid( Phys ) ) then return end

        local constraint = constraint.Keepupright( ent, Phys:GetAngles(), 0, 999999 )

        -- I feel like this is not stable enough
        -- This cannot be implemented without a custom constraint.Keepupright function or modification for proper duplicator support.
        --print( constraint:GetSaveTable().m_worldGoalAxis )
        --constraint:SetSaveValue( "m_localTestAxis", constraint:GetSaveTable().m_worldGoalAxis ) --ent:GetAngles():Up() )
        --constraint:SetSaveValue( "m_worldGoalAxis", Vector( 0, 0, 1 ) )
        --constraint:SetSaveValue( "m_bDampAllRotation", true )

        if ( constraint ) then

            ply:AddCleanup( "constraints", constraint )
            ent:SetNWBool( "IsUpright", true )

        end

        properties.Add( "keepupright", keepupright)

    end

-- Stopping keeping up
    do

        local keepupright_stop = {}
        keepupright_stop.MenuLabel = "#keepupright_stop"
        keepupright_stop.MenuIcon = "icon16/arrow_rotate_clockwise.png"
        keepupright_stop.Order = 900

        function keepupright_stop:Filter( ent )
            if ( !IsValid( ent ) ) then return false end
            if ( ent:GetClass() != "prop_physics" ) then return false end
            if ( !ent:GetNWBool( "IsUpright" ) ) then return false end
            return true
        end

        function keepupright_stop:Action( ent )

            self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()

        end

        function keepupright_stop:Receive( length, ply )

            local ent = net.ReadEntity()

            if ( !IsValid( ent ) ) then return end
            if ( !IsValid( ply ) ) then return end
            if ( !properties.CanBeTargeted( ent, ply ) ) then return end
            if ( ent:GetClass() != "prop_physics" ) then return end
            if ( !ent:GetNWBool( "IsUpright" ) ) then return end

            constraint.RemoveConstraints( ent, "Keepupright" )

            ent:SetNWBool( "IsUpright", false )

        end

        properties.Add( "keepupright_stop", keepupright_stop)

    end

end

-- Persisting
do

    local persist = {}
    persist.MenuLabel = "#makepersistent"
    persist.MenuIcon = "icon16/link.png"
    persist.Order = 400

    function persist:Filter( ent, ply )

        if ( ent:IsPlayer() ) then return false end
        if ( GetConVarString( "sbox_persist" ):Trim() == "" ) then return false end
        if ( !gamemode.Call( "CanProperty", ply, "persist", ent ) ) then return false end

        return !ent:GetPersistent()

    end

    function persist:Action( ent )

        self:MsgStart()
            net.WriteEntity( ent )
        self:MsgEnd()

    end

    function persist:Receive( length, ply )

        local ent = net.ReadEntity()
        if ( !IsValid( ent ) ) then return end
        if ( !properties.CanBeTargeted( ent, ply ) ) then return end
        if ( !self:Filter( ent, ply ) ) then return end

        -- TODO: Start some kind of animation, take 5 seconds to make something persistent

        ent:SetPersistent( true )
        --ent:EnableMotion( false )

    end

    properties.Add( "persist", persist)

-- Ending the persisting
    do

        local persist_end = {}
        persist_end.MenuLabel = "#stoppersisting"
        persist_end.MenuIcon = "icon16/link_break.png"
        persist_end.Order = 400

        function persist_end:Filter( ent, ply )

            if ( ent:IsPlayer() ) then return false end
            if ( GetConVarString( "sbox_persist" ):Trim() == "" ) then return false end
            if ( !gamemode.Call( "CanProperty", ply, "persist", ent ) ) then return false end

            return ent:GetPersistent()

        end

        function persist_end:Action( ent )

            self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()

        end

        function persist_end:Receive( length, ply )

            local ent = net.ReadEntity()
            if ( !IsValid( ent ) ) then return end
            if ( !properties.CanBeTargeted( ent, ply ) ) then return end
            if ( !self:Filter( ent, ply ) ) then return end

            -- TODO: Start some kind of animation, take 5 seconds to make something persistent

            ent:SetPersistent( false )

        end

        properties.Add( "persist_end", persist_end )

    end

end

-- Controling an object / drive
do

    local control = {}
    control.MenuLabel = "#drive"
    control.MenuIcon = "icon16/joystick.png"
    control.Order = 1100

    function control:Filter( ent, ply )

        if ( !IsValid( ent ) || !IsValid( ply ) ) then return false end
        if ( ent:IsPlayer() || IsValid( ply:GetVehicle() ) ) then return false end
        if ( !gamemode.Call( "CanProperty", ply, "drive", ent ) ) then return false end
        if ( !gamemode.Call( "CanDrive", ply, ent ) ) then return false end

        -- We cannot drive these, maybe this should have a custom GetEntityDriveMode?
        if ( ent:GetClass() == "prop_vehicle_jeep" || ent:GetClass() == "prop_vehicle_jeep_old" ) then return false end

        -- Make sure nobody else is driving this or we can get into really invalid states
        for id, ply in ipairs( player.GetAll() ) do
            if ( ply:GetDrivingEntity() == ent ) then return false end
        end

        return true

    end

    function control:Action( ent )

        self:MsgStart()
            net.WriteEntity( ent )
        self:MsgEnd()

    end

    function control:Receive( length, ply )

        local ent = net.ReadEntity()
        if ( !properties.CanBeTargeted( ent, ply ) ) then return end
        if ( !self:Filter( ent, ply ) ) then return end

        local drivemode = "drive_sandbox"

        if ( ent.GetEntityDriveMode ) then
            drivemode = ent:GetEntityDriveMode( ply )
        end

        drive.PlayerStartDriving( ply, ent, drivemode )

    end

    properties.Add( "control", control)

end

-- Igniting an object
do

    do

        local function CanEntityBeSetOnFire( ent )
            -- func_pushable, func_breakable & func_physbox cannot be ignited
            if ( ent:GetClass() == "item_item_crate" ) then return true end
            if ( ent:GetClass() == "simple_physics_prop" ) then return true end
            if ( ent:GetClass():match( "prop_physics*") ) then return true end
            if ( ent:GetClass():match( "prop_ragdoll*") ) then return true end
            if ( ent:IsNPC() ) then return true end

            return false
        end

        local ignite = {}
        ignite.MenuLabel = "#ignite"
        ignite.MenuIcon = "icon16/fire.png"
        ignite.Order = 999

        function ignite:Filter( ent, ply )

            if ( !IsValid( ent ) ) then return false end
            if ( ent:IsPlayer() ) then return false end
            if ( !CanEntityBeSetOnFire( ent ) ) then return false end
            if ( !gamemode.Call( "CanProperty", ply, "ignite", ent ) ) then return false end

            return !ent:IsOnFire()
        end

        function ignite:Action( ent )

            self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()

        end

        function ignite:Receive( length, ply )

            local ent = net.ReadEntity()

            if ( !properties.CanBeTargeted( ent, ply ) ) then return end
            if ( !self:Filter( ent, ply ) ) then return end

            ent:Ignite( 360 )

        end

        properties.Add( "ignite", ignite )

    end

    do

        local extinguish = {}
        extinguish.MenuLabel = "#extinguish"
        extinguish.MenuIcon = "icon16/water.png"
        extinguish.Order = 999

        function extinguish:Filter( ent, ply )

            if ( !IsValid( ent ) ) then return false end
            if ( ent:IsPlayer() ) then return false end
            if ( !gamemode.Call( "CanProperty", ply, "extinguish", ent ) ) then return false end

            return ent:IsOnFire()
        end

        function extinguish:Action( ent )

            self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()

        end

        function extinguish:Receive( length, ply )

            local ent = net.ReadEntity()

            if ( !properties.CanBeTargeted( ent, ply ) ) then return end
            if ( !self:Filter( ent, ply ) ) then return end

            ent:Extinguish()

        end

        properties.Add( "extinguish", extinguish )

    end

end

-- Collisions
do

    do

        local collision_off = {}
        collision_off.MenuLabel = "#collision_off"
        collision_off.MenuIcon = "icon16/collision_off.png"
        collision_off.Order = 1500

        function collision_off:Filter( ent, ply )

            if ( !IsValid( ent ) ) then return false end
            if ( ent:IsPlayer() ) then return false end
            if ( !gamemode.Call( "CanProperty", ply, "collision", ent ) ) then return false end
            if ( ent:GetCollisionGroup() == COLLISION_GROUP_WORLD ) then return false end

            return true

        end

        function collision_off:Action( ent )

            self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()

        end

        function collision_off:Receive( length, ply )

            local ent = net.ReadEntity()
            if ( !properties.CanBeTargeted( ent, ply ) ) then return end
            if ( !self:Filter( ent, ply ) ) then return end

            ent:SetCollisionGroup( COLLISION_GROUP_WORLD )

        end

        properties.Add( "collision_off", collision_off )

    end

    do

        local collision_on = {}
        collision_on.MenuLabel = "#collision_on"
        collision_on.MenuIcon = "icon16/collision_on.png"
        collision_on.Order = 1500

        function collision_on:Filter( ent, ply )

            if ( !IsValid( ent ) ) then return false end
            if ( ent:IsPlayer() ) then return false end
            if ( !gamemode.Call( "CanProperty", ply, "collision", ent ) ) then return false end

            return ent:GetCollisionGroup() == COLLISION_GROUP_WORLD

        end

        function collision_on:Action( ent )

            self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()

        end

        function collision_on:Receive( length, ply )

            local ent = net.ReadEntity()
            if ( !properties.CanBeTargeted( ent, ply ) ) then return end
            if ( !self:Filter( ent, ply ) ) then return end

            ent:SetCollisionGroup( COLLISION_GROUP_NONE )

        end

        properties.Add( "collision_on", collision_on )

    end

end

-- Gravity
do

    -- The following is for the server's eyes only
    local GravityDuplicator
    if ( SERVER ) then
        function GravityDuplicator( ply, ent, data )

            if ( !data || !data.enabled ) then

                duplicator.ClearEntityModifier( ent, "gravity_property" )
                return

            end

            -- Simply restore the value whenever we are duplicated
            -- We don't need to reapply EnableGravity because duplicator already does it for us
            ent:SetNWBool( "gravity_disabled", data.enabled )

            duplicator.StoreEntityModifier( ent, "gravity_property", data )

        end
        duplicator.RegisterEntityModifier( "gravity_property", GravityDuplicator )
    end

    do

        local gravity_disabled = {}
        gravity_disabled.MenuLabel = "#gravity"
        gravity_disabled.Order = 1001
        gravity_disabled.Type = "toggle"

        function gravity_disabled:Filter( ent, ply )
            if ( !IsValid( ent ) ) then return false end
            if ( !gamemode.Call( "CanProperty", ply, "gravity", ent ) ) then return false end

            if ( ent:GetClass() == "prop_physics" ) then return true end
            if ( ent:GetClass() == "prop_ragdoll" ) then return true end

            return false
        end

        function gravity_disabled:Checked( ent, ply )
            return ent:GetNWBool( "gravity_disabled" ) == false
        end

        function gravity_disabled:Action( ent )
            self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()
        end

        function gravity_disabled:Receive( length, ply )
            local ent = net.ReadEntity()
            if ( !properties.CanBeTargeted( ent, ply ) ) then return end
            if ( !self:Filter( ent, ply ) ) then return end

            local bones = ent:GetPhysicsObjectCount()
            local b = ent:GetNWBool( "gravity_disabled" )

            for i = 0, bones - 1 do

                local phys = ent:GetPhysicsObjectNum( i )
                if ( IsValid( phys ) ) then
                    phys:EnableGravity( b )
                    phys:Wake()
                end

            end

            ent:SetNWBool( "gravity_disabled", b == false )

            GravityDuplicator( ply, ent, { enabled = ent:GetNWBool( "gravity_disabled" ) } )

        end

        properties.Add( "gravity_disabled", gravity_disabled )

    end

end

-- NPC scaling
do

    do

        local npc_bigger = {}
        npc_bigger.MenuLabel = "#biggify"
        npc_bigger.MenuIcon = "icon16/magnifier_zoom_in.png"
        npc_bigger.Order = 1799

        function npc_bigger:Filter( ent, ply )

            if ( !gamemode.Call( "CanProperty", ply, "npc_bigger", ent ) ) then return false end
            if ( !IsValid( ent ) ) then return false end
            if ( !ent:IsNPC() ) then return false end

            return true

        end

        function npc_bigger:Action( ent )

            self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()

        end

        function npc_bigger:Receive( length, ply )

            local ent = net.ReadEntity()
            if ( !properties.CanBeTargeted( ent, ply ) ) then return end
            if ( !self:Filter( ent, ply ) ) then return end

            ent:SetModelScale( ent:GetModelScale() * 1.25, 1 )

        end

        properties.Add( "npc_bigger", npc_bigger )

    end

    do

        local npc_smaller = {}
        npc_smaller.MenuLabel = "#smallify"
        npc_smaller.MenuIcon = "icon16/magifier_zoom_out.png"
        npc_smaller.Order = 1800

        function npc_smaller:Filter( ent, ply )

            if ( !gamemode.Call( "CanProperty", ply, "npc_smaller", ent ) ) then return false end
            if ( !IsValid( ent ) ) then return false end
            if ( !ent:IsNPC() ) then return false end

            return true

        end

        function npc_smaller:Action( ent )

            self:MsgStart()
                net.WriteEntity( ent )
            self:MsgEnd()

        end

        function npc_smaller:Receive( length, ply )

            local ent = net.ReadEntity()
            if ( !properties.CanBeTargeted( ent, ply ) ) then return end
            if ( !self:Filter( ent, ply ) ) then return end

            ent:SetModelScale( ent:GetModelScale() * 0.8, 1 )

        end

        properties.Add( "npc_smaller", npc_smaller )

    end

end

-- Editing entities
do

    local editentity = {}
    editentity.MenuLabel = "#entedit"
    editentity.MenuIcon = "icon16/pencil.png"
    editentity.PrependSpacer = true
    editentity.Order = 90001

    function editentity:Filter( ent, ply )

        if ( !IsValid( ent ) ) then return false end
        if ( !ent.Editable ) then return false end
        if ( !gamemode.Call( "CanProperty", ply, "editentity", ent ) ) then return false end

        return true

    end

    function editentity:Action( ent )

        local window = g_ContextMenu:Add( "DFrame" )
        window:SetSize( 320, 400 )
        window:SetTitle( tostring( ent ) )
        window:Center()
        window:SetSizable( true )

        local control = window:Add( "DEntityProperties" )
        control:SetEntity( ent )
        control:Dock( FILL )

        control.OnEntityLost = function()

            window:Remove()

        end

    end

    properties.Add( "editentity", editentity )

end