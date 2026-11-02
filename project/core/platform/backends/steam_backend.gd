class_name SteamBackend
extends PlatformBackend
## Steam backend (STM-01..08). THE ONLY FILE ALLOWED TO CONTAIN THE STEAM SINGLETON (STM-03).
## Empty until GodotSteam (GDExtension, versions.toml) is vendored at the first Steam milestone.
## Only reached when the build carries the `steam` feature tag; start() fails so Platform
## degrades to NullBackend and logs why (STM-05).

const NOT_READY: String = "GodotSteam not vendored yet"


func backend_name() -> StringName:
	return &"steam"


func start() -> bool:
	Log.warn("platform", "steam backend unavailable: %s" % NOT_READY)
	return false


func shutdown() -> void:
	return


func poll() -> void:
	return


func is_online() -> bool:
	return false


func unlock(_id: StringName) -> bool:
	return false


func is_unlocked(_id: StringName) -> bool:
	return false


func set_stat(_id: StringName, _value: int) -> bool:
	return false


func inc_stat(_id: StringName, _by: int) -> int:
	return 0


func get_stat(_id: StringName) -> int:
	return 0


func flush() -> bool:
	return false


func rich_presence(_key: String, _value: String) -> bool:
	return false


func hardware() -> Hardware:
	return Hardware.DESKTOP


func text_input_request(_prompt: String, _multiline: bool) -> bool:
	return false


func glyph_family() -> GlyphFamily:
	return GlyphFamily.KBM


func profile_dir() -> String:
	return NullBackend.PROFILE_DIR


func cloud_enabled() -> bool:
	return false
