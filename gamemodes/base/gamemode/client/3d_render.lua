-- Scene
function GM:RenderScene(origin, angle, fov)
end

-- Player
function GM:PostPlayerDraw( ply )
end

function GM:PrePlayerDraw( ply )
end

do

	local player_manager_RunClass = player_manager.RunClass
	local class_name = "ShouldDrawLocal"

	function GM:ShouldDrawLocalPlayer( ply )
		return player_manager_RunClass( ply, class_name )
	end

end

-- PlayerInitialized
hook.Add("RenderScene", "GM:PlayerInitialized", function()
	hook.Remove("RenderScene", "GM:PlayerInitialized")
	hook.Run( "PlayerInitialized", LocalPlayer() )
end)

-- Render
function GM:PreRender()
	return false
end

function GM:PostRender()
end

-- Skybox
function GM:PreDrawSkyBox()
end

function GM:PostDrawSkyBox()
end

function GM:PostDraw2DSkyBox()
end

-- OpaqueRenderables
function GM:PreDrawOpaqueRenderables( bDrawingDepth, bDrawingSkybox )
end

function GM:PostDrawOpaqueRenderables( bDrawingDepth, bDrawingSkybox )
end

-- TranslucentRenderables
function GM:PreDrawTranslucentRenderables( bDrawingDepth, bDrawingSkybox )
end

function GM:PostDrawTranslucentRenderables( bDrawingDepth, bDrawingSkybox )
end

-- Monitors
function GM:DrawMonitors()
end

-- Effects
function GM:PreDrawEffects()
end

function GM:PostDrawEffects()
end

-- Halos
function GM:PreDrawHalos()
end