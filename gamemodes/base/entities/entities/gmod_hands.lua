AddCSLuaFile()

ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_OTHER

-- Thanks CFC for this fix
-- https://github.com/CFC-Servers/gmod_hands_fix
function ENT:Initialize()
	self:SetNotSolid( true )
	self:DrawShadow( false )
	self:SetTransmitWithParent( true )

	if SERVER or (self:GetOwner() == LocalPlayer()) then
		hook.Add("OnViewModelChanged", self, self.ViewModelChanged)
	end
end

function ENT:OnRemove()
	if SERVER or (self:GetOwner() == LocalPlayer()) then
		hook.Remove( "OnViewModelChanged", self )
	end
end

function ENT:DoSetup(ply, spec)
	-- Set these hands to the player
	ply:SetHands(self)
	self:SetOwner(ply)

	-- Which hands should we use? Let the gamemode decide
	hook.Call("PlayerSetHandsModel", GAMEMODE, spec or ply, self)

	-- Attach them to the viewmodel
	local vm = (spec or ply):GetViewModel(0)
	self:AttachToViewmodel(vm)

	vm:DeleteOnRemove(self)
	ply:DeleteOnRemove(self)
end

function ENT:GetPlayerColor()
	local owner = self:GetOwner()
	if IsValid(owner) then
		if not owner["GetPlayerColor"] then return end

		return owner:GetPlayerColor()
	end
end

function ENT:ViewModelChanged(vm, old, new)
	if (vm:GetOwner() != self:GetOwner()) then return end
	self:AttachToViewmodel(vm)
end

function ENT:AttachToViewmodel(vm)
	self:AddEffects(EF_BONEMERGE)
	self:SetParent(vm)
	self:SetMoveType(MOVETYPE_NONE)

	self:SetPos(vector_origin)
	self:SetAngles(angle_zero)
end