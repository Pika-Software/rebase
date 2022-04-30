-- Overlay
function GM:DrawOverlay()
end

-- HUD
function GM:PreDrawHUD()
end

function GM:HUDPaintBackground()
end

function GM:HUDPaint()
end

function GM:PostDrawHUD()
end

-- HUDShouldDraw
do

	local player = nil
	hook.Add("PlayerInitialized", "HUDShouldDraw", function( ply )
		player = ply
	end)

	local IsValid = IsValid
	function GM:HUDShouldDraw( name )
		if (player == nil) then return true end

		local wep = player:GetActiveWeapon()
		if IsValid( wep ) then
			if (wep.HUDShouldDraw == nil) then return true end
			return wep:HUDShouldDraw( name )
		end

		return true
	end

end

-- Pickup HUD
function GM:HUDWeaponPickedUp( wep )
end

function GM:HUDItemPickedUp( itemname )
end

function GM:HUDAmmoPickedUp( itemname, amount )
end

function GM:HUDDrawPickupHistory()
end

-- Death Notice
function GM:AddDeathNotice( att, team1, infl, ply, team2 )
end

function GM:DrawDeathNotice( x, y )
end

-- Scoreboard
function GM:ScoreboardShow()
end

function GM:ScoreboardHide()
end

function GM:HUDDrawScoreBoard()
end

-- Screen Effects
function GM:RenderScreenspaceEffects()
end

-- VGUI
function GM:PostRenderVGUI()
end

-- Blur
function GM:GetMotionBlurValues( x, y, fwd, spin )
	return x, y, fwd, spin
end