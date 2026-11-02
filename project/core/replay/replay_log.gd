class_name ReplayLog
extends RefCounted
## A recorded run (SIM-05): master seed, build, per-tick input (stored as changes only), a state
## hash every CHECKPOINT_EVERY ticks, the event timeline and the final hash. Saved as JSON
## (`gtai.replay/1`, DAT-07). Two logs of the same build, seed and inputs must compare equal.

const SCHEMA: String = "gtai.replay/1"
const CHECKPOINT_EVERY: int = 60

var master_seed: int = 0
var build: String = ""
var ticks: int = 0
var final_hash: String = ""
var checkpoints: Array[String] = []
var timeline: Array[String] = []
var _change_ticks: Array[int] = []
var _change_inputs: Array[int] = []


func _init(p_master_seed: int = 0, p_build: String = build_id()) -> void:
	master_seed = p_master_seed
	build = p_build


## Engine build + game version. The export pipeline will stamp a git hash into the version.
static func build_id() -> String:
	var version: String = ProjectSettings.get_setting("application/config/version", "")
	var engine_hash: String = Engine.get_version_info().get("hash", "")
	return "%s+%s" % [version if version != "" else "dev", engine_hash.left(12)]


## Parses a saved log; returns null (and logs why) on any schema or shape problem.
static func load_file(path: String) -> ReplayLog:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		Log.error("replay", "%s: not JSON (%s)" % [path, parser.get_error_message()])
		return null
	var d: Dictionary = parser.data
	var input_ticks: Array = d.get("input_ticks", [])
	var inputs: Array = d.get("inputs", [])
	if d.get("schema") != SCHEMA or _int(d.get("tick_rate")) != SimClock.TICK_RATE:
		Log.error("replay", "%s: schema or tick rate mismatch" % path)
		return null
	if input_ticks.size() != inputs.size():
		Log.error("replay", "%s: input_ticks and inputs differ in length" % path)
		return null
	var log: ReplayLog = ReplayLog.new(_int(d.get("master_seed")), str(d.get("build", "")))
	log.ticks = _int(d.get("ticks"))
	log.final_hash = str(d.get("final_hash", ""))
	var saved_checkpoints: Array = d.get("checkpoints", [])
	var saved_timeline: Array = d.get("timeline", [])
	log.checkpoints.assign(saved_checkpoints)
	log.timeline.assign(saved_timeline)
	for i: int in inputs.size():
		log._change_ticks.append(_int(input_ticks[i]))
		log._change_inputs.append(_int(inputs[i]))
	return log


## JSON numbers arrive as floats (DAT-05); anything that is not a number reads as -1.
static func _int(value: Variant) -> int:
	if value is float:
		var number: float = value
		return int(number)
	return value if value is int else -1


static func _list_divergence(a: Array[String], b: Array[String], what: String) -> String:
	for i: int in mini(a.size(), b.size()):
		if a[i] != b[i]:
			if what == "checkpoint":
				return "state hash differs at tick %d" % ((i + 1) * CHECKPOINT_EVERY)
			return "%s %d: '%s' vs '%s'" % [what, i, a[i], b[i]]
	if a.size() != b.size():
		return "%s count %d vs %d" % [what, a.size(), b.size()]
	return ""


## Records the tick's input; only a change from the previous tick is stored.
func record_input(tick: int, input: TickInput) -> void:
	var packed: int = input.pack()
	var last: int = (
		_change_inputs.back() if not _change_inputs.is_empty() else TickInput.new().pack()
	)
	if packed != last:
		_change_ticks.append(tick)
		_change_inputs.append(packed)


func input_at(tick: int) -> TickInput:
	var i: int = _change_ticks.bsearch(tick, false) - 1
	return TickInput.unpack(_change_inputs[i]) if i >= 0 else TickInput.new()


func input_changes() -> int:
	return _change_ticks.size()


## Overwrites the input stored for `tick` (planted-mutation tests only).
func tamper_input(tick: int, input: TickInput) -> void:
	var i: int = _change_ticks.bsearch(tick, true)
	if i < _change_ticks.size() and _change_ticks[i] == tick:
		_change_inputs[i] = input.pack()
		return
	var err: int = _change_ticks.insert(i, tick)
	err |= _change_inputs.insert(i, input.pack())
	if err != OK:
		Log.error("replay", "tamper_input failed (%d)" % err)


## "" when equal, else the first difference: header, then checkpoints, timeline, final hash.
func first_divergence(other: ReplayLog) -> String:
	var reason: String = ""
	if other.build != build:
		reason = "build %s vs %s (replays hold within one build, SIM-04)" % [build, other.build]
	elif other.master_seed != master_seed or other.ticks != ticks:
		reason = "header: seed %d/%d" % [master_seed, other.master_seed]
		reason += ", ticks %d/%d" % [ticks, other.ticks]
	if reason == "":
		reason = _list_divergence(checkpoints, other.checkpoints, "checkpoint")
	if reason == "":
		reason = _list_divergence(timeline, other.timeline, "event")
	if reason == "" and final_hash != other.final_hash:
		reason = "final hash differs"
	return reason


func to_dict() -> Dictionary:
	return {
		"schema": SCHEMA,
		"master_seed": master_seed,
		"build": build,
		"tick_rate": SimClock.TICK_RATE,
		"ticks": ticks,
		"final_hash": final_hash,
		"checkpoint_every": CHECKPOINT_EVERY,
		"checkpoints": checkpoints,
		"timeline": timeline,
		"input_ticks": _change_ticks,
		"inputs": _change_inputs,
	}


func save(path: String) -> Error:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var ok: bool = file.store_string(JSON.stringify(to_dict(), "", true))
	file.close()
	return OK if ok else ERR_FILE_CANT_WRITE
