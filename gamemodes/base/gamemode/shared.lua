GM.Name = "Re-Base"
GM.Author = "Pika Software"
GM.Email = "github@pika-soft.ru"
GM.Website = "https://pika-soft.ru"

do

	local AddCSLuaFile = AddCSLuaFile
	local include = include
	local SERVER = SERVER

	local function includeFolder( folder )
		folder = folder .. "/"

		for _, fileName in ipairs( file.Find( folder .. "*", "LUA" ) ) do
			if SERVER then
				AddCSLuaFile( folder .. fileName )
			end

			include( folder .. fileName )
		end
	end

	includeFolder( "base/gamemode/shared/player_class" )
	includeFolder( "base/gamemode/shared" )

end

function GM:GetGameDescription()
	return self.Name
end

function GM:Tick()
end

function GM:Think()
end

function GM:PreGamemodeLoaded()
end

function GM:OnGamemodeLoaded()
end

function GM:PostGamemodeLoaded()
end

function GM:Initialize()
end

function GM:OnReloaded()
end

function GM:InitPostEntity()
end

function GM:ShutDown()
end

function GM:Restored()
end

function GM:Saved()
end