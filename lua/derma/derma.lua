local vgui_GetControlTable = vgui.GetControlTable
local debug_getregistry = debug.getregistry
local vgui_Register = vgui.Register
local gamemode_Call = gamemode.Call
local setmetatable = setmetatable
local table_insert = table.insert
local table_Copy = table.Copy
local isfunction = isfunction
local ispanel = ispanel
local ipairs = ipairs
local pairs = pairs
local Msg = Msg
local _G = _G

module( "derma" )

Controls = {}
SkinList = {}

local DefaultSkin = {}
local SkinMetaTable = {}
local iSkinChangeIndex = 1

SkinMetaTable.__index = function( self, key )
	return DefaultSkin[ key ]
end

local function FindPanelsByClass( SeekingClass )
	local outtbl = {}

	local tbl = debug_getregistry()
	for class, pnl in pairs( tbl ) do
		if ispanel( pnl ) then
			if (v.ClassName == nil) then continue end
			if (v.ClassName == SeekingClass) then
				table_insert( outtbl, v )
			end
		end
	end

	return outtbl
end

--
-- Find all the panels that use this class and
-- if allowed replace the functions with the new ones.
--
local function ReloadClass( classname )
	local ctrl = vgui_GetControlTable( classname )
	if (ctrl == nil) then return end

	local tbl = FindPanelsByClass( classname )
	for k, v in ipairs( tbl ) do
		if not v.AllowAutoRefresh then continue end

		if (v.PreAutoRefresh ~= nil) then
			v:PreAutoRefresh()
		end

		for name, func in pairs( ctrl ) do
			if not isfunction( func ) then continue end
			v[ name ] = func
		end

		if (v.PostAutoRefresh ~= nil) then
			v:PostAutoRefresh()
		end
	end
end

--[[---------------------------------------------------------
	GetControlList
-----------------------------------------------------------]]
function GetControlList()
	return Controls
end

--[[---------------------------------------------------------
	DefineControl
-----------------------------------------------------------]]
function DefineControl( strName, strDescription, strTable, strBase )
	local bReloading = Controls[ strName ] ~= nil

	strTable.Derma = {
		["ClassName"]	= strName,
		["Description"]	= strDescription,
		["BaseClass"]	= strBase
	}

	-- Register control with VGUI
	vgui_Register( strName, strTable, strBase )

	-- Store control
	Controls[ strName ] = strTable.Derma

	-- Store as a global so controls can 'baseclass' easier
	-- TODO: STOP THIS
	_G[ strName ] = strTable

	if (bReloading == true) then
		Msg( "Reloaded Control: ", strName, "\n" )
		ReloadClass( strName )
	end

	return strTable
end

--[[---------------------------------------------------------
	DefineSkin
-----------------------------------------------------------]]
do
	local default_base = "Default"
	function DefineSkin( strName, strDescription, strTable )
		strTable.Name = strName
		strTable.Description = strDescription
		strTable.Base = strBase or default_base

		if (strName ~= default_base) then
			setmetatable( strTable, SkinMetaTable )
		else
			DefaultSkin = strTable
		end

		SkinList[ strName ] = strTable

		-- Make all panels update their skin
		RefreshSkins()
	end
end

--[[---------------------------------------------------------
	GetSkin - Returns current skin for panel
-----------------------------------------------------------]]
function GetSkinTable()
	return table_Copy( SkinList )
end

--[[---------------------------------------------------------
	Returns 'Named' Skin
-----------------------------------------------------------]]
function GetNamedSkin( name )
	return SkinList[ name ]
end

--[[---------------------------------------------------------
	Returns 'Default' Skin
-----------------------------------------------------------]]
do
	local call_name = "ForceDermaSkin"
	function GetDefaultSkin()
		local skinname = gamemode_Call( call_name )
		if (skinname == nil) then
			return DefaultSkin
		end

		local skin = GetNamedSkin( skinname )
		if (skin == nil) then
			return DefaultSkin
		end

		return skin
	end
end

--[[---------------------------------------------------------
	SkinHook( strType, strName, panel )
-----------------------------------------------------------]]
function SkinHook( strType, strName, panel, w, h )
	local Skin = panel:GetSkin()
	if (Skin == nil) then
		return
	end

	local func = Skin[ strType .. strName ]
	if (func == nil) then
		return
	end

	return func( Skin, panel, w, h )
end

--[[---------------------------------------------------------
	SkinTexture( strName, panel, default )
-----------------------------------------------------------]]
function SkinTexture( strName, panel, default )
	local Skin = panel:GetSkin()
	if (Skin == nil) then
		return default
	end

	local Textures = Skin.tex
	if (Textures == nil) then
		return default
	end

	return Textures[ strName ] or default
end

--[[---------------------------------------------------------
	Color( strName, panel, default )
-----------------------------------------------------------]]
function Color( strName, panel, default )
	local Skin = panel:GetSkin()
	if (Skin == nil) then
		return default
	end

	return Skin[ strName ] or default
end

--[[---------------------------------------------------------
	SkinChangeIndex
-----------------------------------------------------------]]
function SkinChangeIndex()
	return iSkinChangeIndex
end

--[[---------------------------------------------------------
	RefreshSkins - clears all cache'd panels (so they will reassess which skin they should be using)
-----------------------------------------------------------]]
function RefreshSkins()
	iSkinChangeIndex = iSkinChangeIndex + 1
end
