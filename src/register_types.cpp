#include "register_types.hpp"

#include "gdexample.hpp"

#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/godot.hpp>

//#include <godot_cpp/classes/engine.hpp>
//#include <godot_cpp/classes/editor_plugin.hpp>

using namespace godot;

void initialize_gonzago_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

	// https://github.com/BOTLANNER/godot-gif/blob/main/src/editor/import_gif_to_animated_texture.h
	// https://github.com/BOTLANNER/godot-gif/blob/main/src/register_types.cpp

	ClassDB::register_class<GDExample>();
}

void uninitialize_gonzago_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
}

extern "C" {
// Initialization.
GDExtensionBool GDE_EXPORT gonzago_library_init(
    GDExtensionInterfaceGetProcAddress p_get_proc_address,
    const GDExtensionClassLibraryPtr p_library,
    GDExtensionInitialization *r_initialization
) {
	godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

	init_obj.register_initializer(initialize_gonzago_module);
	init_obj.register_terminator(uninitialize_gonzago_module);
	init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

	return init_obj.init();
}
}