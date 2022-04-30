if (GM.DisableStockUI == true) then
    return
end

-- Scoreboard
do

    module( "scoreboard", package.seeall )

    surface.CreateFont( "ScoreboardDefault", {
        ["font"] = "Helvetica",
        ["size"] = 22,
        ["weight"] = 800
    })

    surface.CreateFont( "ScoreboardDefaultTitle", {
        font	= "Helvetica",
        size	= 32,
        weight	= 800
    } )


    do

        PLAYER = {}

        function PLAYER:Init()
            self.AvatarButton = self:Add( "DButton" )
            self.AvatarButton:Dock( LEFT )
            self.AvatarButton:SetSize( 32, 32 )
            self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

            self.Avatar = vgui.Create( "AvatarImage", self.AvatarButton )
            self.Avatar:SetSize( 32, 32 )
            self.Avatar:SetMouseInputEnabled( false )

            self.Name = self:Add( "DLabel" )
            self.Name:Dock( FILL )
            self.Name:SetFont( "ScoreboardDefault" )
            self.Name:SetTextColor( Color( 93, 93, 93 ) )
            self.Name:DockMargin( 8, 0, 0, 0 )

            self.Mute = self:Add( "DImageButton" )
            self.Mute:SetSize( 32, 32 )
            self.Mute:Dock( RIGHT )

            self.Ping = self:Add( "DLabel" )
            self.Ping:Dock( RIGHT )
            self.Ping:SetWidth( 50 )
            self.Ping:SetFont( "ScoreboardDefault" )
            self.Ping:SetTextColor( Color( 93, 93, 93 ) )
            self.Ping:SetContentAlignment( 5 )

            self.Deaths = self:Add( "DLabel" )
            self.Deaths:Dock( RIGHT )
            self.Deaths:SetWidth( 50 )
            self.Deaths:SetFont( "ScoreboardDefault" )
            self.Deaths:SetTextColor( Color( 93, 93, 93 ) )
            self.Deaths:SetContentAlignment( 5 )

            self.Kills = self:Add( "DLabel" )
            self.Kills:Dock( RIGHT )
            self.Kills:SetWidth( 50 )
            self.Kills:SetFont( "ScoreboardDefault" )
            self.Kills:SetTextColor( Color( 93, 93, 93 ) )
            self.Kills:SetContentAlignment( 5 )

            self:Dock( TOP )
            self:DockPadding( 3, 3, 3, 3 )
            self:SetHeight( 32 + 3 * 2 )
            self:DockMargin( 2, 0, 2, 2 )
        end

        function PLAYER:Update()

            if ( !IsValid( self.Player ) ) then
                self:SetZPos( 9999 ) -- Causes a rebuild
                self:Remove()
                return
            end

            self.Avatar:SetPlayer( self.Player )

            if ( self.PName == nil || self.PName != self.Player:Nick() ) then
                self.PName = self.Player:Nick()
                self.Name:SetText( self.PName )
            end

            if ( self.NumKills == nil || self.NumKills != self.Player:Frags() ) then
                self.NumKills = self.Player:Frags()
                self.Kills:SetText( self.NumKills )
            end

            if ( self.NumDeaths == nil || self.NumDeaths != self.Player:Deaths() ) then
                self.NumDeaths = self.Player:Deaths()
                self.Deaths:SetText( self.NumDeaths )
            end

            if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
                self.NumPing = self.Player:Ping()
                self.Ping:SetText( self.NumPing )
            end

            --
            -- Change the icon of the mute button based on state
            --
            if ( self.Muted == nil || self.Muted != self.Player:IsMuted() ) then

                self.Muted = self.Player:IsMuted()
                if ( self.Muted ) then
                    self.Mute:SetImage( "icon32/muted.png" )
                else
                    self.Mute:SetImage( "icon32/unmuted.png" )
                end

                self.Mute.DoClick = function( s ) self.Player:SetMuted( !self.Muted ) end
                self.Mute.OnMouseWheeled = function( s, delta )
                    self.Player:SetVoiceVolumeScale( self.Player:GetVoiceVolumeScale() + ( delta / 100 * 5 ) )
                    s.LastTick = CurTime()
                end

                self.Mute.PaintOver = function( s, w, h )
                    if ( !IsValid( self.Player ) ) then return end

                    local a = 255 - math.Clamp( CurTime() - ( s.LastTick or 0 ), 0, 3 ) * 255
                    if ( a <= 0 ) then return end

                    draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, a * 0.75 ) )
                    draw.SimpleText( math.ceil( self.Player:GetVoiceVolumeScale() * 100 ) .. "%", "DermaDefaultBold", w / 2, h / 2, Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end

            end

            --
            -- Connecting players go at the very bottom
            --
            if ( self.Player:Team() == TEAM_CONNECTING ) then
                self:SetZPos( 2000 + self.Player:EntIndex() )
                return
            end

            --
            -- This is what sorts the list. The panels are docked in the z order,
            -- so if we set the z order according to kills they'll be ordered that way!
            -- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
            --
            self:SetZPos( ( self.NumKills * -50 ) + self.NumDeaths + self.Player:EntIndex() )
        end

        function PLAYER:Paint( w, h )
            if ( !IsValid( self.Player ) ) then
                return
            end

            --
            -- We draw our background a different colour based on the status of the player
            --

            if ( self.Player:Team() == TEAM_CONNECTING ) then
                draw.RoundedBox( 4, 0, 0, w, h, Color( 200, 200, 200, 200 ) )
                return
            end

            if ( !self.Player:Alive() ) then
                draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 200, 200, 255 ) )
                return
            end

            if ( self.Player:IsAdmin() ) then
                draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 255, 230, 255 ) )
                return
            end

            draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 230, 230, 255 ) )
        end

        PLAYER = vgui.RegisterTable( PLAYER, "DPanel" )

    end

    do

        SCORE_BOARD = {}

        function SCORE_BOARD:Init()
            self.Header = self:Add( "Panel" )
            self.Header:Dock( TOP )
            self.Header:SetHeight( 100 )

            self.Name = self.Header:Add( "DLabel" )
            self.Name:SetFont( "ScoreboardDefaultTitle" )
            self.Name:SetTextColor( color_white )
            self.Name:Dock( TOP )
            self.Name:SetHeight( 40 )
            self.Name:SetContentAlignment( 5 )
            self.Name:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )

            self.NumPlayers = self.Header:Add( "DLabel" )
            self.NumPlayers:SetFont( "ScoreboardDefault" )
            self.NumPlayers:SetTextColor( color_white )
            self.NumPlayers:SetPos( 0, 100 - 30 )
            self.NumPlayers:SetSize( 300, 30 )
            self.NumPlayers:SetContentAlignment( 4 )

            self.Scores = self:Add( "DScrollPanel" )
            self.Scores:Dock( FILL )
        end

        function SCORE_BOARD:PerformLayout( w, h )
            self:SetSize( 700, ScrH() - 200 )
            self:SetPos( ScrW() / 2 - 350, 100 )
        end

        function SCORE_BOARD:Paint( w, h )
            -- draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
        end

        function SCORE_BOARD:Update()
            self.Name:SetText( GetHostName() )

            for num, pnl in ipairs( self.Scores:GetCanvas():GetChildren() ) do
                pnl:Update()
            end

            local players = player.GetAll()
            self.NumPlayers:SetText( #players .. " / " .. game.MaxPlayers() )

            for num, ply in ipairs( players ) do
                local hasPanel = false
                for num, pnl in ipairs( self.Scores:GetCanvas():GetChildren() ) do
                    if IsValid( pnl.Player ) and (pnl.Player:EntIndex() == ply:EntIndex()) then
                        hasPanel = true
                        break
                    end
                end

                if (hasPanel) then continue end

                local pnl = vgui.CreateFromTable( PLAYER )
                pnl.Player = ply
                pnl:Update()

                self.Scores:AddItem( pnl )

            end
        end

        SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" )

    end

    if IsValid( g_Scoreboard ) then
        g_Scoreboard:Remove()
    end

    function GM:ScoreboardShow()
        if not IsValid( g_Scoreboard ) then
            g_Scoreboard = vgui.CreateFromTable( SCORE_BOARD )
        end

        if IsValid( g_Scoreboard ) then
            g_Scoreboard:Show()
            g_Scoreboard:Update()
            g_Scoreboard:MakePopup()
            g_Scoreboard:SetKeyboardInputEnabled( false )
        end
    end

    function GM:ScoreboardHide()
        if IsValid( g_Scoreboard ) then
            g_Scoreboard:Hide()
        end
    end

    function GM:HUDDrawScoreBoard()
    end

end

-- Voice
do

    local PANEL = {}
    local PlayerVoicePanels = {}

    function PANEL:Init()

        self.LabelName = vgui.Create( "DLabel", self )
        self.LabelName:SetFont( "GModNotify" )
        self.LabelName:Dock( FILL )
        self.LabelName:DockMargin( 8, 0, 0, 0 )
        self.LabelName:SetTextColor( color_white )

        self.Avatar = vgui.Create( "AvatarImage", self )
        self.Avatar:Dock( LEFT )
        self.Avatar:SetSize( 32, 32 )

        self.Color = color_transparent

        self:SetSize( 250, 32 + 8 )
        self:DockPadding( 4, 4, 4, 4 )
        self:DockMargin( 2, 2, 2, 2 )
        self:Dock( BOTTOM )

    end

    function PANEL:Setup( ply )

        self.ply = ply
        self.LabelName:SetText( ply:Nick() )
        self.Avatar:SetPlayer( ply )

        self.Color = team.GetColor( ply:Team() )

        self:InvalidateLayout()

    end

    function PANEL:Paint( w, h )

        if ( !IsValid( self.ply ) ) then return end
        draw.RoundedBox( 4, 0, 0, w, h, Color( 0, self.ply:VoiceVolume() * 255, 0, 240 ) )

    end

    function PANEL:Think()

        if ( IsValid( self.ply ) ) then
            self.LabelName:SetText( self.ply:Nick() )
        end

        if ( self.fadeAnim ) then
            self.fadeAnim:Run()
        end

    end

    function PANEL:FadeOut( anim, delta, data )

        if ( anim.Finished ) then

            if ( IsValid( PlayerVoicePanels[ self.ply ] ) ) then
                PlayerVoicePanels[ self.ply ]:Remove()
                PlayerVoicePanels[ self.ply ] = nil
                return
            end

        return end

        self:SetAlpha( 255 - ( 255 * delta ) )

    end

    derma.DefineControl( "VoiceNotify", "", PANEL, "DPanel" )

    function GM:PlayerStartVoice( ply )

        if ( !IsValid( g_VoicePanelList ) ) then return end

        -- There'd be an exta one if voice_loopback is on, so remove it.
        GAMEMODE:PlayerEndVoice( ply )


        if ( IsValid( PlayerVoicePanels[ ply ] ) ) then

            if ( PlayerVoicePanels[ ply ].fadeAnim ) then
                PlayerVoicePanels[ ply ].fadeAnim:Stop()
                PlayerVoicePanels[ ply ].fadeAnim = nil
            end

            PlayerVoicePanels[ ply ]:SetAlpha( 255 )

            return

        end

        if ( !IsValid( ply ) ) then return end

        local pnl = g_VoicePanelList:Add( "VoiceNotify" )
        pnl:Setup( ply )

        PlayerVoicePanels[ ply ] = pnl

    end

    timer.Create( "VoiceClean", 10, 0, function()

        for k, v in pairs( PlayerVoicePanels ) do

            if ( !IsValid( k ) ) then
                GAMEMODE:PlayerEndVoice( k )
            end

        end

    end )

    function GM:PlayerEndVoice( ply )

        if ( IsValid( PlayerVoicePanels[ ply ] ) ) then

            if ( PlayerVoicePanels[ ply ].fadeAnim ) then return end

            PlayerVoicePanels[ ply ].fadeAnim = Derma_Anim( "FadeOut", PlayerVoicePanels[ ply ], PlayerVoicePanels[ ply ].FadeOut )
            PlayerVoicePanels[ ply ].fadeAnim:Start( 2 )

        end

    end

    hook.Add( "InitPostEntity", "CreateVoiceVGUI", function()

        g_VoicePanelList = vgui.Create( "DPanel" )

        g_VoicePanelList:ParentToHUD()
        g_VoicePanelList:SetPos( ScrW() - 300, 100 )
        g_VoicePanelList:SetSize( 250, ScrH() - 200 )
        g_VoicePanelList:SetPaintBackground( false )

    end )

end

-- TargetID
do

	local TEAM_UNASSIGNED = TEAM_UNASSIGNED

	local surface_GetTextSize = surface.GetTextSize
	local draw_SimpleText = draw.SimpleText
	local surface_SetFont = surface.SetFont
	local team_GetColor = team.GetColor
	local gui_MousePos = gui.MousePos
	local font = "TargetID"
	local ScrW = ScrW
	local ScrH = ScrH

	local col1 = Color( 0, 0, 0, 120 )
	local col2 = Color( 0, 0, 0, 50 )

	hook.Add("PlayerInitialized", "HUDDrawTargetID", function( ply )
		hook.Add("HUDPaint", "HUDDrawTargetID", function()
			local tr = ply:GetEyeTrace()
			if (tr.Hit == false) then return end
			if (tr.HitNonWorld == false) then return end

			local ent = tr.Entity
			if ent:IsPlayer() then
				local text = ent:Nick() or "ERROR"
				local ply_color = team_GetColor( (ent.Team == nil) and TEAM_UNASSIGNED or ent:Team() )

				surface_SetFont( font )
				local w, h = surface_GetTextSize( text )

				local MouseX, MouseY = gui_MousePos()
				if ( MouseX == 0 and MouseY == 0 ) then
					MouseX = ScrW() / 2
					MouseY = ScrH() / 2
				end

				local x = MouseX
				local y = MouseY

				x = x - w / 2
				y = y + 30

				-- The fonts internal drop shadow looks lousy with AA on
				draw_SimpleText( text, font, x + 1, y + 1, col1 )
				draw_SimpleText( text, font, x + 2, y + 2, col2 )
				draw_SimpleText( text, font, x, y, ply_color )

				y = y + h + 5

				local text = ent:Health() .. "%"
				local font = "TargetIDSmall"

				surface_SetFont( font )
				local w, h = surface_GetTextSize( text )
				local x = MouseX - w / 2

				draw_SimpleText( text, font, x + 1, y + 1, col1 )
				draw_SimpleText( text, font, x + 2, y + 2, col2 )
				draw_SimpleText( text, font, x, y, ply_color )
			end
		end)
	end)

end