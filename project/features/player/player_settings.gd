class_name PlayerSettings
extends RefCounted
## The player's settings as versioned JSON (`gtai.player-settings/1`, SAV-10 device side):
## master volume (0..1), the reduced-motion flag and key rebinds (action id -> physical key
## name). apply() pushes them into the AudioServer and the InputMap. Read with the JSON class
## only (SEC-02); unknown or bad fields fall back to the defaults.

const SCHEMA: String = "gtai.player-settings/1"
const PATH: String = "user://settings.json"
## The actions a player may rebind on the keyboard (the menu lists them in this order).
const REBINDABLE: Array[StringName] = [
	&"move_up", &"move_down", &"move_left", &"move_right", &"interact", &"melee", &"car"
]

var volume: float = 0.8
var reduced_motion: bool = false
var keys: Dictionary[String, String] = {}


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
		"schema": SCHEMA, "volume": volume, "reduced_motion": reduced_motion, "keys": keys
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
