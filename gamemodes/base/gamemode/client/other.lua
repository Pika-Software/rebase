-- PhysGun
function GM:DrawPhysgunBeam( ply, wep, bOn, target, boneid, pos )
	return true
end

-- Idk what is this
function GM:PostProcessPermitted( str )
	return false
end

-- Spawn Menu
function GM:OnSpawnMenuOpen()
end

function GM:OnSpawnMenuClose()
end

-- Context Menu
function GM:OnContextMenuOpen()
end

function GM:OnContextMenuClose()
end

do

	local hook_Run = hook.Run

	local hook_name1 = "OnSpawnMenuOpen"
	local hook_name2 = "OnSpawnMenuClose"

	local hook_name3 = "OnContextMenuOpen"
	local hook_name4 = "OnContextMenuClose"

	concommand.Add( "+menu", function()
		hook_Run( hook_name1 )
	end, nil, "Opens the spawnmenu", FCVAR_DONTRECORD )

	concommand.Add( "-menu", function()
		hook_Run( hook_name2 )
	end, nil, "Closes the spawnmenu", FCVAR_DONTRECORD )

	concommand.Add( "+menu_context", function()
		hook_Run( hook_name3 )
	end, nil, "Opens the context menu", FCVAR_DONTRECORD )

	concommand.Add( "-menu_context", function()
		hook_Run( hook_name4 )
	end, nil, "Closes the context menu", FCVAR_DONTRECORD )

end


timer.Simple(0, function()
	-- Sandbox trash
	spawnmenu.RemoveCreationTab( "#spawnmenu.category.postprocess" )

	-- Widgets Remove
	hook.Remove("PostDrawEffects", "RenderWidgets")
	hook.Remove("PlayerTick", "TickWidgets")

	-- demo_recording.lua
	hook.Remove("Initialize", "DemoRenderInit")
	hook.Remove("RenderScene", "RenderForDemo")

	-- gm_demo.lua
	hook.Remove("PopulateContent", "GameProps")
	hook.Remove("HUDPaint", "DrawRecordingIcon")
	concommand.Remove("gm_demo")

	-- Bloom
	hook.Remove("RenderScreenspaceEffects", "RenderBloom")
	list.Remove("PostProcess", "#bloom_pp")

	-- Bokeh DOF
	hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
	hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")

	-- Color Modify
	hook.Remove("RenderScreenspaceEffects", "RenderColorModify")
	list.Remove("PostProcess", "#colormod_pp")

	-- DOF
	hook.Remove("Think", "DOFThink")
	list.Remove("PostProcess", "#dof_pp")

	-- Blend
	hook.Remove("PostRender", "RenderFrameBlend")
	list.Remove("PostProcess", "#frame_blend_pp")

	-- Motion Blur
	hook.Remove("RenderScreenspaceEffects", "RenderMotionBlur")
	list.Remove("PostProcess", "#motion_blur_pp")

	-- Material Overlay
	hook.Remove("RenderScreenspaceEffects", "RenderMaterialOverlay")
	list.Remove("PostProcess", "#overlay_pp")
	list.Remove("OverlayMaterials")

	-- Sharpen
	hook.Remove("RenderScreenspaceEffects", "RenderSharpen")
	list.Remove("PostProcess", "#sharpen_pp")

	-- Sobel
	hook.Remove("RenderScreenspaceEffects", "RenderSobel")
	list.Remove("PostProcess", "#sobel_pp")

	-- Stereoscopy
	hook.Remove("RenderScene", "RenderStereoscopy")
	list.Remove("PostProcess", "#stereoscopy_pp")

	hook.Remove("RenderScreenspaceEffects", "RenderSunbeams")
	list.Remove("PostProcess", "#sunbeams_pp")

	-- Super DoF
	hook.Remove("RenderScene", "RenderSuperDoF")
	hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
	hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")
	hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
	concommand.Remove("pp_superdof")
	list.Remove("PostProcess", "#superdof_pp")

	-- Texturize
	hook.Remove("RenderScreenspaceEffects", "RenderTexturize")
	list.Remove("PostProcess", "#texturize_pp")
	list.Remove("TexturizeMaterials")

	-- ToyTown
	hook.Remove("RenderScreenspaceEffects", "RenderToyTown")
	list.Remove("PostProcess", "#toytown_pp")
end)