// GDExtension entry point (entry_symbol gtai_sim_init in project/native/gtai_sim.gdextension).
#include <gdextension_interface.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

#include "city_sim.h"

using namespace godot;

static void initialize_gtai_sim(ModuleInitializationLevel level) {
	if (level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
	GDREGISTER_CLASS(CitySim);
}

static void uninitialize_gtai_sim(ModuleInitializationLevel) {}

extern "C" {
GDExtensionBool GDE_EXPORT gtai_sim_init(GDExtensionInterfaceGetProcAddress get_proc_address,
		const GDExtensionClassLibraryPtr library, GDExtensionInitialization *r_initialization) {
	GDExtensionBinding::InitObject init_obj(get_proc_address, library, r_initialization);
	init_obj.register_initializer(initialize_gtai_sim);
	init_obj.register_terminator(uninitialize_gtai_sim);
	init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);
	return init_obj.init();
}
}
