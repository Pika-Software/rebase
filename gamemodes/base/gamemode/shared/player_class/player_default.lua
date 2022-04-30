local PLAYER = {
    ["DisplayName"] = "Default Class",

    -- Boolean
    ["TeammateNoCollide"] = true,
    ["CanUseFlashlight"] = true,
    ["DropWeaponOnDie"] = false,
    ["AvoidPlayers"] = true,
    ["UseVMHands"] = true,

    ["RespawnTime"] = 2,

    -- Default Loadout
    ["DefaultLoadout"] = {
        {"weapon_pistol", 255}
    },

    -- Health & Armor
    ["StartHealth"] = 100,
    ["MaxHealth"] = 100,

    ["StartArmor"] = 0,
    ["MaxArmor"]  = 100,

    -- Movement Speed (Walk & Run & Sprint)
    ["SlowWalkSpeed"] = 200,
    ["WalkSpeed"] = 400,
    ["RunSpeed"] = 600,

    -- Jump Hight
    ["JumpPower"] = 200,

    -- Speed Multipliers
    ["CrouchedWalkSpeed"] = 0.3,
    ["UnDuckSpeed"] = 0.3,
    ["DuckSpeed"] = 0.3
}

function PLAYER:SetupDataTables()
end

function PLAYER:Init()
    self.Player.RespawnTime = 2
end

if (SERVER) then

    function PLAYER:Spawn()
    end

    do

        local game_GetAmmoName = game.GetAmmoName
        local IsValid = IsValid
        local ipairs = ipairs

        function PLAYER:Loadout()
            for num, data in ipairs( self.DefaultLoadout ) do
                local wep = self.Player:Give( data[1] )
                if IsValid( wep ) then
                    if (data[2] ~= nil) then
                        self.Player:GiveAmmo( data[2], game_GetAmmoName( wep:GetPrimaryAmmoType() ), true )
                    end

                    if (data[3] ~= nil) then
                        self.Player:GiveAmmo( data[3], game_GetAmmoName( wep:GetSecondaryAmmoType() ), true )
                    end
                end
            end
        end

    end

    do
        local player_manager_TranslatePlayerModel = player_manager.TranslatePlayerModel
        function PLAYER:SetModel()
            self.Player:SetModel( Model( player_manager_TranslatePlayerModel( self.Player:GetInfo( "cl_playermodel" ) ) ) )
        end
    end

    function PLAYER:Death( inflictor, attacker )
    end

else

    function PLAYER:CalcView( view )
    end

    function PLAYER:CreateMove( cmd )
    end

    function PLAYER:ShouldDrawLocal()
    end

end

-- Movement
function PLAYER:StartMove( cmd, mv )
end

function PLAYER:Move( mv )
end

function PLAYER:FinishMove( mv )
end

-- Viewmodel
function PLAYER:PreDrawViewModel( vm, wep )
end

function PLAYER:PostDrawViewModel( vm, wep )
end

-- Hands
do

    local player_manager_TranslatePlayerHands = player_manager.TranslatePlayerHands
    local player_manager_TranslateToPlayerModelName = player_manager.TranslateToPlayerModelName

    function PLAYER:GetHandsModel()
        return player_manager_TranslatePlayerHands( player_manager_TranslateToPlayerModelName( self.Player:GetModel() ) )
    end

end

player_manager.RegisterClass( "player_default", PLAYER )