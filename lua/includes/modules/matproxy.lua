local pairs = pairs
local Msg = Msg

module( "matproxy" )

ActiveList = {}
ProxyList = {}

function ShouldOverrideProxy( name )
	return ProxyList[ name ] ~= nil
end

--
-- Called by the engine from OnBind
--
function Call( name, mat, ent )
	local proxy = ActiveList[ name ]
	if not proxy then return end
	if not proxy.bind then return end
	proxy:bind( mat, ent )
end

--
-- Called by the engine from OnBind
--
function Init( name, uname, mat, values )
	local proxy = ProxyList[ name ]
	if not proxy then return end

	local new_proxy = {}
	for key, value in pairs( proxy ) do
		new_proxy[ key ] = value
	end

	ActiveList[ uname ] = new_proxy

	if not new_proxy.init then return end
	new_proxy:init( mat, values )

	-- Store these incase we reload
	new_proxy.Values = values
	new_proxy.Material = mat
end

function Add( tbl )
	if not tbl.bind then return end

	local name = tbl.name
	if not name then return end

	local isReload = ProxyList[ name ] == nil
	ProxyList[ name ] = tbl

	--
	-- If we're reloading then reload all the active entries that use this proxy
	--
	if isReload then return end

	for key, value in pairs( ActiveList ) do
		if name ~= value.name then continue end
		Msg( "Reloading: ", value.Material, "\n" )
		Init( name, key, value.Material, value.Values )
	end
end