class_name SaveWorker
extends RefCounted
## Writes autosaves off the main thread (SAV-08): at most one write in flight; a request made
## meanwhile replaces the single pending one (coalesced, never queued without bound). The worker
## picks the target itself from what is on disk (the older slot), encodes, round-trips, writes
## through SlotFile and then meta.json. It never logs (Log is main-thread): the Result carries
## the lines and `poll()` hands them on.

signal finished(result: Result)

const BUDGET_BYTES: int = 262144

var slots: SaveSlots
var coalesced: int = 0
var completed: int = 0
var _thread: Thread = null
var _pending: Dictionary = {}
var _has_pending: bool = false


class Result:
	extends RefCounted
	var error: Error = OK
	var slot: int = -1
	var seq: int = 0
	var point: String = ""
	var notes: Array[String] = []


func _init(p_slots: SaveSlots) -> void:
	slots = p_slots


func busy() -> bool:
	return _thread != null or _has_pending


## `request` = {point, body, meta}; body is the payload dictionary (already a snapshot).
func submit(request: Dictionary) -> void:
	if _thread != null:
		coalesced += int(_has_pending)
		_pending = request
		_has_pending = true
		return
	_start(request)


## Main-thread pump: collects a finished write and starts the pending one.
func poll() -> void:
	if _thread != null and not _thread.is_alive():
		_collect()


## Blocks until nothing is in flight or pending (quit, tests).
func flush() -> void:
	while busy():
		if _thread != null:
			_collect()
		elif _has_pending:
			_start(_take_pending())


func _start(request: Dictionary) -> void:
	_thread = Thread.new()
	@warning_ignore("return_value_discarded")
	_thread.start(_run.bind(request))


func _take_pending() -> Dictionary:
	var request: Dictionary = _pending
	_pending = {}
	_has_pending = false
	return request


func _collect() -> void:
	var raw: Variant = _thread.wait_to_finish()
	var result: Result = raw if raw is Result else Result.new()
	_thread = null
	completed += 1
	for note: String in result.notes:
		Log.warn("save", note)
	finished.emit(result)
	if _has_pending:
		_start(_take_pending())


## The write itself, on the calling thread (what the worker thread runs; tests, tools).
func write_now(request: Dictionary) -> Result:
	return _run(request)


func _run(request: Dictionary) -> Result:
	var out: Result = Result.new()
	out.point = str(request.get("point", ""))
	var infos: Array[SaveSlots.Info] = slots.scan()
	out.slot = slots.pick_target(infos)
	if out.slot < 0:
		out.error = ERR_UNAUTHORIZED
		out.notes.append("both slots hold a newer save: not writing")
		return out
	out.seq = slots.highest_seq(infos) + 1
	var envelope: Dictionary = {
		"save_version": SaveMigrations.CURRENT,
		"seq": out.seq,
		"saved_unix": int(Time.get_unix_time_from_system()),
		"point": out.point,
		"body": request.get("body", {}),
	}
	var bytes: PackedByteArray = GtsvContainer.encode(envelope)
	var back: GtsvContainer.Decoded = GtsvContainer.decode(bytes)
	if back.kind != GtsvContainer.Kind.OK or back.seq() != out.seq:
		out.error = ERR_INVALID_DATA
		out.notes.append("encoded save does not round-trip: %s" % back.reason)
		return out
	if bytes.size() > BUDGET_BYTES:
		out.notes.append(
			"save is %d bytes, over the %d budget (SAV-05)" % [bytes.size(), BUDGET_BYTES]
		)
	out.error = SlotFile.write(slots.slot_path(out.slot), bytes)
	if out.error != OK:
		out.notes.append(
			"write to %s failed (%s)" % [SaveSlots.IDS[out.slot], error_string(out.error)]
		)
		return out
	var meta: Dictionary = {}
	var raw_meta: Variant = request.get("meta")
	if raw_meta is Dictionary:
		meta = raw_meta
	SaveMeta.write(slots, meta, out)
	return out
