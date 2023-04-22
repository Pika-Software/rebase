GM.Name = "Re-Base"
GM.Author = "Pika Software"
GM.Email = "github@pika-soft.ru"
GM.Website = "https://pika-soft.ru"

do

	local include = include
	local shared = {
		"shared/player_class/player_default.lua",
		"shared/player_class/taunt_camera.lua",
		"shared/animations.lua",
		"shared/player.lua",
		"shared/entity.lua",
		"shared/other.lua"
	}

	for _, path in ipairs( shared ) do
		include( path )
	end

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