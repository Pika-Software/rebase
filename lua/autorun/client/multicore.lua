local RunConsoleCommand = RunConsoleCommand

local function setMulticore( bool )
	RunConsoleCommand( "mat_queue_mode", -1 )
	RunConsoleCommand( "gmod_mcore_test", bool and 1 or 0 )
	RunConsoleCommand( "cl_threaded_bone_setup", bool and 1 or 0 )
end

setMulticore( CreateClientConVar( "cl_multicore", "1", true, true, "Enables/disables multi-core game processing.", 0, 1 ):GetBool() )
cvars.AddChangeCallback( "cl_multicore", function( _, __, value ) setMulticore( value == "1" ) end, "GMod" )