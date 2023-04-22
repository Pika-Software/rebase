local surface = surface
local table = table
local team = team
local draw = draw
local math = math
local vgui = vgui

local ScrW, ScrH = ScrW, ScrH
local IsValid = IsValid
local CurTime = CurTime
local ipairs = ipairs
local Color = Color
local pairs = pairs
local type = type

-- Scoreboard
do

    if IsValid( g_Scoreboard ) then
        g_Scoreboard:Remove()
        g_Scoreboard = nil
    end

    surface.CreateFont( "ScoreboardDefault", {
        ["font"] = "Helvetica",
        ["weight"] = 800,
        ["size"] = 22
    })

    surface.CreateFont( "ScoreboardDefaultTitle", {
        ["font"] = "Helvetica",
        ["weight"] = 800,
        ["size"] = 32
    } )

    local PLAYER = {}

    do

        local TEAM_CONNECTING = TEAM_CONNECTING
        local color1 = Color( 93, 93, 93 )

        function PLAYER:Init()
            local avatarButton = self:Add( "DButton" )
            self.AvatarButton = avatarButton

            avatarButton:Dock( LEFT )
            avatarButton:SetSize( 32, 32 )
            avatarButton.DoClick = function( pnl )
                self.Player:ShowProfile()
            end

            local avatar = vgui.Create( "AvatarImage", avatarButton )
            self.Avatar = avatar

            avatar:SetSize( 32, 32 )
            avatar:SetMouseInputEnabled( false )

            local name = self:Add( "DLabel" )
            self.Name = name

            name:Dock( FILL )
            name:SetFont( "ScoreboardDefault" )
            name:SetTextColor( color1 )
            name:DockMargin( 8, 0, 0, 0 )

            local mute = self:Add( "DImageButton" )
            self.Mute = mute

            mute:SetSize( 32, 32 )
            mute:Dock( RIGHT )

            local ping = self:Add( "DLabel" )
            self.Ping = ping

            mute:Dock( RIGHT )
            mute:SetWidth( 50 )
            mute:SetFont( "ScoreboardDefault" )
            mute:SetTextColor( color1 )
            mute:SetContentAlignment( 5 )

            local deaths = self:Add( "DLabel" )
            self.Deaths = deaths

            deaths:Dock( RIGHT )
            deaths:SetWidth( 50 )
            deaths:SetFont( "ScoreboardDefault" )
            deaths:SetTextColor( color1 )
            deaths:SetContentAlignment( 5 )

            local kills = self:Add( "DLabel" )
            self.Kills = kills

            kills:Dock( RIGHT )
            kills:SetWidth( 50 )
            kills:SetFont( "ScoreboardDefault" )
            kills:SetTextColor( color1 )
            kills:SetContentAlignment( 5 )

            self:Dock( TOP )
            self:DockPadding( 3, 3, 3, 3 )
            self:SetHeight( 32 + 3 * 2 )
            self:DockMargin( 2, 0, 2, 2 )
        end

        function PLAYER:Update()
            local ply = self.Player
            if not IsValid( ply ) then
                self:SetZPos( 9999 ) -- Causes a rebuild
                self:Remove()
                return
            end

            self.Avatar:SetPlayer( ply )

            if not self.PName or self.PName ~= ply:Nick() then
                self.PName = ply:Nick()
                self.Name:SetText( self.PName )
            end

            if not self.NumKills or self.NumKills ~= ply:Frags() then
                self.NumKills = ply:Frags()
                self.Kills:SetText( self.NumKills )
            end

            if not self.NumDeaths or self.NumDeaths ~= ply:Deaths() then
                self.NumDeaths = ply:Deaths()
                self.Deaths:SetText( self.NumDeaths )
            end

            if not self.NumPing or self.NumPing ~= ply:Ping() then
                self.NumPing = ply:Ping()
                self.Ping:SetText( self.NumPing )
            end

            --
            -- Change the icon of the mute button based on state
            --
            if not self.Muted or self.Muted ~= ply:IsMuted() then

                self.Muted = ply:IsMuted()
                if self.Muted then
                    self.Mute:SetImage( "icon32/muted.png" )
                else
                    self.Mute:SetImage( "icon32/unmuted.png" )
                end

                self.Mute.DoClick = function( pnl )
                    ply:SetMuted( not self.Muted )
                end

                self.Mute.OnMouseWheeled = function( pnl, delta )
                    ply:SetVoiceVolumeScale( ply:GetVoiceVolumeScale() + ( delta / 100 * 5 ) )
                    pnl.LastTick = CurTime()
                end

                self.Mute.PaintOver = function( pnl, w, h )
                    if not IsValid( ply ) then return end

                    local a = 255 - math.Clamp( CurTime() - ( pnl.LastTick or 0 ), 0, 3 ) * 255
                    if a <= 0 then return end

                    draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, a * 0.75 ) )
                    draw.SimpleText( math.ceil( ply:GetVoiceVolumeScale() * 100 ) .. "%", "DermaDefaultBold", w / 2, h / 2, Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end

            end

            --
            -- Connecting players go at the very bottom
            --
            if ply:Team() == TEAM_CONNECTING then
                self:SetZPos( 2000 + ply:EntIndex() )
                return
            end

            --
            -- This is what sorts the list. The panels are docked in the z order,
            -- so if we set the z order according to kills they'll be ordered that way!
            -- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
            --
            self:SetZPos( ( self.NumKills * -50 ) + self.NumDeaths + ply:EntIndex() )
        end

        local color2 = Color( 200, 200, 200, 200 )
        local color3 = Color( 230, 200, 200, 255 )
        local color4 = Color( 230, 255, 230, 255 )
        local color5 = Color( 230, 230, 230, 255 )

        function PLAYER:Paint( w, h )
            local ply = self.Player
            if not IsValid( ply ) then return end

            --
            -- We draw our background a different colour based on the status of the player
            --
            if ply:Team() == TEAM_CONNECTING then
                draw.RoundedBox( 4, 0, 0, w, h, color2 )
                return
            end

            if not ply:Alive() then
                draw.RoundedBox( 4, 0, 0, w, h, color3 )
                return
            end

            if ply:IsAdmin() then
                draw.RoundedBox( 4, 0, 0, w, h, color4 )
                return
            end

            draw.RoundedBox( 4, 0, 0, w, h, color5 )
        end

        PLAYER = vgui.RegisterTable( PLAYER, "DPanel" )

    end

    do

        local SCORE_BOARD = {}

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
        end

        local game_MaxPlayers = game.MaxPlayers
        local player_GetAll = player.GetAll
        local GetHostName = GetHostName

        function SCORE_BOARD:Update()
            self.Name:SetText( GetHostName() )

            for _, pnl in ipairs( self.Scores:GetCanvas():GetChildren() ) do
                pnl:Update()
            end

            local players = player_GetAll()
            self.NumPlayers:SetText( #players .. " / " .. game_MaxPlayers() )

            for _, ply in ipairs( players ) do
                local hasPanel = false
                for __, pnl in ipairs( self.Scores:GetCanvas():GetChildren() ) do
                    if IsValid( pnl.Player ) and pnl.Player:EntIndex() == ply:EntIndex() then
                        hasPanel = true
                        break
                    end
                end

                if hasPanel then continue end

                local pnl = vgui.CreateFromTable( PLAYER )
                pnl.Player = ply
                pnl:Update()

                self.Scores:AddItem( pnl )
            end
        end

        SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" )

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
            if not IsValid( g_Scoreboard ) then return end
            g_Scoreboard:Hide()
        end

        function GM:HUDDrawScoreBoard()
        end

    end

end

-- Voice
do

    local PANEL = {}
    local PlayerVoicePanels = {}

    function PANEL:Init()
        local labelName = vgui.Create( "DLabel", self )
        self.LabelName = labelName

        labelName:SetFont( "GModNotify" )
        labelName:Dock( FILL )
        labelName:DockMargin( 8, 0, 0, 0 )
        labelName:SetTextColor( color_white )

        local avatar = vgui.Create( "AvatarImage", self )
        self.Avatar = avatar

        avatar:Dock( LEFT )
        avatar:SetSize( 32, 32 )

        self.Color = color_transparent

        self:SetSize( 250, 32 + 8 )
        self:DockPadding( 4, 4, 4, 4 )
        self:DockMargin( 2, 2, 2, 2 )
        self:Dock( BOTTOM )
    end

    function PANEL:Setup( ply )
        self.Color = team.GetColor( ply:Team() )
        self.Player = ply

        self.LabelName:SetText( ply:Nick() )
        self.Avatar:SetPlayer( ply )

        self:InvalidateLayout()
    end

    function PANEL:Paint( w, h )
        if not IsValid( self.Player ) then return end
        draw.RoundedBox( 4, 0, 0, w, h, Color( 0, self.Player:VoiceVolume() * 255, 0, 240 ) )
    end

    function PANEL:Think()
        local ply = self.Player
        if IsValid( ply ) then
            self.LabelName:SetText( ply:Nick() )
        end

        if self.fadeAnim then
            self.fadeAnim:Run()
        end
    end

    function PANEL:FadeOut( anim, delta, data )
        if anim.Finished then
            local pnl = PlayerVoicePanels[ self.Player ]
            if IsValid( pnl ) then
                pnl:Remove()
            end

            PlayerVoicePanels[ self.Player ] = nil
            return
        end

        self:SetAlpha( 255 - ( 255 * delta ) )
    end

    derma.DefineControl( "VoiceNotify", "", PANEL, "DPanel" )

    function GM:PlayerStartVoice( ply )
        if not IsValid( g_VoicePanelList ) then return end

        -- There'd be an exta one if voice_loopback is on, so remove it.
        GAMEMODE:PlayerEndVoice( ply )

        local pnl = PlayerVoicePanels[ ply ]
        if IsValid( pnl ) then
            if pnl.fadeAnim then
                pnl.fadeAnim:Stop()
                pnl.fadeAnim = nil
            end

            pnl:SetAlpha( 255 )
            return
        end

        if not IsValid( ply ) then return end

        pnl = g_VoicePanelList:Add( "VoiceNotify" )
        pnl:Setup( ply )

        PlayerVoicePanels[ ply ] = pnl
    end

    timer.Create( "VoiceClean", 10, 0, function()
        for ply in pairs( PlayerVoicePanels ) do
            if IsValid( ply ) then continue end
            GAMEMODE:PlayerEndVoice( ply )
        end
    end )

    function GM:PlayerEndVoice( ply )
        local pnl = PlayerVoicePanels[ ply ]
        if IsValid( pnl ) then
            if pnl.fadeAnim then return end
            pnl.fadeAnim = Derma_Anim( "FadeOut", pnl, pnl.FadeOut )
            pnl.fadeAnim:Start( 2 )
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
    local gui_MousePos = gui.MousePos
    local font = "TargetID"

    local col1 = Color( 0, 0, 0, 120 )
    local col2 = Color( 0, 0, 0, 50 )

    function GM:HUDDrawTargetID()
        local eyePos = EyePos()
        local tr = util.TraceLine( {
            ["start"] = eyePos,
            ["endPos"] = eyePos + ( EyeAngles():Forward() * 32768 ),
            ["filter"] = LocalPlayer()
        } )

        if not tr.Hit then return end
        if not tr.HitNonWorld then return end

        local ent = tr.Entity
        if ent:IsPlayer() then
            local text = ent:Nick() or "ERROR"
            local ply_color = team.GetColor( (ent.Team == nil) and TEAM_UNASSIGNED or ent:Team() )

            surface.SetFont( font )
            local w, h = surface.GetTextSize( text )

            local mouseX, mouseY = gui_MousePos()
            if mouseX == 0 and mouseY == 0 then
                mouseX = ScrW() / 2
                mouseY = ScrH() / 2
            end

            local x = mouseX
            local y = mouseY

            x = x - w / 2
            y = y + 30

            -- The fonts internal drop shadow looks lousy with AA on
            draw.SimpleText( text, font, x + 1, y + 1, col1 )
            draw.SimpleText( text, font, x + 2, y + 2, col2 )
            draw.SimpleText( text, font, x, y, ply_color )

            y = y + h + 5

            local text = ent:Health() .. "%"
            local font = "TargetIDSmall"

            surface.SetFont( font )
            local x = mouseX - surface.GetTextSize( text ) / 2

            draw.SimpleText( text, font, x + 1, y + 1, col1 )
            draw.SimpleText( text, font, x + 2, y + 2, col2 )
            draw.SimpleText( text, font, x, y, ply_color )
        end
    end

end

-- Killicons
do

    local deaths = {}

    local function addDeathNotice(att, team1, infl, ply, team2)
        local death = {}

        death.time = CurTime()
        death.left = att
        death.right = ply
        death.icon = infl

        if team1 ~= -1 then death.color1 = table.Copy( team.GetColor( team1 ) ) end
        if team2 ~= -1 then death.color2 = table.Copy( team.GetColor( team2 ) ) end

        if death.left == death.right then
            death.left = nil
            death.icon = "suicide"
        end

        deaths[ #deaths + 1 ] = death
    end

    local net = net

    net.Receive( "PlayerKilled", function()
        local ply = net.ReadEntity()
        local deathType = net.ReadInt( 3 )

        if deathType == 1 then
            addDeathNotice(nil, 0, "suicide", ply:Name(), ply:Team())
            return
        end

        local infl_class = net.ReadString()

        local att
        if deathType == 2 then
            att = net.ReadEntity()
        else
            att = net.ReadString()
        end

        if type( att ) == "string" then
            if IsValid( ply ) then return end
            addDeathNotice( "#" .. att, -1, infl_class, ply:Name(), ply:Team() )
            return
        elseif IsValid( att ) and IsValid( ply ) then
            addDeathNotice( att:Name(), att:Team(), infl_class, ply:Name(), ply:Team() )
        end
    end )

    local function DrawDeath( x, y, death, deathTime )
        local w, h = killicon.GetSize( death.icon )
        if not w or not h then return end

        local alpha = math.Clamp( ( death.time + deathTime - CurTime() ) * 255, 0, 255 )
        death.color1.a = alpha
        death.color2.a = alpha

        killicon.Draw( x, y, death.icon, alpha )

        if death.left then
            draw.SimpleText( death.left, "ChatFont", x - w * 0.5 - 16, y, death.color1, TEXT_ALIGN_RIGHT )
        end

        draw.SimpleText( death.right, "ChatFont", x + w * 0.5 + 16, y, death.color2, TEXT_ALIGN_LEFT )

        return y + h * 0.7
    end

    local hud_deathnotice_time = CreateConVar( "hud_deathnotice_time", "6", FCVAR_REPLICATED, "Amount of time to show death notice" )
    local cl_drawhud = GetConVar( "cl_drawhud" )

    function GM:DrawDeathNotice( x, y )
        if not cl_drawhud:GetBool() then return end
        x, y = x * ScrW(), y * ScrH()

        local deathTime = hud_deathnotice_time:GetFloat()
        for _, death in ipairs( deaths ) do
            if death.time + deathTime > CurTime() then
                if death.lerp then
                    x = x * 0.3 + death.lerp.x * 0.7
                    y = y * 0.3 + death.lerp.y * 0.7
                end

                death.lerp = death.lerp or {}
                death.lerp.x = x
                death.lerp.y = y

                y = DrawDeath( x, y, death, deathTime )
            end
        end

        for _, death in ipairs( deaths ) do
            if death.time + deathTime > CurTime() then return end
        end

        for key in pairs( deaths ) do
            deaths[ key ] = nil
        end
    end

end

do

    GM.PickupHistory = {}
    GM.PickupHistoryLast = 0
    GM.PickupHistoryTop = ScrH() / 2
    GM.PickupHistoryWide = 300
    GM.PickupHistoryCorner = surface.GetTextureID( "gui/corner8" )

    local function addGenericPickup( self, itemname )
        local pickup = {
            ["font"] = "DermaDefaultBold",
            ["time"] = CurTime(),
            ["name"] = itemname,
            ["fadein"] = 0.04,
            ["fadeout"] = 0.3,
            ["holdtime"] = 5
        }

        surface.SetFont( pickup.font )
        pickup.width, pickup.height = surface.GetTextSize( pickup.name )

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
        if not IsValid( wep ) then return end
        if type( wep.GetPrintName ) ~= "function" then return end
        local pickup = addGenericPickup( self, wep:GetPrintName() )
        pickup.color = Color( 255, 200, 50, 255 )
    end

    --[[---------------------------------------------------------
        Name: gamemode:HUDItemPickedUp( itemname )
        Desc: An item has been picked up..
    -----------------------------------------------------------]]
    function GM:HUDItemPickedUp( itemname )
        local pickup = addGenericPickup( self, "#" .. itemname )
        pickup.color = Color( 180, 255, 180, 255 )
    end

    --[[---------------------------------------------------------
        Name: gamemode:HUDAmmoPickedUp( itemname, amount )
        Desc: Ammo has been picked up..
    -----------------------------------------------------------]]
    function GM:HUDAmmoPickedUp( itemname, amount )
        -- Try to tack it onto an exisiting ammo pickup
        for k, v in pairs( self.PickupHistory ) do
            if ( v.name == "#" .. itemname .. "_ammo" ) then
                v.amount = tostring( tonumber( v.amount ) + amount )
                v.time = CurTime() - v.fadein
                return
            end
        end

        local pickup = addGenericPickup( self, "#" .. itemname .. "_ammo" )
        pickup.color = Color( 180, 200, 255, 255 )
        pickup.amount = tostring( amount )

        pickup.width = pickup.width + surface.GetTextSize( pickup.amount ) + 16
    end

    function GM:HUDDrawPickupHistory()
        local ply = LocalPlayer()
        if not IsValid( ply ) or not ply:Alive() then return end

        local x, y = ScrW() - self.PickupHistoryWide - 20, self.PickupHistoryTop
        local tall = 0
        local wide = 0

        for k, v in pairs( self.PickupHistory ) do
            if type( v ) ~= "table" then
                Msg( tostring( v ) .. "\n" )
                PrintTable( self.PickupHistory )
                self.PickupHistory[ k ] = nil
                return
            end

            if v.time < CurTime() then
                if not v.y then v.y = y end
                v.y = ( v.y * 5 + y ) / 6

                local delta = ( v.time + v.holdtime ) - CurTime()
                delta = delta / v.holdtime

                local alpha = 255
                local colordelta = math.Clamp( delta, 0.6, 0.7 )

                -- Fade in/out
                if delta > 1 - v.fadein then
                    alpha = math.Clamp( ( 1.0 - delta ) * ( 255 / v.fadein ), 0, 255 )
                elseif delta < v.fadeout then
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

                if v.amount then
                    draw.SimpleText( v.amount, v.font, v.x + self.PickupHistoryWide + 1, ry + ( rh / 2 ) + 1, Color( 0, 0, 0, alpha * 0.5 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                    draw.SimpleText( v.amount, v.font, v.x + self.PickupHistoryWide, ry + ( rh / 2 ), Color( 255, 255, 255, alpha ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                end

                y = y + ( v.height + 16 )
                tall = tall + v.height + 18
                wide = math.max( wide, v.width + v.height + 24 )

                if alpha == 0 then self.PickupHistory[ k ] = nil end
            end

        end

        self.PickupHistoryTop = ( self.PickupHistoryTop * 5 + ( ScrH() * 0.75 - tall ) / 2 ) / 6
        self.PickupHistoryWide = ( self.PickupHistoryWide * 5 + wide ) / 6

    end

end