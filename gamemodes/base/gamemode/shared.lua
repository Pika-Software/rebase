local include = include

GM.Name 	= "Re-Base"
GM.Author 	= "Pika Software"
GM.Email 	= "prikolmen@pika-soft.ru"
GM.Website 	= "https://pika-soft.ru"

--	//		Includes	//
include("shared/entity.lua")
include("shared/other.lua")
include("shared/player.lua")
include("shared/player_class/player_default.lua")

--	//		Source Engine		//
function GM:GetGameDescription()
	return self.Name
end

function GM:OnReloaded()
end

function GM:Restored()
end

function GM:Saved()
end

function GM:Tick()
end

--	//		Gamemode		//
function GM:PreGamemodeLoaded()
end

function GM:OnGamemodeLoaded()
end

function GM:PostGamemodeLoaded()
end

--	//			Tools			//
function net.ReceiveRemove( name )
	net.Receivers[ name:lower() ] = nil
end

do
	local list_GetForEdit = list.GetForEdit
	local ipairs = ipairs

	function list.Remove( name, key )
		local tbl = list_GetForEdit( name )
		if (key == nil) then
			for key, value in ipairs( tbl ) do
				tbl[ key ] = nil
			end
		else
			tbl[ key ] = nil
		end
	end
end