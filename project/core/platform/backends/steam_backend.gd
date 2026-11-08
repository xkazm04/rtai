class_name SteamBackend
extends PlatformBackend
## Steam backend (STM-01..08). THE ONLY FILE ALLOWED TO CONTAIN THE STEAM SINGLETON (STM-03).
## Empty until GodotSteam (GDExtension, versions.toml) is vendored at the first Steam milestone.
## Only reached when the build carries the `steam` feature tag; start() fails so Platform
## degrades to NullBackend and logs why (STM-05).

const NOT_READY: String = "GodotSteam not vendored yet"
## ESteamHardwareType's values (k_ESteamHardwareTypeNone, ...SteamDeck): check against the SDK
## header when GodotSteam is vendored (LEDGER, n10).
const HARDWARE_NONE: int = 0
const HARDWARE_DECK: int = 1


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


## n10-handheld: the one call when GodotSteam is vendored (SDK 1.65 removed the Deck check,
## LEDGER section 9): `return hardware_of(Steam.isRunningOnSteamHardware())`. The method name is
## GodotSteam's and unconfirmed.
func hardware() -> Hardware:
	return hardware_of(HARDWARE_NONE)


## ESteamHardwareType (SDK 1.65) as this game reads it: a Deck, other Steam hardware, or neither.
static func hardware_of(steam_hardware_type: int) -> Hardware:
	if steam_hardware_type == HARDWARE_NONE:
		return Hardware.DESKTOP
	return Hardware.STEAM_DECK if steam_hardware_type == HARDWARE_DECK else Hardware.STEAM_HARDWARE


## n10-handheld: the one call when GodotSteam is vendored, for the first pad's handle:
## `var origin: int = Steam.getActionOriginFromXboxOrigin(handle, XBOX[label])`, then
## `return Steam.getGlyphPNGForActionOrigin(origin, size, 0)`. Names unconfirmed, as above.
func action_glyph_path(_xbox_label: String) -> String:
	return ""


func text_input_request(_prompt: String, _multiline: bool) -> bool:
	return false


func glyph_family() -> GlyphFamily:
	return GlyphFamily.KBM


func profile_dir() -> String:
	return NullBackend.PROFILE_DIR


func cloud_enabled() -> bool:
	return false
