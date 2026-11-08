class_name PlayerSettings
extends RefCounted
## The player's settings as versioned JSON (`gtai.player-settings/1`, SAV-10 device side):
## master volume (0..1), the reduced-motion flag, key rebinds (action id -> physical key
## name), a frame cap (0 = the device row's own; the handheld pause card offers 30/40/60), a
## rumble level (1 / 0.5 / 0 on the device row's gain) and the frame pacing (n9 Call P-3:
## "efficient" = no limiter at 60 Hz, the default; "steady" = the limiter on top of
## vsync). apply() pushes them into the AudioServer,
## the InputMap, Engine.max_fps and HandheldRumble. Read with the
## JSON class only (SEC-02); unknown or bad fields fall back to the defaults.

const SCHEMA: String = "gtai.player-settings/1"
const PATH: String = "user://settings.json"
## The actions a player may rebind on the keyboard (the menu lists them in this order).
const REBINDABLE: Array[StringName] = [
	&"move_up", &"move_down", &"move_left", &"move_right", &"interact", &"melee", &"car"
]
## The frame caps a player may pick (0 = the device profile's own cap).
const FRAME_CAPS: Array[int] = [0, 30, 40, 60]
## The rumble levels a player may pick (full, half, off), times the device row's gain.
const RUMBLE_LEVELS: Array[float] = [1.0, 0.5, 0.0]
## The frame pacings a player may pick; the first is the default.
const PACINGS: Array[String] = ["efficient", "steady"]

var volume: float = 0.8
var reduced_motion: bool = false
var keys: Dictionary[String, String] = {}
var frame_cap: int = 0
var rumble: float = 1.0
var pacing: String = PACINGS[0]


static func load_or_default(path: String = PATH) -> PlayerSettings:
	var s: PlayerSettings = PlayerSettings.new()
	if not FileAccess.file_exists(path):
		return s
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		return s
	var d: Dictionary = parser.data
	if d.get("schema") != SCHEMA:
		return s
	var v: Variant = d.get("volume")
	var vol: float = v if v is float else s.volume
	s.volume = clampf(vol, 0.0, 1.0)
	var rm: Variant = d.get("reduced_motion")
	var flag: bool = rm if rm is bool else false
	s.reduced_motion = flag
	var fc: Variant = d.get("frame_cap")
	var cap: float = fc if fc is float else 0.0
	s.frame_cap = int(cap) if FRAME_CAPS.has(int(cap)) else 0
	var ru: Variant = d.get("rumble")
	var level: float = ru if ru is float else 1.0
	s.rumble = level if RUMBLE_LEVELS.has(level) else 1.0
	var pa: Variant = d.get("pacing")
	s.pacing = str(pa) if pa is String and PACINGS.has(str(pa)) else PACINGS[0]
	var k: Variant = d.get("keys")
	var raw: Dictionary = k if k is Dictionary else {}
	for action: Variant in raw:
		var key_name: Variant = raw[action]
		if REBINDABLE.has(StringName(str(action))) and key_name is String:
			s.keys[str(action)] = str(key_name)
	return s


func save(path: String = PATH) -> Error:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var body: Dictionary = {
		"schema": SCHEMA,
		"volume": volume,
		"reduced_motion": reduced_motion,
		"keys": keys,
		"frame_cap": frame_cap,
		"rumble": rumble,
		"pacing": pacing
	}
	var ok: bool = file.store_string(JSON.stringify(body, "  ", true))
	file.close()
	return OK if ok else ERR_FILE_CANT_WRITE


## Volume to the master bus; every rebind replaces the action's keyboard keys (pads and the
## mouse keep their defaults).
func apply() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume, 0.0001)))
	for action: String in keys:
		rebind(StringName(action), keys[action])
	apply_frame_cap()
	HandheldRumble.player_gain = rumble


## The player's cap, else the device row's, else (the desktop row has none) the pacing on top of
## the boot cap (FrameCap).
func apply_frame_cap() -> void:
	if frame_cap > 0:
		Engine.max_fps = frame_cap
	elif DeviceProfile.shared().max_fps >= 0:
		Engine.max_fps = DeviceProfile.shared().max_fps
	else:
		FrameCap.apply_pacing(pacing == "steady")


func rebind(action: StringName, key_name: String) -> void:
	var code: Key = OS.find_keycode_from_string(key_name)
	if not InputMap.has_action(action) or code == KEY_NONE:
		return
	for ev: InputEvent in InputMap.action_get_events(action):
		if ev is InputEventKey:
			InputMap.action_erase_event(action, ev)
	var k: InputEventKey = InputEventKey.new()
	k.physical_keycode = code
	InputMap.action_add_event(action, k)
	keys[String(action)] = key_name
