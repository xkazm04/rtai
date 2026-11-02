class_name NullBackend
extends PlatformBackend
## Offline backend (STM-05/06): the local mirror is the store. Not a stub that says yes:
## unlocks persist across runs and queue in `pending` for replay into Steam later.

const PROFILE_DIR: String = "user://profile/"

var _mirror: AchievementMirror
var _started: bool = false


func _init(mirror_path: String = AchievementMirror.DEFAULT_PATH) -> void:
	_mirror = AchievementMirror.new(mirror_path)


func backend_name() -> StringName:
	return &"null"


func start() -> bool:
	var err: Error = _mirror.load_from_disk()
	if err != OK:
		Log.warn(
			"platform",
			"mirror %s unreadable (%s); starting empty" % [_mirror.location(), error_string(err)]
		)
	_started = true
	return true


func shutdown() -> void:
	if _started and not flush():
		Log.warn("platform", "final flush failed; unlocks stay pending in the mirror")
	_started = false


func poll() -> void:
	return


func is_online() -> bool:
	return false


func unlock(id: StringName) -> bool:
	if _mirror.unlocked.has(id):
		return false
	_mirror.unlocked[id] = Time.get_datetime_string_from_system(true)
	_mirror.pending.append(id)
	achievement_confirmed.emit(id)
	return true


func is_unlocked(id: StringName) -> bool:
	return _mirror.unlocked.has(id)


func set_stat(id: StringName, value: int) -> bool:
	_mirror.stats[id] = value
	return true


func inc_stat(id: StringName, by: int) -> int:
	var next: int = get_stat(id) + by
	_mirror.stats[id] = next
	return next


func get_stat(id: StringName) -> int:
	return _mirror.stats.get(id, 0)


func flush() -> bool:
	var err: Error = _mirror.save_to_disk()
	if err != OK:
		store_failed.emit(error_string(err))
		return false
	return true


func rich_presence(_key: String, _value: String) -> bool:
	return false


func hardware() -> Hardware:
	return Hardware.DESKTOP


func text_input_request(_prompt: String, _multiline: bool) -> bool:
	return false


func glyph_family() -> GlyphFamily:
	return GlyphFamily.KBM


func profile_dir() -> String:
	return PROFILE_DIR


func cloud_enabled() -> bool:
	return false


## Unlocks not yet confirmed by Steam (the replay queue).
func pending_unlocks() -> Array[StringName]:
	return _mirror.pending.duplicate()
