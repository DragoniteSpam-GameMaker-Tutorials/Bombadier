/// @param message
/// @param longMessage
function cluck_exception() {
    var ax = 0;
    var exception_message = argument[ax++];
    var exception_longMessage = argument[ax++];
	// Credit: Nuxii @Kat3Nuxii
	// https://gist.github.com/NuxiiGit/1ed55debd0c0c7be02a78a0c464b50ee
	var script_stack = debug_get_callstack();
	var script_count = array_length(script_stack);
	var script_top = script_stack[0];
	var script_name = string_replace(string_copy(script_top, 1, string_pos(":",script_top) - 1), "gml_Script_", "");
    script_name = string_replace(script_name, "gml_Object_", "");
    script_name = string_replace(script_name, "gml_Room_", "");
    // why would you do this
    script_name = string_replace(script_name, "gml_Timeline_", "");
    return {
        message: exception_message,
        longMessage: exception_longMessage,
        stacktrace: script_stack,
        script: script_name,
    };
}