if (GM.DisableStockUI == true) then
    return
end

-- Scoreboard
do

    g_Scoreboard = nil

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

    local ply = nil
    hook.Add("PlayerInitialized", "HUDDrawTargetID", function( pl ) ply = pl end)

    function GM:HUDDrawTargetID()
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
    end

end

-- Killicons
do
    local Deaths = {}

    local function AddDeathNotice(att, team1, infl, ply, team2)
        local Death = {}

        Death.time = CurTime()
        Death.left = att
        Death.right = ply
        Death.icon = infl

        if team1 ~= -1 then Death.color1 = table.Copy(team.GetColor(team1)) end
        if team2 ~= -1 then Death.color2 = table.Copy(team.GetColor(team2)) end

        if (Death.left == Death.right) then
            Death.left = nil
            Death.icon = "suicide"
        end

        table.insert(Deaths, Death)
    end

    local function PlayerKilled()
        local ply = net.ReadEntity()
        local _type = net.ReadInt(3)

        if _type == 1 then
            AddDeathNotice(nil, 0, "suicide", ply:Name(), ply:Team())
            return
        end

        local infl_class = net.ReadString()

        local att
        if _type == 2 then
            att = net.ReadEntity()
        else
            att = net.ReadString()
        end

        if isstring(att) then
            if IsValid(ply) then return end
            att	= "#" .. att
            AddDeathNotice(att, -1, infl_class, ply:Name(), ply:Team())
            return
        elseif IsValid(att) and IsValid(ply) then
            AddDeathNotice(att:Name(), att:Team(), infl_class, ply:Name(), ply:Team())
        end
    end
    net.Receive("PlayerKilled", PlayerKilled)

    local function DrawDeath(x, y, death, hud_deathnotice_time)
        local w, h = killicon.GetSize( death.icon )
        if not w then return end

        local fadeout = death.time + hud_deathnotice_time - CurTime()

        local alpha = math.Clamp(fadeout * 255, 0, 255)
        death.color1.a = alpha
        death.color2.a = alpha

        killicon.Draw(x, y, death.icon, alpha)

        if death.left then
            draw.SimpleText(death.left, "ChatFont", x - w * .5 - 16, y, death.color1, TEXT_ALIGN_RIGHT)
        end
        draw.SimpleText(death.right, "ChatFont", x + w *.5 + 16, y, death.color2, TEXT_ALIGN_LEFT)

        return y + h * .70
    end

    local hud_deathnotice_time = 6 --hud_deathnotice_time:GetFloat()

    function GM:DrawDeathNotice( x, y )
        x, y = x * ScrW(), y * ScrH()

        for _, Death in ipairs(Deaths) do
            if Death.time + hud_deathnotice_time > CurTime() then
                if Death.lerp then
                    x = x * .3 + Death.lerp.x * .7
                    y = y * .3 + Death.lerp.y * .7
                end
                Death.lerp = Death.lerp or {}
                Death.lerp.x = x
                Death.lerp.y = y
                y = DrawDeath(x, y, Death, hud_deathnotice_time)
            end
        end

        for _, Death in ipairs(Deaths) do
            if Death.time + hud_deathnotice_time > CurTime() then
                return
            end
        end

        Deaths = {}
    end

end

do

    GM.PickupHistory = {}
    GM.PickupHistoryLast = 0
    GM.PickupHistoryTop = ScrH() / 2
    GM.PickupHistoryWide = 300
    GM.PickupHistoryCorner = surface.GetTextureID( "gui/corner8" )

    local function AddGenericPickup( self, itemname )
        local pickup		= {}
        pickup.time			= CurTime()
        pickup.name			= itemname
        pickup.holdtime		= 5
        pickup.font			= "DermaDefaultBold"
        pickup.fadein		= 0.04
        pickup.fadeout		= 0.3

        surface.SetFont( pickup.font )
        local w, h = surface.GetTextSize( pickup.name )
        pickup.height		= h
        pickup.width		= w

        --[[if ( self.PickupHistoryLast >= pickup.time ) then
            pickup.time = self.PickupHistoryLast + 0.05
        end]]

        table.insert( self.PickupHistory, pickup )
        self.PickupHistoryLast = pickup.time

        return pickup
    end

    --[[---------------------------------------------------------
        Name: gamemode:HUDWeaponPickedUp( wep )
        Desc: The game wants you to draw on the HUD that a weapon has been picked up
    -----------------------------------------------------------]]
    function GM:HUDWeaponPickedUp( wep )

        if ( !IsValid( LocalPlayer() ) || !LocalPlayer():Alive() ) then return end
        if ( !IsValid( wep ) ) then return end
        if ( !isfunction( wep.GetPrintName ) ) then return end

        local pickup = AddGenericPickup( self, wep:GetPrintName() )
        pickup.color = Color( 255, 200, 50, 255 )

    end

    --[[---------------------------------------------------------
        Name: gamemode:HUDItemPickedUp( itemname )
        Desc: An item has been picked up..
    -----------------------------------------------------------]]
    function GM:HUDItemPickedUp( itemname )

        if ( !IsValid( LocalPlayer() ) || !LocalPlayer():Alive() ) then return end

        local pickup = AddGenericPickup( self, "#" .. itemname )
        pickup.color = Color( 180, 255, 180, 255 )

    end

    --[[---------------------------------------------------------
        Name: gamemode:HUDAmmoPickedUp( itemname, amount )
        Desc: Ammo has been picked up..
    -----------------------------------------------------------]]
    function GM:HUDAmmoPickedUp( itemname, amount )

        if ( !IsValid( LocalPlayer() ) || !LocalPlayer():Alive() ) then return end

        -- Try to tack it onto an exisiting ammo pickup
        if ( self.PickupHistory ) then

            for k, v in pairs( self.PickupHistory ) do

                if ( v.name == "#" .. itemname .. "_ammo" ) then

                    v.amount = tostring( tonumber( v.amount ) + amount )
                    v.time = CurTime() - v.fadein
                    return

                end

            end

        end

        local pickup = AddGenericPickup( self, "#" .. itemname .. "_ammo" )
        pickup.color = Color( 180, 200, 255, 255 )
        pickup.amount = tostring( amount )

        local w, h = surface.GetTextSize( pickup.amount )
        pickup.width = pickup.width + w + 16

    end

    function GM:HUDDrawPickupHistory()

        if ( self.PickupHistory == nil ) then return end

        local x, y = ScrW() - self.PickupHistoryWide - 20, self.PickupHistoryTop
        local tall = 0
        local wide = 0

        for k, v in pairs( self.PickupHistory ) do

            if ( !istable( v ) ) then

                Msg( tostring( v ) .. "\n" )
                PrintTable( self.PickupHistory )
                self.PickupHistory[ k ] = nil
                return
            end

            if ( v.time < CurTime() ) then

                if ( v.y == nil ) then v.y = y end

                v.y = ( v.y * 5 + y ) / 6

                local delta = ( v.time + v.holdtime ) - CurTime()
                delta = delta / v.holdtime

                local alpha = 255
                local colordelta = math.Clamp( delta, 0.6, 0.7 )

                -- Fade in/out
                if ( delta > 1 - v.fadein ) then
                    alpha = math.Clamp( ( 1.0 - delta ) * ( 255 / v.fadein ), 0, 255 )
                elseif ( delta < v.fadeout ) then
                    alpha = math.Clamp( delta * ( 255 / v.fadeout ), 0, 255 )
                end

                v.x = x + self.PickupHistoryWide - ( self.PickupHistoryWide * ( alpha / 255 ) )

                local rx, ry, rw, rh = math.Round( v.x - 4 ), math.Round( v.y - ( v.height / 2 ) - 4 ), math.Round( self.PickupHistoryWide + 9 ), math.Round( v.height + 8 )
                local bordersize = 8

                surface.SetTexture( self.PickupHistoryCorner )

                surface.SetDrawColor( v.color.r, v.color.g, v.color.b, alpha )
                surface.DrawTexturedRectRotated( rx + bordersize / 2, ry + bordersize / 2, bordersize, bordersize, 0 )
                surface.DrawTexturedRectRotated( rx + bordersize / 2, ry + rh -bordersize / 2, bordersize, bordersize, 90 )
                surface.DrawRect( rx, ry + bordersize, bordersize, rh-bordersize * 2 )
                surface.DrawRect( rx + bordersize, ry, v.height - 4, rh )

                surface.SetDrawColor( 230 * colordelta, 230 * colordelta, 230 * colordelta, alpha )
                surface.DrawTexturedRectRotated( rx + rw - bordersize / 2 , ry + rh - bordersize / 2, bordersize, bordersize, 180 )
                surface.DrawTexturedRectRotated( rx + rw - bordersize / 2 , ry + bordersize / 2, bordersize, bordersize, 270 )
                surface.DrawRect( rx + rw - bordersize, ry + bordersize, bordersize, rh-bordersize * 2 )
                surface.DrawRect( rx + bordersize + v.height - 4, ry, rw - ( v.height - 4 ) - bordersize * 2, rh )

                draw.SimpleText( v.name, v.font, v.x + v.height + 9, ry + ( rh / 2 ) + 1, Color( 0, 0, 0, alpha * 0.5 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                draw.SimpleText( v.name, v.font, v.x + v.height + 8, ry + ( rh / 2 ), Color( 255, 255, 255, alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

                if ( v.amount ) then

                    draw.SimpleText( v.amount, v.font, v.x + self.PickupHistoryWide + 1, ry + ( rh / 2 ) + 1, Color( 0, 0, 0, alpha * 0.5 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                    draw.SimpleText( v.amount, v.font, v.x + self.PickupHistoryWide, ry + ( rh / 2 ), Color( 255, 255, 255, alpha ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

                end

                y = y + ( v.height + 16 )
                tall = tall + v.height + 18
                wide = math.max( wide, v.width + v.height + 24 )

                if ( alpha == 0 ) then self.PickupHistory[ k ] = nil end

            end

        end

        self.PickupHistoryTop = ( self.PickupHistoryTop * 5 + ( ScrH() * 0.75 - tall ) / 2 ) / 6
        self.PickupHistoryWide = ( self.PickupHistoryWide * 5 + wide ) / 6

    end

end
