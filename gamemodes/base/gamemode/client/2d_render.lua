-- Overlay
function GM:DrawOverlay()
end

-- HUD
function GM:PreDrawHUD()
end

function GM:HUDPaintBackground()
end

do

	local hook_Call = hook.Call

	function GM:HUDPaint()
		hook_Call( "HUDDrawTargetID", self )
		hook_Call( "HUDDrawPickupHistory", self )
		hook_Call( "DrawDeathNotice", self, 0.85, 0.04 )
	end

end

function GM:PostDrawHUD()
end

-- HUDShouldDraw
do

	local LocalPlayer = LocalPlayer
	local IsValid = IsValid

	function GM:HUDShouldDraw( name )
		local ply = LocalPlayer()
		if not IsValid( ply ) then return true end

		local wep = ply:GetActiveWeapon()
		if not IsValid( wep ) then return true end
		if not wep.HUDShouldDraw then return true end

		return wep:HUDShouldDraw( name )
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