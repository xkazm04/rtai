extends Node
## Save autoload (SAV-01..09): exactly two rotating autosave slots, the GTSV container, a
## threaded atomic writer, and a loader that falls back to the other slot when one is bad.
## Autosave only; manual save is descoped. Quests declare where they autosave
## (features/save/autosave_points.gd); the game calls `autosave(point, body)` at those edges.

signal autosaved(result: SaveWorker.Result)
## A one-line notice for the HUD/title to show (key for Loc, English fallback text).
signal notice(key: StringName, text: String)

const DEFAULT_ROOT: String = "user://profile"

var _slots: SaveSlots
var _worker: SaveWorker
var _active_slot: int = -1
var _last_notice: String = ""


func _init() -> void:
	_open(DEFAULT_ROOT)


func _process(_delta: float) -> void:
	_worker.poll()


## Points the engine at another profile folder (tests, --profile). Flushes first.
func use_root(root: String) -> void:
	flush()
	_open(root)


func _open(root: String) -> void:
	_slots = SaveSlots.new(root)
	_worker = SaveWorker.new(_slots)
	@warning_ignore("return_value_discarded")
	_worker.finished.connect(_on_finished)
	_active_slot = -1


func slots() -> SaveSlots:
	return _slots


func worker() -> SaveWorker:
	return _worker


func active_slot() -> int:
	return _active_slot


## Queues an autosave of `body` (a snapshot taken now, on the main thread). `meta` feeds
## meta.json: quest, beat, playtime_s. Returns at once; at most one write runs at a time.
func autosave(point: String, body: Dictionary, meta: Dictionary = {}) -> void:
	_worker.submit({"point": point, "body": body.duplicate(true), "meta": meta})


## Waits for the write in flight and the pending one (quit, tests).
func flush() -> void:
	_worker.flush()


## True when at least one slot file exists (the title card's Continue).
func has_continue() -> bool:
	return (
		FileAccess.file_exists(_slots.slot_path(0)) or FileAccess.file_exists(_slots.slot_path(1))
	)


## Loads the newest valid slot through `accept` (see SaveLoader). Raises `notice` on a fallback.
func load_latest(accept: Callable) -> SaveLoader.Outcome:
	flush()
	var out: SaveLoader.Outcome = SaveLoader.load_latest(_slots, accept)
	for line: String in out.lines:
		Log.warn("save", line)
	_active_slot = out.slot
	if out.notice != "":
		_last_notice = out.notice
		notice.emit(out.notice_key, out.notice)
	return out


## The last notice raised, once; "" afterwards (a HUD that was not listening yet).
func take_notice() -> String:
	var text: String = _last_notice
	_last_notice = ""
	return text


func read_meta() -> Dictionary:
	return SaveMeta.read(_slots)


func reset() -> void:
	flush()
	_active_slot = -1
	_last_notice = ""


func _on_finished(result: SaveWorker.Result) -> void:
	if result.error == OK:
		_active_slot = result.slot
	autosaved.emit(result)
