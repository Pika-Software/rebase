GM.Name = "Re-Base"
GM.Author = "Pika Software"
GM.Email = "prikolmen@pika-soft.ru"
GM.Website = "https://pika-soft.ru"
GM.Version = "1.3.5"

do

    local include = include
    local cl_files = {
      "shared/player_class/player_default.lua",
      "shared/player_class/taunt_camera.lua",
      "shared/animations.lua",
      "shared/player.lua",
      "shared/entity.lua",
      "shared/other.lua"
    }

    for num, path in ipairs( cl_files ) do
        include( path )
    end

end

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