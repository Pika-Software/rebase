AddCSLuaFile()

SWEP.ViewModel = Model( "models/weapons/c_arms_animations.mdl" )
SWEP.WorldModel = Model( "models/MaxOfS2D/camera.mdl" )

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.PrintName	= "#GMOD_Camera"

SWEP.Slot		= 5
SWEP.SlotPos	= 1

SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
SWEP.Spawnable		= true

SWEP.HoldType = "camera"

local CLIENT = CLIENT
local SERVER = SERVER
local IN_ATTACK2 = IN_ATTACK2

if (SERVER) then

	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

	concommand.Add("gmod_camera", function( ply, class )
		if ply:HasWeapon( class ) then
			ply:SelectWeapon( class )
		end
	end)

end

function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "Zoom" )
	self:NetworkVar( "Float", 1, "Roll" )

	if (SERVER) then
		self:SetZoom( 75 )
		self:SetRoll( 0 )
	end

end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:Reload()
	local ply = self:GetOwner()
	if IsValid( ply ) then
		if ply:KeyDown( IN_ATTACK2 ) then
			return
		end

		self:SetZoom( ply:IsBot() and 75 or ply:GetInfoNum( "fov_desired", 75 ) )
		self:SetRoll( 0 )
	end
end

function SWEP:PrimaryAttack()
	self:DoShootEffect()

	if (CLIENT) and IsFirstTimePredicted() then
		RunConsoleCommand( "jpeg" )
	end
end

function SWEP:SecondaryAttack()
end

do

	local math_Clamp = math.Clamp
	local FrameTime = FrameTime

	function SWEP:Tick()
		local ply = self:GetOwner()
		if IsValid( ply ) then
			if (CLIENT) and (ply:EntIndex() == LocalPlayer()) then
				local cmd = ply:GetCurrentCommand()
				if cmd:KeyDown( IN_ATTACK2 ) then
					self:SetZoom( math_Clamp( self:GetZoom() + cmd:GetMouseY() * FrameTime() * 6.6, 0.1, 175 ) )
					self:SetRoll( self:GetRoll() + cmd:GetMouseX() * FrameTime() * 1.65 )
				end
			end
		end
	end

end

function SWEP:TranslateFOV()
	return self:GetZoom()
end

function SWEP:Deploy()
	return true
end

function SWEP:Equip()
	local ply = self:GetOwner()
	if IsValid( ply ) then
		if ply:IsBot() then return end
		if (self:GetZoom() == 70) and ply:IsPlayer() then
			self:SetZoom( ply:GetInfoNum( "fov_desired", 75 ) )
		end
	end
end

function SWEP:ShouldDropOnDie()
	return false
end

do

	local PLAYER_ATTACK1 = PLAYER_ATTACK1
	local ACT_VM_PRIMARYATTACK = ACT_VM_PRIMARYATTACK

	SWEP.ShootSound = Sound( "NPC_CScanner.TakePhoto" )

	function SWEP:DoShootEffect()

		self:EmitSound( self.ShootSound )
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

		local ply = self:GetOwner()
		if IsValid( ply ) then
			ply:SetAnimation( PLAYER_ATTACK1 )

			if (SERVER) then

				local pos = ply:GetShootPos()
				local tr = util.TraceLine({
					start = pos,
					endpos = pos + ply:GetAimVector() * 256,
					filter = ply
				})

				local fx = EffectData()
				fx:SetOrigin( tr.HitPos )
				util.Effect( "camera_flash", fx, true )

			end

		end

	end

end

if (SERVER) then return end

SWEP.WepSelectIcon = surface.GetTextureID( "vgui/gmod_camera" )

-- Don't draw the weapon info on the weapon selection thing
function SWEP:DrawHUD() end
function SWEP:PrintWeaponInfo() end

SWEP.BlockedHUDS = {
	["CHudWeaponSelection"] = true,
	["CHudChat"] = true
}

function SWEP:HUDShouldDraw(name)
	if (self.BlockedHUDS[ name ] == true) then
		return true
	end

	return false
end

function SWEP:FreezeMovement()
	local ply = self:GetOwner()
	if IsValid( ply ) then
		if ply:KeyDown( IN_ATTACK2 ) then
			return true
		end

		if ply:KeyReleased( IN_ATTACK2 ) then
			return true
		end
	end

	return false
end

function SWEP:CalcView( ply, origin, angles, fov )
	if (self:GetRoll() ~= 0) then
		angles.Roll = self:GetRoll()
	end

	return origin, angles, fov
end

function SWEP:AdjustMouseSensitivity()
	local ply = self:GetOwner()
	if IsValid( ply ) then
		if ply:KeyDown( IN_ATTACK2 ) then
			return 1
		end
	end

	return self:GetZoom() / 80
end