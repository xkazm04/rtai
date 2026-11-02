extends Node
## Platform autoload (STM-02). Always processes. Owns exactly one PlatformBackend and forwards
## its signals. Gameplay never calls this directly: it emits Events, and the AchievementTracker
## (owned here, lands with the achievements ticket) calls unlock/set_stat/flush (ACH-07).

signal achievement_confirmed(id: StringName)
signal store_failed(reason: String)
signal overlay_toggled(open: bool)

var _backend: PlatformBackend


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


## SteamBackend only with the `steam` feature tag and a successful start (STM-02/05);
## otherwise NullBackend, with the reason logged.
func _ready() -> void:
	if OS.has_feature("steam"):
		if use_backend(SteamBackend.new()):
			return
		Log.warn("platform", "steam tag set but Steam did not start; using NullBackend")
	if not use_backend(NullBackend.new()):
		Log.error("platform", "NullBackend failed to start")


func _process(_delta: float) -> void:
	_backend.poll()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and _backend != null:
		_backend.shutdown()


## Swaps the active backend (tests inject a FakeBackend here) and starts it.
## Returns false when the new backend did not start.
func use_backend(backend: PlatformBackend) -> bool:
	if _backend != null:
		_backend.shutdown()
		_backend.achievement_confirmed.disconnect(achievement_confirmed.emit)
		_backend.store_failed.disconnect(store_failed.emit)
		_backend.overlay_toggled.disconnect(overlay_toggled.emit)
	_backend = backend
	var wired: int = OK
	wired |= _backend.achievement_confirmed.connect(achievement_confirmed.emit)
	wired |= _backend.store_failed.connect(store_failed.emit)
	wired |= _backend.overlay_toggled.connect(overlay_toggled.emit)
	if wired != OK:
		Log.error("platform", "could not wire backend %s signals" % _backend.backend_name())
	return _backend.start()


func backend_name() -> StringName:
	return _backend.backend_name() if _backend != null else &"none"


func is_online() -> bool:
	return _backend.is_online()


func unlock(id: StringName) -> bool:
	return _backend.unlock(id)


func is_unlocked(id: StringName) -> bool:
	return _backend.is_unlocked(id)


func set_stat(id: StringName, value: int) -> bool:
	return _backend.set_stat(id, value)


func inc_stat(id: StringName, by: int) -> int:
	return _backend.inc_stat(id, by)


func get_stat(id: StringName) -> int:
	return _backend.get_stat(id)


func flush() -> bool:
	return _backend.flush()


func rich_presence(key: String, value: String) -> bool:
	return _backend.rich_presence(key, value)


func hardware() -> PlatformBackend.Hardware:
	return _backend.hardware()


func text_input_request(prompt: String, multiline: bool) -> bool:
	return _backend.text_input_request(prompt, multiline)


func glyph_family() -> PlatformBackend.GlyphFamily:
	return _backend.glyph_family()


func profile_dir() -> String:
	return _backend.profile_dir()


func cloud_enabled() -> bool:
	return _backend.cloud_enabled()
