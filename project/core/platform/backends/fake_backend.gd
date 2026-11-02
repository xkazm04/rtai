class_name FakeBackend
extends PlatformBackend
## In-memory backend for tests (STM-02). Records calls; `fail_flush` simulates a failed store.

var fail_flush: bool = false
var calls: Array[String] = []
var presence: Dictionary[String, String] = {}
var _unlocked: Dictionary[StringName, bool] = {}
var _stats: Dictionary[StringName, int] = {}
var _stored_unlocks: int = 0


func backend_name() -> StringName:
	return &"fake"


func start() -> bool:
	calls.append("start")
	return true


func shutdown() -> void:
	calls.append("shutdown")


func poll() -> void:
	return


func is_online() -> bool:
	return false


func unlock(id: StringName) -> bool:
	calls.append("unlock:%s" % id)
	if _unlocked.has(id):
		return false
	_unlocked[id] = true
	achievement_confirmed.emit(id)
	return true


func is_unlocked(id: StringName) -> bool:
	return _unlocked.has(id)


func set_stat(id: StringName, value: int) -> bool:
	_stats[id] = value
	return true


func inc_stat(id: StringName, by: int) -> int:
	var next: int = get_stat(id) + by
	_stats[id] = next
	return next


func get_stat(id: StringName) -> int:
	return _stats.get(id, 0)


func flush() -> bool:
	calls.append("flush")
	if fail_flush:
		store_failed.emit("fake store failure")
		return false
	_stored_unlocks = _unlocked.size()
	return true


func stored_unlock_count() -> int:
	return _stored_unlocks


func rich_presence(key: String, value: String) -> bool:
	presence[key] = value
	return true


func hardware() -> Hardware:
	return Hardware.DESKTOP


func text_input_request(_prompt: String, _multiline: bool) -> bool:
	return false


func glyph_family() -> GlyphFamily:
	return GlyphFamily.KBM


func profile_dir() -> String:
	return "user://test_profile/"


func cloud_enabled() -> bool:
	return false
