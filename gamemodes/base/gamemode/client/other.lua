-- PhysGun
function GM:DrawPhysgunBeam( ply, wep, bOn, target, boneid, pos )
	return true
end

-- Idk what is this
function GM:PostProcessPermitted( str )
	return false
end

timer.Simple(0, function()
	-- Sandbox trash
	hook.Remove("PostReloadToolsMenu", "BuildCleanupUI")
	hook.Remove("PopulateMenuBar", "DisplayOptions_MenuBar")
	hook.Remove("PopulateMenuBar", "NPCOptions_MenuBar")
	hook.Remove("PopulateToolMenu", "PopulateUtilityMenus")
	hook.Remove("AddToolMenuCategories", "CreateUtilitiesCategories")
	hook.Remove("OnGamemodeLoaded", "CreateMenuBar")

	-- Widgets Remove
	hook.Remove("PostDrawEffects", "RenderWidgets")
	hook.Remove("PlayerTick", "TickWidgets")

	-- Remove Spawnmenu Binds
	concommand.Remove("+menu")
	concommand.Remove("-menu")

	concommand.Remove("+menu_context")
	concommand.Remove("-menu_context")

	-- Remove Halos
	hook.Remove("PostDrawEffects", "RenderHalos")

	-- demo_recording.lua
	hook.Remove("Initialize", "DemoRenderInit")
	hook.Remove("RenderScene", "RenderForDemo")

	-- gm_demo.lua
	hook.Remove("PopulateContent", "GameProps")
	hook.Remove("HUDPaint", "DrawRecordingIcon")

	concommand.Remove("gm_demo")

	-- gui/icon_progress.lua
	hook.Remove("SpawniconGenerated", "SpawniconGenerated")

	-- modules/properties.lua
	properties.List = {}
	hook.Remove("PreDrawHalos", "PropertiesHover")
	hook.Remove("GUIMousePressed", "PropertiesClick")
	hook.Remove("PreventScreenClicks", "PropertiesPreventClicks")

	-- modules/undo.lua
	net.ReceiveRemove("Undo_Undone")
	net.ReceiveRemove("Undo_AddUndo")
	net.ReceiveRemove("Undo_FireUndo")

	hook.Remove("PostReloadToolsMenu", "BuildUndoUI")

	concommand.Remove("undo")
	concommand.Remove("gmod_undo")
	concommand.Remove("gmod_undonum")

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